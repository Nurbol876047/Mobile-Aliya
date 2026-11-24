"""FloraCare бэкенді: веб-прототипті таратады және фотоны OpenAI (GPT) арқылы талдайды.

API кілті тек серверде (.env) сақталады — браузерге/қолданбаға берілмейді.
Тек стандартты Python кітапханасы қолданылады (pip қажет емес).

Іске қосу:  python3 backend/server.py   →  http://127.0.0.1:8090
"""
from __future__ import annotations

import base64
import binascii
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parent
STATIC_DIR = PROJECT / "web_prototype"

# Әдепкіде тек осы компьютер. Телефоннан кіру үшін: python3 backend/server.py 0.0.0.0
HOST = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("-") \
    else os.getenv("FLORACARE_HOST", "127.0.0.1")
PORT = int(os.getenv("PORT") or os.getenv("FLORACARE_PORT", "8090"))
MAX_BODY = 12 * 1024 * 1024          # base64 фото ≈ 9 МБ дейін
ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp"}
MODELS = [m.strip() for m in os.getenv(
    "OPENAI_MODELS",
    "gpt-4o-mini,gpt-4.1-mini",
).split(",") if m.strip()]
API_URL = "https://api.openai.com/v1/chat/completions"
TOTAL_BUDGET = 75          # бір талдауға жалпы уақыт шегі, секунд
RETRY_CODES = {429, 500, 502, 503, 504}   # уақытша қателер — қайталауға болады
# Flutter веб-нұсқасы басқа порттан сұрайды (мыс. :8080) — тек жергілікті origin-дерге рұқсат.
# Мобильді қолданба (Android/iOS) Origin тақырыбын жібермейді, оған CORS қажет емес.
# Жергілікті origin-дер: localhost және үй желісінің жеке IP-лері
# (телефоннан Wi-Fi арқылы ашу үшін).
CORS_RE = re.compile(
    r"^https?://("
    r"localhost|127\.0\.0\.1|\[::1\]"
    r"|192\.168\.\d{1,3}\.\d{1,3}"
    r"|10\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    r"|172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}"
    r")(:\d+)?$"
)
# Өндірістегі веб-қолданба үшін нақты рұқсат етілген origin-дер (мыс. GitHub Pages),
# үтірмен бөлек FLORACARE_EXTRA_ORIGINS айнымалысы арқылы беріледі.
EXTRA_ORIGINS = {
    o.strip().rstrip("/") for o in os.getenv("FLORACARE_EXTRA_ORIGINS", "").split(",") if o.strip()
}


def origin_allowed(origin: str) -> bool:
    return bool(origin) and (bool(CORS_RE.match(origin)) or origin.rstrip("/") in EXTRA_ORIGINS)


def load_key() -> str:
    """Кілтті ортаның айнымалысынан немесе жоба түбіріндегі .env файлынан оқиды."""
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if key:
        return key
    env = PROJECT / ".env"
    if env.is_file():
        for line in env.read_text(encoding="utf-8").splitlines():
            if line.startswith("OPENAI_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    return ""


API_KEY = load_key()

PROMPT = """Сен — үй және бау-бақша өсімдіктерінің денсаулығын бағалайтын тәжірибелі агроном-фитопатолог әрі ботаниксің.
Суреттегі өсімдікті (әсіресе жапырақтарды, гүлін, сабағын) мұқият қарап, толық, түсінікті есеп бер.

Ережелер:
- Мәтінді төмендегі МАҢЫЗДЫ нұсқаудағы тілде жаз (латынша атаулардан басқа). Өзіңді, модельді немесе компанияны атама.
- Суретте өсімдік жоқ болса немесе сурет тым бұлыңғыр/қараңғы болса, is_plant=false қой, photo_quality_note толтыр,
  күйді "warning" қой, өсімдік туралы өрістерді бос қалдыр (ойдан толтырма).
- status: "healthy" — айқын белгі жоқ; "warning" — сарғаю, солу, дақтар, зиянкес белгілері басталған;
  "critical" — кең таралған қоңыр/қара дақтар, шірік, кебу, ауыр зақым.
- green_pct, yellow_pct, brown_pct — жапырақ (гүл болса — өсімдік) ауданындағы түс үлесі (қосындысы ≈100).
- color_explanation — осы түс үлестері НЕНІ білдіретінін осы өсімдікке қатысты 2–3 сөйлеммен түсіндір
  (мыс. «сарғаю 30% — азот жетіспеушілігінің белгісі, төменгі жапырақтардан басталған»).
- health_score: 0 (өлген) … 100 (толық сау).
- summary — 2–3 сөйлемдік жалпы қорытынды.
- symptoms — суретте НАҚТЫ көрінетін белгілер (3–6); causes — ықтимал себептер, ең ықтималы бірінші (2–5);
  advice — нақты, орындалатын 4–6 қадам (не істеу, қашан, қанша).
- prognosis — қалпына келу мүмкіндігі және қанша уақытта (1–2 сөйлем).
- plant_info — өсімдік туралы деректер: latin_name, family (тұқымдасы қазақша + латынша), origin (отаны),
  description (өсімдік туралы 2–3 сөйлем), toxicity (адамға/үй жануарларына уыттылығы), fun_fact (бір қызықты дерек).
- care — осы түрге арналған күтім талаптары, әрқайсысы 1 сөйлем: light, watering, temperature, humidity, soil, fertilizer.
- next_check_days — келесі фото-тексеруді неше күннен кейін жасау керек (1–30).
- Сенімсіз болсаң, confidence мәнін төмен қой және оны жасырма. Ойдан диагноз құрастырма.
{context}"""

SCHEMA = {
    "type": "OBJECT",
    "properties": {
        "is_plant": {"type": "BOOLEAN"},
        "plant_name": {"type": "STRING", "description": "Қазақша атауы (Латынша атауы)"},
        "status": {"type": "STRING", "enum": ["healthy", "warning", "critical"]},
        "health_score": {"type": "INTEGER"},
        "green_pct": {"type": "NUMBER"},
        "yellow_pct": {"type": "NUMBER"},
        "brown_pct": {"type": "NUMBER"},
        "color_explanation": {"type": "STRING"},
        "diagnosis": {"type": "STRING", "description": "Қысқа қорытынды, 2–6 сөз"},
        "summary": {"type": "STRING"},
        "symptoms": {"type": "ARRAY", "items": {"type": "STRING"}},
        "causes": {"type": "ARRAY", "items": {"type": "STRING"}},
        "advice": {"type": "ARRAY", "items": {"type": "STRING"}},
        "prognosis": {"type": "STRING"},
        "urgency": {"type": "STRING", "enum": ["low", "medium", "high"]},
        "confidence": {"type": "NUMBER", "description": "0..1"},
        "photo_quality_note": {"type": "STRING"},
        "plant_info": {
            "type": "OBJECT",
            "properties": {
                "latin_name": {"type": "STRING"},
                "family": {"type": "STRING"},
                "origin": {"type": "STRING"},
                "description": {"type": "STRING"},
                "toxicity": {"type": "STRING"},
                "fun_fact": {"type": "STRING"},
            },
            "required": ["latin_name", "family", "origin", "description", "toxicity", "fun_fact"],
        },
        "care": {
            "type": "OBJECT",
            "properties": {
                "light": {"type": "STRING"},
                "watering": {"type": "STRING"},
                "temperature": {"type": "STRING"},
                "humidity": {"type": "STRING"},
                "soil": {"type": "STRING"},
                "fertilizer": {"type": "STRING"},
            },
            "required": ["light", "watering", "temperature", "humidity", "soil", "fertilizer"],
        },
        "next_check_days": {"type": "INTEGER"},
    },
    "required": ["is_plant", "status", "health_score", "green_pct", "yellow_pct", "brown_pct",
                 "color_explanation", "diagnosis", "summary", "symptoms", "causes", "advice",
                 "prognosis", "urgency", "confidence", "plant_info", "care", "next_check_days"],
}

# OpenAI-дің strict structured output режимі: барлық өріс "required"-те болуы керек
# (бос мән қайтаруға болады) және әр объектіде additionalProperties: false болуы керек.
OPENAI_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "is_plant": {"type": "boolean"},
        "plant_name": {"type": "string", "description": "Қазақша атауы (Латынша атауы)"},
        "status": {"type": "string", "enum": ["healthy", "warning", "critical"]},
        "health_score": {"type": "integer"},
        "green_pct": {"type": "number"},
        "yellow_pct": {"type": "number"},
        "brown_pct": {"type": "number"},
        "color_explanation": {"type": "string"},
        "diagnosis": {"type": "string", "description": "Қысқа қорытынды, 2–6 сөз"},
        "summary": {"type": "string"},
        "symptoms": {"type": "array", "items": {"type": "string"}},
        "causes": {"type": "array", "items": {"type": "string"}},
        "advice": {"type": "array", "items": {"type": "string"}},
        "prognosis": {"type": "string"},
        "urgency": {"type": "string", "enum": ["low", "medium", "high"]},
        "confidence": {"type": "number", "description": "0..1"},
        "photo_quality_note": {"type": "string"},
        "plant_info": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "latin_name": {"type": "string"},
                "family": {"type": "string"},
                "origin": {"type": "string"},
                "description": {"type": "string"},
                "toxicity": {"type": "string"},
                "fun_fact": {"type": "string"},
            },
            "required": ["latin_name", "family", "origin", "description", "toxicity", "fun_fact"],
        },
        "care": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "light": {"type": "string"},
                "watering": {"type": "string"},
                "temperature": {"type": "string"},
                "humidity": {"type": "string"},
                "soil": {"type": "string"},
                "fertilizer": {"type": "string"},
            },
            "required": ["light", "watering", "temperature", "humidity", "soil", "fertilizer"],
        },
        "next_check_days": {"type": "integer"},
    },
    "required": ["is_plant", "plant_name", "status", "health_score", "green_pct", "yellow_pct", "brown_pct",
                 "color_explanation", "diagnosis", "summary", "symptoms", "causes", "advice",
                 "prognosis", "urgency", "confidence", "photo_quality_note", "plant_info", "care",
                 "next_check_days"],
}


LANG_DIRECTIVE = {
    "kk": "\nМАҢЫЗДЫ: барлық мәтін мәндерін ҚАЗАҚ тілінде жаз. IMPORTANT: write ALL text values in Kazakh.",
    "ru": "\nМАҢЫЗДЫ: барлық мәтін мәндерін ОРЫС тілінде жаз. IMPORTANT: write ALL text values in Russian.",
    "en": "\nМАҢЫЗДЫ: барлық мәтін мәндерін АҒЫЛШЫН тілінде жаз. IMPORTANT: write ALL text values in English.",
}


class AnalysisError(Exception):
    """code — клиент оны өз тілінде көрсетеді (busy, unavailable, key, bad_image, too_big, not_configured, bad_json)."""
    def __init__(self, message: str, status: int = 502, code: str = "unavailable"):
        super().__init__(message)
        self.status = status
        self.code = code


def parse_data_url(data_url: str) -> tuple[str, str]:
    """'data:image/jpeg;base64,...' → (mime, base64). Форматы мен өлшемін тексереді."""
    m = re.fullmatch(r"data:(image/[a-z+.-]+);base64,([A-Za-z0-9+/=\s]+)", data_url or "", re.S)
    if not m:
        raise AnalysisError("Фото форматы дұрыс емес.", 400, "bad_image")
    mime, b64 = m.group(1).lower(), re.sub(r"\s+", "", m.group(2))
    if mime not in ALLOWED_MIME:
        raise AnalysisError("Тек JPG, PNG немесе WEBP суреттеріне рұқсат.", 400, "bad_image")
    try:
        raw = base64.b64decode(b64, validate=True)
    except (binascii.Error, ValueError):
        raise AnalysisError("Фото деректері бұзылған.", 400, "bad_image")
    if not raw:
        raise AnalysisError("Фото бос.", 400, "bad_image")
    if len(raw) > 10 * 1024 * 1024:
        raise AnalysisError("Фото тым үлкен.", 413, "too_big")
    return mime, b64


def clamp(v, lo, hi, default):
    try:
        return max(lo, min(hi, float(v)))
    except (TypeError, ValueError):
        return default


def normalize(r: dict) -> dict:
    """Модель жауабын тексеріп, шекараларға келтіреді (UI сенімді түрде көрсетуі үшін)."""
    status = r.get("status") if r.get("status") in ("healthy", "warning", "critical") else "warning"
    g, y, b = (clamp(r.get(k), 0, 100, 0.0) for k in ("green_pct", "yellow_pct", "brown_pct"))
    total = g + y + b
    if total > 0:
        g, y, b = (round(v / total * 100, 1) for v in (g, y, b))
    lst = lambda k: [str(s).strip() for s in (r.get(k) or []) if str(s).strip()][:6]
    def txt(v, n):
        t = str(v or "").strip()
        return "" if t.lower() in {"n/a", "na", "-", "—", "жоқ", "белгісіз", "none", "null"} else t[:n]
    sub_obj = lambda k, keys, n: {f: txt((r.get(k) or {}).get(f) if isinstance(r.get(k), dict) else "", n) for f in keys}
    out = {
        "is_plant": bool(r.get("is_plant", True)),
        "plant_name": str(r.get("plant_name") or "").strip()[:80],
        "status": status,
        "health_score": int(clamp(r.get("health_score"), 0, 100, 50)),
        "green_pct": g, "yellow_pct": y, "brown_pct": b,
        "diagnosis": str(r.get("diagnosis") or "").strip()[:80],
        "summary": str(r.get("summary") or "").strip()[:600],
        "symptoms": lst("symptoms"), "causes": lst("causes"), "advice": lst("advice"),
        "urgency": r.get("urgency") if r.get("urgency") in ("low", "medium", "high") else "medium",
        "confidence": round(clamp(r.get("confidence"), 0, 1, 0.5), 2),
        "photo_quality_note": str(r.get("photo_quality_note") or "").strip()[:200],
        "color_explanation": txt(r.get("color_explanation"), 500),
        "prognosis": txt(r.get("prognosis"), 300),
        "plant_info": sub_obj("plant_info", ("latin_name", "family", "origin", "description", "toxicity", "fun_fact"), 400),
        "care": sub_obj("care", ("light", "watering", "temperature", "humidity", "soil", "fertilizer"), 220),
        "next_check_days": int(clamp(r.get("next_check_days"), 1, 30, 7)),
    }
    if not out["is_plant"]:
        # Өсімдік жоқ суретке «өсімдік туралы» және «күтім» деректерін көрсетпейміз
        out["plant_info"] = {k: "" for k in out["plant_info"]}
        out["care"] = {k: "" for k in out["care"]}
        out["color_explanation"] = ""
    return out


def log(msg: str):
    sys.stderr.write(time.strftime("%d/%b/%Y %H:%M:%S ") + msg + "\n")


def call_openai(mime: str, b64: str, plant: str = "", species: str = "", lang: str = "kk") -> dict:
    """Модельдерді кезекпен сынайды; уақытша қатеде (503/429/таймаут) бір рет қайталайды."""
    if not API_KEY:
        raise AnalysisError("ЖИ қызметі баптаулмаған.", 503, "not_configured")
    ctx = ""
    if plant or species:
        ctx = f"\nПайдаланушы бұл өсімдікті «{plant[:60]}» деп атаған" + (f" (түрі: {species[:60]})" if species else "") + "."
    prompt_text = PROMPT.replace("{context}", ctx) + LANG_DIRECTIVE.get(lang, LANG_DIRECTIVE["kk"])
    messages = [{"role": "user", "content": [
        {"type": "text", "text": prompt_text},
        {"type": "image_url", "image_url": {"url": f"data:{mime};base64,{b64}"}},
    ]}]

    started = time.time()
    attempts: list[str] = []
    busy = False
    for model in MODELS:
        body = json.dumps({
            "model": model,
            "messages": messages,
            "temperature": 0.2,
            "response_format": {
                "type": "json_schema",
                "json_schema": {"name": "plant_analysis", "strict": True, "schema": OPENAI_SCHEMA},
            },
        }).encode()

        for attempt in (1, 2):
            left = TOTAL_BUDGET - (time.time() - started)
            if left < 5:
                break
            t0 = time.time()
            req = urllib.request.Request(
                API_URL, data=body, method="POST",
                headers={"Content-Type": "application/json", "Authorization": f"Bearer {API_KEY}"},
            )
            try:
                with urllib.request.urlopen(req, timeout=min(35, left)) as resp:
                    data = json.loads(resp.read())
            except urllib.error.HTTPError as e:
                detail = ""
                try:
                    detail = json.loads(e.read()).get("error", {}).get("message", "")[:120]
                except Exception:
                    pass
                attempts.append(f"{model}#{attempt}: HTTP {e.code}")
                log(f"openai {model} try {attempt}: HTTP {e.code} {detail} ({time.time()-t0:.1f}s)")
                if e.code in (401, 403):
                    raise AnalysisError("ЖИ қызметінің кілті жарамсыз.", 502, "key")
                # 429 «insufficient_quota» — лимит/баланс таусылған: қайталаудың мәні жоқ,
                # бірден келесі модельге көшеміз (уақыт үнемделеді).
                quota_exhausted = e.code == 429 and "quota" in detail.lower()
                if e.code in RETRY_CODES and not quota_exhausted:
                    busy = True
                    if attempt == 1:
                        time.sleep(1.5)
                        continue          # сол модельді тағы бір рет
                break                     # 404, quota т.б. — келесі модель
            except (urllib.error.URLError, TimeoutError, OSError) as e:
                attempts.append(f"{model}#{attempt}: {type(e).__name__}")
                log(f"openai {model} try {attempt}: {e} ({time.time()-t0:.1f}s)")
                busy = True
                break                     # таймаут — уақытты үнемдеп, келесі модельге
            try:
                text = data["choices"][0]["message"]["content"]
                result = normalize(json.loads(text))
            except (KeyError, IndexError, TypeError, json.JSONDecodeError):
                attempts.append(f"{model}#{attempt}: bad format")
                log(f"openai {model} try {attempt}: unexpected response format")
                break
            log(f"openai {model} try {attempt}: OK ({time.time()-t0:.1f}s)")
            return {"model": "", "result": result}

    detail = "; ".join(attempts) or "жауап жоқ"
    if busy:
        raise AnalysisError("Талдау сервері қазір жүктелген.", 503, "busy")
    log(f"all models failed: {detail}")
    raise AnalysisError("ЖИ талдауы қазір қолжетімсіз.", 502, "unavailable")


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=str(STATIC_DIR), **kw)

    def log_message(self, fmt, *args):  # кілт ешқашан логқа түспейді, тек жол мен код
        sys.stderr.write("%s %s\n" % (self.log_date_time_string(), fmt % args))

    def end_headers(self):
        origin = self.headers.get("Origin", "")
        if origin_allowed(origin):
            self.send_header("Access-Control-Allow-Origin", origin)
            self.send_header("Vary", "Origin")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def _json(self, status: int, payload: dict):
        raw = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_OPTIONS(self):  # CORS preflight
        self.send_response(204)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self):
        if self.path.startswith("/api/health"):
            return self._json(200, {"ok": True, "ai": bool(API_KEY)})
        return super().do_GET()

    def do_POST(self):
        if not self.path.startswith("/api/analyze"):
            return self._json(404, {"ok": False, "error": "Табылмады"})
        length = int(self.headers.get("Content-Length") or 0)
        if length <= 0 or length > MAX_BODY:
            return self._json(413, {"ok": False, "code": "too_big", "error": "Сұраныс тым үлкен немесе бос."})
        try:
            payload = json.loads(self.rfile.read(length))
            mime, b64 = parse_data_url(payload.get("image", ""))
            t0 = time.time()
            lang = str(payload.get("lang", "kk"))
            out = call_openai(mime, b64, str(payload.get("plant", "")), str(payload.get("species", "")),
                              lang if lang in LANG_DIRECTIVE else "kk")
            out.update(ok=True, ms=int((time.time() - t0) * 1000))
            return self._json(200, out)
        except json.JSONDecodeError:
            return self._json(400, {"ok": False, "code": "bad_json", "error": "JSON қате."})
        except AnalysisError as e:
            return self._json(e.status, {"ok": False, "code": e.code, "error": str(e)})


if __name__ == "__main__":
    print(f"FloraCare: http://{HOST}:{PORT}  (ЖИ: {'қосулы' if API_KEY else 'кілт жоқ'}, модельдер: {', '.join(MODELS)})")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
