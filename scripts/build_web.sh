#!/usr/bin/env bash
# Flutter қолданбасының веб-нұсқасын жинайды → _src/build/web (оны backend/server.py таратады).
# Render осы скриптті әр деплойда іске қосады; жергілікті компьютерде де жұмыс істейді.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.0}"
cd "$(dirname "$0")/../_src"

# Render-де Flutter жоқ — уақытша қалтаға жүктейміз (деплой пакетіне кірмейді).
if ! command -v flutter >/dev/null 2>&1; then
  sdk="${TMPDIR:-/tmp}/flutter-$FLUTTER_VERSION"
  [ -x "$sdk/bin/flutter" ] ||
    git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$sdk"
  export PATH="$sdk/bin:$PATH"
fi

flutter --version
flutter pub get
# «/» — API дәл осы сайттың өзінде (бір origin), сондықтан бөлек мекенжай да, CORS та керек емес.
flutter build web --release --dart-define=AI_BACKEND_URL="${AI_BACKEND_URL:-/}"
