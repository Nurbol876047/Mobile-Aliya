/// Қызылорда облысында танымал өсімдіктер анықтамалығы (қазақша / русский / English).
/// Фотолар: assets/plants/ (Wikimedia Commons, авторлары — catalog_credits.dart).
library;

import '../l10n/l10n.dart';
import 'catalog_credits.dart';

enum CatalogCategory { indoor, garden, native }

/// [kk, ru, en]
typedef T3 = List<String>;

class CatalogPlant {
  final String id;
  final CatalogCategory category;
  final String latin;
  final String family;
  final T3 name;
  final T3 description;
  final T3 kyzylorda;
  final T3 light;
  final T3 water;
  final T3 temp;
  final T3 soil;
  final T3 toxicity;

  const CatalogPlant({
    required this.id,
    required this.category,
    required this.latin,
    required this.family,
    required this.name,
    required this.description,
    required this.kyzylorda,
    required this.light,
    required this.water,
    required this.temp,
    required this.soil,
    required this.toxicity,
  });

  String _l(T3 v) => v[L10n.current.index];
  String get title => _l(name);
  String get about => _l(description);
  String get localTip => _l(kyzylorda);
  String get tox => _l(toxicity);

  /// CareGrid форматына: light, watering, temperature, soil.
  Map<String, String> get care => {
        'light': _l(light),
        'watering': _l(water),
        'temperature': _l(temp),
        'soil': _l(soil),
      };

  PhotoCredit? get credit => catalogCredits[id];
  String? get image => credit == null ? null : 'assets/plants/${credit!.file}';

  /// Іздеу: барлық тілдегі атаулар мен латынша атау бойынша.
  bool matches(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return [...name, latin, family].any((v) => v.toLowerCase().contains(s));
  }
}

/// ЖИ анықтаған латынша атауды анықтамалықпен салыстыру (тек тек атауы бойынша).
CatalogPlant? catalogMatch(String latinOrName) {
  final s = latinOrName.toLowerCase();
  if (s.trim().isEmpty) return null;
  for (final p in catalog) {
    final genus = p.latin.split(' ').first.toLowerCase();
    if (genus.length > 3 && RegExp('\\b${RegExp.escape(genus)}\\b').hasMatch(s)) return p;
  }
  return null;
}

const T3 _fullSun = ['Толық күн', 'Полное солнце', 'Full sun'];
const T3 _nonToxic = ['Уытты емес', 'Нетоксично', 'Non-toxic'];

const List<CatalogPlant> _all = [
  // ===================== Бөлме өсімдіктері =====================
  CatalogPlant(
    id: 'pelargonium', category: CatalogCategory.indoor,
    latin: 'Pelargonium zonale', family: 'Geraniaceae',
    name: ['Қазтамақ (пеларгония)', 'Пеларгония (герань)', 'Geranium (Pelargonium)'],
    description: [
      'Ашық қызыл, қызғылт немесе ақ гүлді, жапырағы хош иісті бөлме өсімдігі. Қазақ үйлерінде ең көп өсірілетін гүлдердің бірі.',
      'Комнатное растение с яркими красными, розовыми или белыми соцветиями и ароматными листьями. Одно из самых распространённых растений в домах Казахстана.',
      'A houseplant with bright red, pink or white flower clusters and fragrant leaves. One of the most common plants in Kazakh homes.',
    ],
    kyzylorda: [
      'Ыстыққа шыдамды; жазда балконда өседі, бірақ шілденің түскі күнінен көлеңкелеу керек.',
      'Жаростойка; летом растёт на балконе, но в июльский полдень её лучше притенять.',
      'Heat-tolerant; can live on a balcony in summer but needs shade from the July midday sun.',
    ],
    light: ['Жарық, тікелей күн (түсте көлеңке)', 'Яркий свет, прямое солнце (в полдень — притенение)', 'Bright light, direct sun (shade at midday)'],
    water: ['Топырақ кепкенде, аптасына 1–2 рет', 'При подсыхании почвы, 1–2 раза в неделю', 'When the soil dries, 1–2 times a week'],
    temp: ['18–25°C (қыста 12–15°C)', '18–25°C (зимой 12–15°C)', '18–25°C (12–15°C in winter)'],
    soil: ['Жеңіл, су өткізгіш, дренажы бар', 'Лёгкая, водопроницаемая, с дренажом', 'Light, well-drained'],
    toxicity: ['Мысық пен итке аздап уытты', 'Слаботоксична для кошек и собак', 'Mildly toxic to cats and dogs'],
  ),
  CatalogPlant(
    id: 'aloe', category: CatalogCategory.indoor,
    latin: 'Aloe vera', family: 'Asphodelaceae',
    name: ['Алоэ вера', 'Алоэ вера', 'Aloe vera'],
    description: [
      'Етжеңді, жиегі тісті сукулент. Жапырағының гелі күйік пен жараға халықтық ем ретінде қолданылады.',
      'Суккулент с мясистыми листьями и зубчатыми краями. Гель из листьев применяют в народной медицине при ожогах и ранках.',
      'A succulent with fleshy, toothed leaves. Its leaf gel is a traditional remedy for burns and cuts.',
    ],
    kyzylorda: [
      'Құрғақ ауаға өте төзімді — Қызылорданың жылытылатын пәтерлеріне өте қолайлы.',
      'Очень устойчиво к сухому воздуху — идеально для отапливаемых квартир Кызылорды.',
      'Very tolerant of dry air — ideal for heated Kyzylorda flats.',
    ],
    light: ['Күнді терезе', 'Солнечное окно', 'Sunny window'],
    water: ['Сирек: жазда 10–14 күнде бір, қыста айына бір', 'Редко: летом раз в 10–14 дней, зимой раз в месяц', 'Sparingly: every 10–14 days in summer, monthly in winter'],
    temp: ['18–30°C', '18–30°C', '18–30°C'],
    soil: ['Кактус пен сукулентке арналған құмды', 'Песчаный грунт для кактусов и суккулентов', 'Sandy cactus and succulent mix'],
    toxicity: ['Үй жануарлары жесе — уытты', 'Токсично для домашних животных при поедании', 'Toxic to pets if eaten'],
  ),
  CatalogPlant(
    id: 'saintpaulia', category: CatalogCategory.indoor,
    latin: 'Saintpaulia ionantha', family: 'Gesneriaceae',
    name: ['Фиалка (сенполия)', 'Фиалка узамбарская (сенполия)', 'African violet'],
    description: [
      'Түкті жапырақты, күлгін, көк, ақ гүлді шағын бөлме өсімдігі. Дұрыс күтімде жыл бойы дерлік гүлдейді.',
      'Компактное растение с опушёнными листьями и фиолетовыми, синими или белыми цветками. При правильном уходе цветёт почти круглый год.',
      'A compact plant with fuzzy leaves and purple, blue or white flowers. With good care it blooms nearly all year.',
    ],
    kyzylorda: [
      'Тікелей күн мен құрғақ ауаны жақтырмайды: жазда терезеден алыстатыңыз, қыста ылғалдылықты арттырыңыз.',
      'Не любит прямое солнце и сухой воздух: летом уберите от окна, зимой повышайте влажность.',
      'Dislikes direct sun and dry air: move it away from the window in summer and raise humidity in winter.',
    ],
    light: ['Шашыраңқы жарық, тікелей күнсіз', 'Рассеянный свет без прямого солнца', 'Bright indirect light, no direct sun'],
    water: ['Табаннан, жылы сумен; жапыраққа тигізбеңіз', 'Через поддон тёплой водой, не мочить листья', 'From below with lukewarm water; keep leaves dry'],
    temp: ['18–24°C', '18–24°C', '18–24°C'],
    soil: ['Жеңіл, қышқылдау, фиалкаға арналған', 'Лёгкий слабокислый грунт для фиалок', 'Light, slightly acidic violet mix'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'ficus', category: CatalogCategory.indoor,
    latin: 'Ficus elastica', family: 'Moraceae',
    name: ['Фикус (резеңке фикус)', 'Фикус каучуконосный', 'Rubber plant (Ficus)'],
    description: [
      'Ірі, жылтыр, қою жасыл жапырақты, ағаш тәрізді әсем өсімдік. Бөлмеде 2–3 метрге дейін өседі.',
      'Декоративное древовидное растение с крупными глянцевыми тёмно-зелёными листьями. В помещении вырастает до 2–3 м.',
      'An ornamental tree-like plant with large glossy dark-green leaves. Indoors it grows up to 2–3 m.',
    ],
    kyzylorda: [
      'Батареяның жанында жапырақ түсіреді; құрғақ ауада жапырағын дымқыл шүберекпен сүртіңіз.',
      'У батареи сбрасывает листья; в сухом воздухе протирайте листья влажной тканью.',
      'Drops leaves next to radiators; wipe the leaves with a damp cloth in dry air.',
    ],
    light: ['Ашық шашыраңқы жарық', 'Яркий рассеянный свет', 'Bright indirect light'],
    water: ['Үстіңгі 2–3 см кепкенде', 'Когда верхние 2–3 см почвы подсохнут', 'When the top 2–3 cm of soil is dry'],
    temp: ['18–26°C', '18–26°C', '18–26°C'],
    soil: ['Құнарлы, бос, дренажы бар', 'Питательная, рыхлая, с дренажом', 'Rich, loose, well-drained'],
    toxicity: ['Сүтті шырыны теріні тітіркендіреді, жануарларға уытты', 'Млечный сок раздражает кожу, токсичен для животных', 'Milky sap irritates skin; toxic to pets'],
  ),
  CatalogPlant(
    id: 'chlorophytum', category: CatalogCategory.indoor,
    latin: 'Chlorophytum comosum', family: 'Asparagaceae',
    name: ['Хлорофитум', 'Хлорофитум хохлатый', 'Spider plant'],
    description: [
      'Ақ жолақты ұзын жіңішке жапырақты, мұртшаларында «балапан» өскіндер шығаратын күтімі оңай өсімдік.',
      'Неприхотливое растение с длинными узкими полосатыми листьями и «детками» на усах.',
      'An easy-care plant with long striped leaves and baby plantlets on runners.',
    ],
    kyzylorda: [
      'Ыстық пен құрғақ ауаға жақсы бейімделеді — жаңадан бастаушыға ең қолайлы.',
      'Хорошо переносит жару и сухой воздух — лучший выбор для начинающих.',
      'Copes well with heat and dry air — the best choice for beginners.',
    ],
    light: ['Жарық немесе жартылай көлеңке', 'Яркий свет или полутень', 'Bright light or partial shade'],
    water: ['Жазда мол, қыста қалыпты', 'Летом обильно, зимой умеренно', 'Generously in summer, moderately in winter'],
    temp: ['16–28°C', '16–28°C', '16–28°C'],
    soil: ['Әмбебап бөлме топырағы', 'Универсальный грунт', 'Universal potting mix'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'sansevieria', category: CatalogCategory.indoor,
    latin: 'Dracaena trifasciata', family: 'Asparagaceae',
    name: ['Сансевиерия', 'Сансевиерия («щучий хвост»)', 'Snake plant'],
    description: [
      'Тік өсетін, қатты, жолақты жапырақты сукулент. Ең шыдамды бөлме өсімдіктерінің бірі.',
      'Суккулент с прямыми жёсткими полосатыми листьями. Одно из самых выносливых комнатных растений.',
      'A succulent with upright, stiff, banded leaves. One of the toughest houseplants.',
    ],
    kyzylorda: [
      'Ыстыққа, құрғақшылыққа және жарықтың аздығына төзеді; тек шамадан тыс суарудан қорқады.',
      'Выносит жару, засуху и нехватку света; боится только перелива.',
      'Tolerates heat, drought and low light; only overwatering harms it.',
    ],
    light: ['Кез келген: күннен көлеңкеге дейін', 'Любое: от солнца до полутени', 'Any: from sun to shade'],
    water: ['2–3 аптада бір рет, қыста сирегірек', 'Раз в 2–3 недели, зимой реже', 'Every 2–3 weeks, less in winter'],
    temp: ['15–30°C', '15–30°C', '15–30°C'],
    soil: ['Сукулентке арналған құмды', 'Песчаный грунт для суккулентов', 'Sandy succulent mix'],
    toxicity: ['Мысық пен итке аздап уытты', 'Слаботоксична для кошек и собак', 'Mildly toxic to cats and dogs'],
  ),
  CatalogPlant(
    id: 'kalanchoe', category: CatalogCategory.indoor,
    latin: 'Kalanchoe blossfeldiana', family: 'Crassulaceae',
    name: ['Каланхоэ', 'Каланхоэ Блоссфельда', 'Flaming Katy (Kalanchoe)'],
    description: [
      'Етжеңді жапырақты, қызыл, қызғылт, сары ұсақ гүлдері шоқ болып ашылатын сукулент. Қыс пен көктемде гүлдейді.',
      'Суккулент с мясистыми листьями и пышными шапками мелких красных, розовых или жёлтых цветков. Цветёт зимой и весной.',
      'A succulent with fleshy leaves and dense clusters of small red, pink or yellow flowers. Blooms in winter and spring.',
    ],
    kyzylorda: [
      'Құрғақ ауаға төзімді; жазғы аптапта терезеден сәл алыстатыңыз.',
      'Устойчиво к сухому воздуху; в летний зной отодвиньте от окна.',
      'Tolerates dry air; move it slightly away from the window in summer heat.',
    ],
    light: ['Жарық, таңертеңгі күн', 'Яркий свет, утреннее солнце', 'Bright light, morning sun'],
    water: ['Топырақ толық кепкенде', 'Когда почва полностью просохнет', 'When the soil is completely dry'],
    temp: ['15–25°C', '15–25°C', '15–25°C'],
    soil: ['Сукулентке арналған', 'Грунт для суккулентов', 'Succulent mix'],
    toxicity: ['Мысық пен итке уытты', 'Токсично для кошек и собак', 'Toxic to cats and dogs'],
  ),
  CatalogPlant(
    id: 'schlumbergera', category: CatalogCategory.indoor,
    latin: 'Schlumbergera truncata', family: 'Cactaceae',
    name: ['Декабрист (шлюмбергера)', 'Декабрист (шлюмбергера)', 'Christmas cactus'],
    description: [
      'Буынды жалпақ сабақты орман кактусы. Желтоқсан–қаңтарда қызғылт, қызыл немесе ақ гүлдермен гүлдейді.',
      'Лесной кактус с плоскими членистыми стеблями. Цветёт в декабре–январе розовыми, красными или белыми цветками.',
      'A forest cactus with flat, segmented stems. Blooms in December–January with pink, red or white flowers.',
    ],
    kyzylorda: [
      'Ыстықты жақтырмайды; күзде салқын жерде (15°C) ұстасаңыз, қыста мол гүлдейді.',
      'Не любит жару; если осенью держать в прохладе (15°C), зимой обильно цветёт.',
      'Dislikes heat; keep it cool (15°C) in autumn for abundant winter flowers.',
    ],
    light: ['Шашыраңқы жарық', 'Рассеянный свет', 'Indirect light'],
    water: ['Үстіңгі қабат кепкенде, гүлдегенде жиірек', 'При подсыхании верхнего слоя, во время цветения чаще', 'When the top layer dries; more often while flowering'],
    temp: ['15–22°C', '15–22°C', '15–22°C'],
    soil: ['Жеңіл, қышқылдау, дренажы бар', 'Лёгкая, слабокислая, с дренажом', 'Light, slightly acidic, well-drained'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'spathiphyllum', category: CatalogCategory.indoor,
    latin: 'Spathiphyllum wallisii', family: 'Araceae',
    name: ['Спатифиллум', 'Спатифиллум («женское счастье»)', 'Peace lily'],
    description: [
      'Қою жасыл жапырақты, ақ жамылғылы гүлі бар көлеңкеге төзімді өсімдік. Су жетіспегенде жапырағын салбыратып «белгі береді».',
      'Теневыносливое растение с тёмно-зелёными листьями и белыми покрывалами соцветий. При нехватке воды опускает листья, подавая сигнал.',
      'A shade-tolerant plant with dark-green leaves and white spathes. It droops visibly when it needs water.',
    ],
    kyzylorda: [
      'Құрғақ ауада жапырақ ұштары қурайды — жиі бүркіп, ылғал керамзит үстіне қойыңыз.',
      'В сухом воздухе сохнут кончики листьев — чаще опрыскивайте, ставьте на влажный керамзит.',
      'Leaf tips brown in dry air — mist often and stand the pot on wet pebbles.',
    ],
    light: ['Жартылай көлеңке, тікелей күнсіз', 'Полутень, без прямого солнца', 'Partial shade, no direct sun'],
    water: ['Топырақты үнемі сәл ылғал ұстаңыз', 'Поддерживайте почву слегка влажной', 'Keep the soil slightly moist'],
    temp: ['18–27°C', '18–27°C', '18–27°C'],
    soil: ['Құнарлы, бос, қышқылдау', 'Питательная, рыхлая, слабокислая', 'Rich, loose, slightly acidic'],
    toxicity: ['Адамға және жануарларға уытты (кальций оксалаты)', 'Токсичен для людей и животных (оксалат кальция)', 'Toxic to people and pets (calcium oxalate)'],
  ),
  CatalogPlant(
    id: 'hibiscus', category: CatalogCategory.indoor,
    latin: 'Hibiscus rosa-sinensis', family: 'Malvaceae',
    name: ['Қытай раушаны (гибискус)', 'Китайская роза (гибискус)', 'Chinese hibiscus'],
    description: [
      'Ірі, ашық қызыл, қызғылт немесе сары гүлді бұта. Әр гүлі бір-екі күн ғана ашылады, бірақ жаңалары үздіксіз шығады.',
      'Кустарник с крупными яркими красными, розовыми или жёлтыми цветками. Каждый цветок живёт 1–2 дня, но новые появляются постоянно.',
      'A shrub with large bright red, pink or yellow flowers. Each flower lasts a day or two, but new ones keep coming.',
    ],
    kyzylorda: [
      'Жарық пен жылуды жақсы көреді — Қызылорданың күнді терезелеріне лайық; жазда жиі суарыңыз.',
      'Любит свет и тепло — подходит для солнечных окон Кызылорды; летом поливайте часто.',
      'Loves light and warmth — suits sunny Kyzylorda windows; water often in summer.',
    ],
    light: ['Жарық, біраз тікелей күн', 'Яркий свет, немного прямого солнца', 'Bright light, some direct sun'],
    water: ['Жазда мол, топырақ кеппеуі керек', 'Летом обильно, не допускать пересыхания', 'Generously in summer; do not let it dry out'],
    temp: ['18–30°C', '18–30°C', '18–30°C'],
    soil: ['Құнарлы, бос', 'Плодородная, рыхлая', 'Fertile, loose'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'crassula', category: CatalogCategory.indoor,
    latin: 'Crassula ovata', family: 'Crassulaceae',
    name: ['Ақша ағашы (крассула)', 'Денежное дерево (толстянка)', 'Jade plant (money tree)'],
    description: [
      'Тиын тәрізді етжеңді жапырақты, ағашқа ұқсас сукулент. Молшылықтың белгісі ретінде жиі сыйға тартылады.',
      'Древовидный суккулент с мясистыми листьями-«монетками». Часто дарят как символ достатка.',
      'A tree-like succulent with coin-shaped fleshy leaves. Often given as a symbol of prosperity.',
    ],
    kyzylorda: [
      'Ыстық пен құрғақ ауаға өте төзімді; ең бастысы — артық суармау.',
      'Очень устойчива к жаре и сухому воздуху; главное — не переливать.',
      'Very tolerant of heat and dry air; the main rule is not to overwater.',
    ],
    light: ['Күнді терезе', 'Солнечное окно', 'Sunny window'],
    water: ['Топырақ толық кепкенде, қыста айына 1 рет', 'При полном просыхании, зимой раз в месяц', 'When fully dry; monthly in winter'],
    temp: ['15–28°C', '15–28°C', '15–28°C'],
    soil: ['Сукулентке арналған құмды', 'Песчаный грунт для суккулентов', 'Sandy succulent mix'],
    toxicity: ['Мысық пен итке уытты', 'Токсична для кошек и собак', 'Toxic to cats and dogs'],
  ),

  // ===================== Бақша гүлдері =====================
  CatalogPlant(
    id: 'rose', category: CatalogCategory.garden,
    latin: 'Rosa', family: 'Rosaceae',
    name: ['Раушан', 'Роза', 'Rose'],
    description: [
      'Хош иісті, түрлі түсті гүлді тікенекті бұта — бақтардың «ханшайымы». Қызылорданың саябақтары мен аулаларында кеңінен отырғызылады.',
      'Колючий кустарник с ароматными цветками разных окрасок — «королева сада». Широко высаживается в парках и дворах Кызылорды.',
      'A thorny shrub with fragrant flowers in many colours — the “queen of the garden”. Widely planted in Kyzylorda parks and yards.',
    ],
    kyzylorda: [
      'Аптапта таңертең түбінен мол суару және мульча қажет; қыста түбін топырақпен үйіңіз.',
      'В зной нужен обильный утренний полив под корень и мульча; на зиму окучивайте.',
      'In the heat, water deeply at the base in the morning and mulch; hill up soil for winter.',
    ],
    light: ['Күнді орын (кемінде 6 сағат)', 'Солнечное место (не менее 6 часов)', 'Full sun (at least 6 hours)'],
    water: ['Аптасына 2–3 рет, түбінен', '2–3 раза в неделю под корень', '2–3 times a week at the base'],
    temp: ['Ыстыққа төзеді; қыста −20°C-қа дейін (жабумен)', 'Жаростойка; зимой до −20°C (с укрытием)', 'Heat-tolerant; down to −20°C in winter (covered)'],
    soil: ['Құнарлы саздақ, тұзы аз', 'Плодородный суглинок, малозасолённый', 'Fertile loam, low salinity'],
    toxicity: ['Уытты емес (тікенегі бар)', 'Нетоксична (есть шипы)', 'Non-toxic (thorny)'],
  ),
  CatalogPlant(
    id: 'tagetes', category: CatalogCategory.garden,
    latin: 'Tagetes erecta', family: 'Asteraceae',
    name: ['Барқытгүл (бархатцы)', 'Бархатцы (тагетес)', 'Marigold (Tagetes)'],
    description: [
      'Сары, сарғылт-қызыл гүлді, өзіне тән иісі бар біржылдық. Қызылорда гүлзарларында ең көп кездесетін гүлдердің бірі.',
      'Однолетник с жёлтыми и оранжевыми цветками и характерным запахом. Один из самых распространённых цветов на клумбах Кызылорды.',
      'An annual with yellow and orange flowers and a distinctive scent. One of the most common flowerbed plants in Kyzylorda.',
    ],
    kyzylorda: [
      'Аптапқа, құрғақшылыққа және сәл тұзды топыраққа шыдайды; зиянкестерді үркітеді.',
      'Выдерживает зной, засуху и слабозасолённые почвы; отпугивает вредителей.',
      'Withstands heat, drought and slightly saline soil; repels pests.',
    ],
    light: _fullSun,
    water: ['Қалыпты, аптасына 2 рет', 'Умеренно, 2 раза в неделю', 'Moderate, twice a week'],
    temp: ['20–35°C, аязға шыдамайды', '20–35°C, не переносит заморозков', '20–35°C; not frost-hardy'],
    soil: ['Кез келген, дренажы бар', 'Любая, с дренажом', 'Any, well-drained'],
    toxicity: ['Уытты емес; шырыны теріні тітіркендіруі мүмкін', 'Нетоксичны; сок может раздражать кожу', 'Non-toxic; sap may irritate skin'],
  ),
  CatalogPlant(
    id: 'petunia', category: CatalogCategory.garden,
    latin: 'Petunia × atkinsiana', family: 'Solanaceae',
    name: ['Петуния', 'Петуния', 'Petunia'],
    description: [
      'Құйғыш тәрізді түрлі түсті гүлдері бар біржылдық. Балкон жәшіктері мен аспалы кашпоға өте қолайлы.',
      'Однолетник с воронковидными цветками самых разных окрасок. Идеальна для балконных ящиков и подвесных кашпо.',
      'An annual with funnel-shaped flowers in many colours. Perfect for balcony boxes and hanging baskets.',
    ],
    kyzylorda: [
      'Ыстықта күнде кешке суарыңыз; солған гүлдерін алып тастасаңыз, күзге дейін гүлдейді.',
      'В жару поливайте ежедневно вечером; если удалять отцветшие цветки, цветёт до осени.',
      'Water every evening in the heat; deadhead it and it flowers until autumn.',
    ],
    light: _fullSun,
    water: ['Ыстықта күн сайын', 'В жару ежедневно', 'Daily in hot weather'],
    temp: ['18–32°C', '18–32°C', '18–32°C'],
    soil: ['Құнарлы, жеңіл', 'Плодородная, лёгкая', 'Fertile, light'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'portulaca', category: CatalogCategory.garden,
    latin: 'Portulaca grandiflora', family: 'Portulacaceae',
    name: ['Портулак (ірі гүлді семізот)', 'Портулак крупноцветковый', 'Moss rose (Portulaca)'],
    description: [
      'Жерге төселіп өсетін, етжеңді жапырақты, ашық түсті гүлдері күн шыққанда ашылатын біржылдық.',
      'Стелющийся однолетник с мясистыми листьями и яркими цветками, раскрывающимися на солнце.',
      'A low, spreading annual with fleshy leaves and bright flowers that open in the sun.',
    ],
    kyzylorda: [
      'Қызылорданың ыстығы мен құрғақ, құмды топырағына ең шыдамды гүлдердің бірі.',
      'Один из самых выносливых цветов для жары и сухих песчаных почв Кызылорды.',
      "One of the toughest flowers for Kyzylorda's heat and dry, sandy soils.",
    ],
    light: ['Толық күн (көлеңкеде гүлі ашылмайды)', 'Полное солнце (в тени цветки не раскрываются)', 'Full sun (flowers stay closed in shade)'],
    water: ['Сирек, топырақ кепкенде', 'Редко, когда почва просохнет', 'Rarely, when the soil is dry'],
    temp: ['20–40°C', '20–40°C', '20–40°C'],
    soil: ['Құмды, кедей', 'Песчаная, бедная', 'Sandy, poor'],
    toxicity: ['Үй жануарларына аздап уытты', 'Слаботоксичен для животных', 'Mildly toxic to pets'],
  ),
  CatalogPlant(
    id: 'zinnia', category: CatalogCategory.garden,
    latin: 'Zinnia elegans', family: 'Asteraceae',
    name: ['Цинния', 'Цинния изящная', 'Zinnia'],
    description: [
      'Ірі, ашық түсті себет гүлдері бар биік біржылдық. Кесуге жарамды, көбелектерді тартады.',
      'Высокий однолетник с крупными яркими соцветиями-корзинками. Хорош для срезки, привлекает бабочек.',
      'A tall annual with large bright flower heads. Great for cutting; attracts butterflies.',
    ],
    kyzylorda: [
      'Ыстық пен күнді жақсы көреді; ақ ұнтақ (мучнистая роса) ауруынан сақтау үшін түбінен суарыңыз.',
      'Любит жару и солнце; поливайте под корень, чтобы избежать мучнистой росы.',
      'Loves heat and sun; water at the base to avoid powdery mildew.',
    ],
    light: _fullSun,
    water: ['Аптасына 2–3 рет', '2–3 раза в неделю', '2–3 times a week'],
    temp: ['20–35°C', '20–35°C', '20–35°C'],
    soil: ['Құнарлы, дренажы бар', 'Плодородная, с дренажом', 'Fertile, well-drained'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'canna', category: CatalogCategory.garden,
    latin: 'Canna indica', family: 'Cannaceae',
    name: ['Канна', 'Канна', 'Canna lily'],
    description: [
      'Ірі жалпақ жапырақты, ашық қызыл, сарғылт, сары гүлді биік көпжылдық. Гүлзарға тропиктік көрініс береді.',
      'Высокий многолетник с крупными широкими листьями и яркими красными, оранжевыми, жёлтыми цветками. Придаёт клумбе тропический вид.',
      'A tall perennial with big broad leaves and bright red, orange or yellow flowers. Gives flowerbeds a tropical look.',
    ],
    kyzylorda: [
      'Ыстықты жақсы көреді, бірақ мол су керек; тамырсабағын күзде қазып алып, қыста салқын жерде сақтаңыз.',
      'Любит жару, но требует обильного полива; корневища осенью выкапывают и хранят зимой в прохладе.',
      'Loves heat but needs plenty of water; lift the rhizomes in autumn and store them cool over winter.',
    ],
    light: _fullSun,
    water: ['Мол, топырақ үнемі ылғал', 'Обильно, почва постоянно влажная', 'Generous; keep the soil moist'],
    temp: ['22–35°C, аязға шыдамайды', '22–35°C, не переносит морозов', '22–35°C; not frost-hardy'],
    soil: ['Құнарлы, ылғал', 'Плодородная, влажная', 'Rich, moist'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'calendula', category: CatalogCategory.garden,
    latin: 'Calendula officinalis', family: 'Asteraceae',
    name: ['Тырнақгүл (календула)', 'Календула (ноготки)', 'Pot marigold (Calendula)'],
    description: [
      'Сары-сарғылт гүлді, дәрілік қасиеті бар біржылдық. Гүлінен қабынуға қарсы тұнба мен май дайындалады.',
      'Однолетник с жёлто-оранжевыми цветками и лекарственными свойствами. Из цветков готовят противовоспалительные настои и мази.',
      'An annual with yellow-orange flowers and medicinal uses. Its flowers are made into anti-inflammatory teas and ointments.',
    ],
    kyzylorda: [
      'Салқынырақ көктем мен күзде жақсы гүлдейді; шілде аптабында гүлдеуі әлсірейді.',
      'Лучше всего цветёт прохладной весной и осенью; в июльский зной цветение ослабевает.',
      'Flowers best in the cooler spring and autumn; flowering slows in the July heat.',
    ],
    light: ['Күн немесе жартылай көлеңке', 'Солнце или полутень', 'Sun or partial shade'],
    water: ['Қалыпты', 'Умеренно', 'Moderate'],
    temp: ['15–28°C', '15–28°C', '15–28°C'],
    soil: ['Кез келген бақша топырағы', 'Любая садовая почва', 'Any garden soil'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'chrysanthemum', category: CatalogCategory.garden,
    latin: 'Chrysanthemum × morifolium', family: 'Asteraceae',
    name: ['Хризантема', 'Хризантема', 'Chrysanthemum'],
    description: [
      'Күзде гүлдейтін, түрлі пішінді және түсті гүлдері бар көпжылдық. Қараша айына дейін гүлзарды безендіреді.',
      'Многолетник, цветущий осенью, с цветками самых разных форм и окрасок. Украшает клумбы вплоть до ноября.',
      'An autumn-flowering perennial with blooms in many shapes and colours. Brightens flowerbeds into November.',
    ],
    kyzylorda: [
      'Жазда мол суарыңыз; Қызылорданың ұзақ әрі жылы күзі хризантемаға өте қолайлы.',
      'Летом поливайте обильно; долгая тёплая осень Кызылорды отлично подходит хризантемам.',
      "Water well in summer; Kyzylorda's long, warm autumn suits chrysanthemums well.",
    ],
    light: ['Күнді орын', 'Солнечное место', 'Sunny spot'],
    water: ['Мол, топырақ кеппеуі керек', 'Обильно, не пересушивать', 'Generous; do not let it dry out'],
    temp: ['15–25°C, жеңіл аязға шыдайды', '15–25°C, выдерживает лёгкие заморозки', '15–25°C; tolerates light frost'],
    soil: ['Құнарлы, бос', 'Плодородная, рыхлая', 'Fertile, loose'],
    toxicity: ['Мысық пен итке уытты', 'Токсична для кошек и собак', 'Toxic to cats and dogs'],
  ),
  CatalogPlant(
    id: 'iris', category: CatalogCategory.garden,
    latin: 'Iris germanica', family: 'Iridaceae',
    name: ['Құртқашаш (ирис)', 'Ирис германский', 'Bearded iris'],
    description: [
      'Семсер тәрізді жапырақты, ірі «сақалды» гүлдері бар көпжылдық. Мамыр айында гүлдейді.',
      'Многолетник с мечевидными листьями и крупными «бородатыми» цветками. Цветёт в мае.',
      'A perennial with sword-shaped leaves and large bearded flowers. Blooms in May.',
    ],
    kyzylorda: [
      'Құрғақшылыққа төзімді; тамырсабағын терең көммеңіз, ауыр тұзды топыраққа құм қосыңыз.',
      'Засухоустойчив; не заглубляйте корневище, в тяжёлую засолённую почву добавляйте песок.',
      "Drought-tolerant; don't bury the rhizome deep, and add sand to heavy, saline soil.",
    ],
    light: _fullSun,
    water: ['Сирек, гүлдеуге дейін қалыпты', 'Редко, до цветения умеренно', 'Sparingly; moderate before flowering'],
    temp: ['Суыққа да, ыстыққа да төзімді', 'Морозо- и жаростоек', 'Frost- and heat-hardy'],
    soil: ['Жеңіл, су тоқтамайтын', 'Лёгкая, без застоя воды', 'Light, free-draining'],
    toxicity: ['Тамырсабағы уытты', 'Корневище ядовито', 'The rhizome is toxic'],
  ),
  CatalogPlant(
    id: 'lilac', category: CatalogCategory.garden,
    latin: 'Syringa vulgaris', family: 'Oleaceae',
    name: ['Сирень', 'Сирень обыкновенная', 'Common lilac'],
    description: [
      'Көктемде хош иісті күлгін немесе ақ шоқ гүлдермен гүлдейтін бұта. Аулалар мен саябақтардың дәстүрлі өсімдігі.',
      'Кустарник, весной цветущий ароматными сиреневыми или белыми кистями. Традиционное растение дворов и парков.',
      'A shrub that bears fragrant lilac or white flower clusters in spring. A classic of yards and parks.',
    ],
    kyzylorda: [
      'Құрғақшылық пен аязға төзімді; ыстық жазда айына 2–3 рет терең суарыңыз.',
      'Засухо- и морозоустойчива; в жаркое лето поливайте глубоко 2–3 раза в месяц.',
      'Drought- and frost-hardy; water deeply 2–3 times a month in hot summers.',
    ],
    light: ['Күнді орын', 'Солнечное место', 'Sunny spot'],
    water: ['Қалыпты, жазда терең суару', 'Умеренно, летом глубокий полив', 'Moderate; deep watering in summer'],
    temp: ['−30°C-тан +40°C-қа дейін', 'От −30°C до +40°C', 'From −30°C to +40°C'],
    soil: ['Бейтарап не сілтілі, құнарлы', 'Нейтральная или щелочная, плодородная', 'Neutral to alkaline, fertile'],
    toxicity: _nonToxic,
  ),

  // ===================== Жергілікті табиғи өсімдіктер =====================
  CatalogPlant(
    id: 'saxaul', category: CatalogCategory.native,
    latin: 'Haloxylon ammodendron', family: 'Amaranthaceae',
    name: ['Сексеуіл', 'Саксаул', 'Saxaul'],
    description: [
      'Қызылқұм мен Арал маңы шөлдерінің негізгі ағашы. Тамыры 10 метрден тереңге кетіп, құмды бекітеді.',
      'Главное дерево пустынь Кызылкума и Приаралья. Корни уходят глубже 10 м и закрепляют пески.',
      'The key tree of the Kyzylkum and Aral deserts. Its roots reach deeper than 10 m and hold the sand in place.',
    ],
    kyzylorda: [
      'Арал теңізінің құрғаған түбінде тұзды шаңды тоқтату үшін жаппай отырғызылады.',
      'Массово высаживается на осушенном дне Аральского моря, чтобы остановить солевые пыльные бури.',
      'Planted on a large scale on the dried Aral Sea bed to stop salty dust storms.',
    ],
    light: _fullSun,
    water: ['Тамыр алғаннан кейін суаруды қажет етпейді', 'После приживания полив не нужен', 'No watering once established'],
    temp: ['−40°C-тан +50°C-қа дейін', 'От −40°C до +50°C', 'From −40°C to +50°C'],
    soil: ['Құмды, тұзды', 'Песчаная, засолённая', 'Sandy, saline'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'tamarix', category: CatalogCategory.native,
    latin: 'Tamarix ramosissima', family: 'Tamaricaceae',
    name: ['Жыңғыл', 'Тамарикс (гребенщик)', 'Tamarisk (salt cedar)'],
    description: [
      'Қабыршақ тәрізді ұсақ жапырақты, қызғылт шашақ гүлдері бар бұта. Сырдария аңғарында кең тараған.',
      'Кустарник с мелкими чешуевидными листьями и розовыми метёлками цветков. Широко распространён в долине Сырдарьи.',
      'A shrub with tiny scale-like leaves and pink feathery flower plumes. Widespread in the Syr Darya valley.',
    ],
    kyzylorda: [
      'Тұзды топыраққа өте төзімді: артық тұзды жапырағы арқылы шығарады. Жол мен арна жағалауын бекітуге қолданылады.',
      'Очень солеустойчив: выводит избыток соли через листья. Используется для закрепления обочин и берегов каналов.',
      'Extremely salt-tolerant — it excretes excess salt through its leaves. Used to stabilise roadsides and canal banks.',
    ],
    light: _fullSun,
    water: ['Аз; жер асты суына жетеді', 'Мало; достаёт грунтовые воды', 'Little; taps groundwater'],
    temp: ['−30°C-тан +45°C-қа дейін', 'От −30°C до +45°C', 'From −30°C to +45°C'],
    soil: ['Тұзды, сортаң, құмды', 'Засолённая, солончаковая, песчаная', 'Saline, sandy'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'alhagi', category: CatalogCategory.native,
    latin: 'Alhagi maurorum', family: 'Fabaceae',
    name: ['Жантақ', 'Верблюжья колючка', 'Camelthorn'],
    description: [
      'Тікенекті, қызғылт гүлді шөл бұташығы. Тамыры 15–20 метр тереңдікке дейін кетеді; түйенің сүйікті азығы.',
      'Колючий пустынный полукустарник с розовыми цветками. Корни уходят на 15–20 м; любимый корм верблюдов.',
      'A spiny desert subshrub with pink flowers. Its roots reach 15–20 m deep; a favourite food of camels.',
    ],
    kyzylorda: [
      'Қызылорда даласы мен сортаңдарында кең тараған; халық емінде шайы асқазанға пайдалы деп саналады.',
      'Широко распространена в степях и на солончаках Кызылорды; в народной медицине чай из неё считают полезным для желудка.',
      "Common on Kyzylorda's steppes and salt flats; in folk medicine its tea is used for digestion.",
    ],
    light: _fullSun,
    water: ['Суаруды қажет етпейді', 'Полив не нужен', 'No watering needed'],
    temp: ['Аптап пен аязға төзімді', 'Выносит зной и мороз', 'Withstands heat and frost'],
    soil: ['Тұзды, құрғақ', 'Засолённая, сухая', 'Saline, dry'],
    toxicity: ['Уытты емес (тікенегі өткір)', 'Нетоксична (острые колючки)', 'Non-toxic (sharp spines)'],
  ),
  CatalogPlant(
    id: 'licorice', category: CatalogCategory.native,
    latin: 'Glycyrrhiza glabra', family: 'Fabaceae',
    name: ['Мия', 'Солодка голая (лакрица)', 'Liquorice'],
    description: [
      'Тамыры тәтті, дәрілік көпжылдық шөп. Тамырынан жөтелге қарсы дәрі мен тағам қоспалары жасалады.',
      'Многолетняя лекарственная трава со сладким корнем. Из корня делают средства от кашля и пищевые добавки.',
      'A medicinal perennial herb with a sweet root. The root is used in cough remedies and food flavourings.',
    ],
    kyzylorda: [
      'Сырдария жайылмасында қалың өседі; Қызылорда облысы — мия тамырын дайындаудың негізгі өңірлерінің бірі.',
      'Образует заросли в пойме Сырдарьи; Кызылординская область — один из главных районов заготовки солодкового корня.',
      'Forms thickets on the Syr Darya floodplain; Kyzylorda region is one of the main liquorice-root harvesting areas.',
    ],
    light: _fullSun,
    water: ['Жер асты суы жақын жерлерде өседі', 'Растёт там, где близко грунтовые воды', 'Grows where groundwater is near'],
    temp: ['Ыстыққа және аязға төзімді', 'Жаро- и морозостойка', 'Heat- and frost-hardy'],
    soil: ['Аллювийлі, сәл тұзды', 'Аллювиальная, слабозасолённая', 'Alluvial, slightly saline'],
    toxicity: ['Көп мөлшерде қан қысымын көтереді', 'В больших дозах повышает давление', 'Raises blood pressure in large amounts'],
  ),
  CatalogPlant(
    id: 'calligonum', category: CatalogCategory.native,
    latin: 'Calligonum', family: 'Polygonaceae',
    name: ['Жүзгін', 'Джузгун (кандым)', 'Calligonum (joozgun)'],
    description: [
      'Жапырағы жоқтың қасы құм бұтасы — фотосинтезді жасыл бұтақтары жасайды. Түкті, түрлі түсті жемістері әдемі.',
      'Песчаный кустарник почти без листьев — фотосинтез идёт в зелёных веточках. Красивы опушённые разноцветные плоды.',
      'A sand-dune shrub with almost no leaves — its green twigs do the photosynthesis. Its bristly, colourful fruits are striking.',
    ],
    kyzylorda: [
      'Қызылқұмның жылжымалы құмдарын бекітеді; ыстық пен құрғақшылыққа өте төзімді.',
      'Закрепляет подвижные пески Кызылкума; исключительно устойчив к жаре и засухе.',
      'Stabilises the shifting sands of the Kyzylkum; extremely heat- and drought-resistant.',
    ],
    light: _fullSun,
    water: ['Суаруды қажет етпейді', 'Полив не нужен', 'No watering needed'],
    temp: ['+50°C-қа дейін', 'До +50°C', 'Up to +50°C'],
    soil: ['Құм', 'Песок', 'Sand'],
    toxicity: _nonToxic,
  ),
  CatalogPlant(
    id: 'elaeagnus', category: CatalogCategory.native,
    latin: 'Elaeagnus angustifolia', family: 'Elaeagnaceae',
    name: ['Жиде', 'Лох узколистный (джида)', 'Russian olive'],
    description: [
      'Күмістей жапырақты, мамырда хош иісті сары гүлдейтін ағаш. Тәтті-ұнтақты жемісі жеуге жарамды.',
      'Дерево с серебристыми листьями и ароматными жёлтыми цветками в мае. Сладковато-мучнистые плоды съедобны.',
      'A tree with silvery leaves and fragrant yellow flowers in May. Its sweet, mealy fruits are edible.',
    ],
    kyzylorda: [
      'Тұзды топыраққа, ыстық пен құрғақшылыққа төзімді — Қызылорда аулаларында және жол бойындағы орман белдеулерінде көп.',
      'Солеустойчив, выносит жару и засуху — часто встречается во дворах Кызылорды и в придорожных лесополосах.',
      'Tolerates saline soil, heat and drought — common in Kyzylorda yards and roadside shelterbelts.',
    ],
    light: _fullSun,
    water: ['Аз, жас кезінде жиірек', 'Мало, в молодости чаще', 'Little; more when young'],
    temp: ['−30°C-тан +45°C-қа дейін', 'От −30°C до +45°C', 'From −30°C to +45°C'],
    soil: ['Кез келген, тұзды да болады', 'Любая, в том числе засолённая', 'Any, including saline'],
    toxicity: _nonToxic,
  ),
];

/// Көрсетілетін анықтамалық: тек нақты фотосы бар өсімдіктер.
final List<CatalogPlant> catalog =
    _all.where((c) => c.image != null).toList(growable: false);
