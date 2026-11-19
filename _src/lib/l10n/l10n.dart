/// Үш тіл: қазақша / русский / English.
/// tr('кілт') — кез келген жерден (build, callback, логика) шақыруға болады.
/// Тіл ауысқанда MaterialApp кілті өзгеріп, бүкіл интерфейс қайта сызылады.
library;

enum Lang { kk, ru, en }

extension LangX on Lang {
  String get code => name;
  String get label => const ['Қазақша', 'Русский', 'English'][index];

  /// ЖИ-ге жауап тілін көрсету үшін.
  String get aiName => const ['Kazakh', 'Russian', 'English'][index];

  static Lang parse(String? code) =>
      Lang.values.firstWhere((l) => l.code == code, orElse: () => Lang.kk);
}

class L10n {
  static Lang current = Lang.kk;

  static String t(String key, [Map<String, Object?> args = const {}]) {
    var v = _t[key]?[current.index] ?? key;
    args.forEach((k, a) => v = v.replaceAll('{$k}', '$a'));
    return v;
  }

  static bool has(String key) => _t.containsKey(key);
  static Iterable<String> get keys => _t.keys;
  static List<String>? raw(String key) => _t[key];

  static const Map<String, List<String>> _t = {
    // --- навигация
    'nav.home': ['Басты бет', 'Главная', 'Home'],
    'nav.plants': ['Өсімдіктер', 'Растения', 'Plants'],
    'nav.scan': ['Сканер', 'Сканер', 'Scan'],
    'nav.diary': ['Тарих', 'История', 'History'],
    'nav.profile': ['Профиль', 'Профиль', 'Profile'],

    // --- жалпы
    'common.cancel': ['Болдырмау', 'Отмена', 'Cancel'],
    'common.delete': ['Жою', 'Удалить', 'Delete'],
    'common.retry': ['Қайталау', 'Повторить', 'Retry'],
    'common.all': ['Барлығы', 'Все', 'All'],

    // --- күйлер
    'status.healthy': ['Дені сау', 'Здорово', 'Healthy'],
    'status.warning': ['Назар аудару керек', 'Требует внимания', 'Needs attention'],
    'status.critical': ['Қауіпті жағдай', 'Критическое состояние', 'Critical'],
    'status.none': ['Әлі тексерілмеген', 'Ещё не проверено', 'Not checked yet'],
    'status.noneShort': ['Тексерілмеген', 'Не проверено', 'Not checked'],
    'urgency.low': ['Шұғыл емес', 'Не срочно', 'Not urgent'],
    'urgency.medium': ['Жақын күндері', 'В ближайшие дни', 'Within days'],
    'urgency.high': ['Шұғыл әрекет қажет', 'Нужны срочные меры', 'Act now'],

    // --- күтім
    'care.light': ['Жарық', 'Свет', 'Light'],
    'care.watering': ['Суару', 'Полив', 'Watering'],
    'care.temperature': ['Температура', 'Температура', 'Temperature'],
    'care.humidity': ['Ылғалдылық', 'Влажность', 'Humidity'],
    'care.soil': ['Топырақ', 'Почва', 'Soil'],
    'care.fertilizer': ['Тыңайтқыш', 'Подкормка', 'Fertilizer'],

    // --- үрдіс, сұрыптау, кезең
    'trend.improving': ['Жақсарып келеді ↑', 'Улучшается ↑', 'Improving ↑'],
    'trend.worsening': ['Нашарлап барады ↓', 'Ухудшается ↓', 'Getting worse ↓'],
    'trend.stable': ['Тұрақты →', 'Стабильно →', 'Stable →'],
    'trend.insufficient': ['Салыстыру үшін кемінде 2 скан керек', 'Для сравнения нужно минимум 2 скана', 'At least 2 scans needed to compare'],
    'sort.prefix': ['Сұрыптау: {x}', 'Сортировка: {x}', 'Sort: {x}'],
    'sort.date': ['Күні', 'Дата', 'Date'],
    'sort.plant': ['Өсімдік атауы', 'Название', 'Plant name'],
    'sort.status': ['Күй (ауырлығы)', 'Состояние', 'Severity'],
    'sort.green': ['Жасыл үлесі', 'Доля зелёного', 'Green share'],
    'period.all': ['Барлық уақыт', 'За всё время', 'All time'],
    'period.7': ['Соңғы 7 күн', 'Последние 7 дней', 'Last 7 days'],
    'period.30': ['Соңғы 30 күн', 'Последние 30 дней', 'Last 30 days'],
    'order.desc': ['Кему ретімен', 'По убыванию', 'Descending'],
    'order.asc': ['Өсу ретімен', 'По возрастанию', 'Ascending'],

    // --- онбординг
    'onb.skip': ['Өткізіп жіберу', 'Пропустить', 'Skip'],
    'onb.next': ['Келесі', 'Далее', 'Next'],
    'onb.start': ['Бастау', 'Начать', 'Get started'],
    'onb.t1': ['Өсімдікті сканерлеңіз', 'Сканируйте растения', 'Scan your plants'],
    'onb.d1': ['Жапырақты суретке түсіріңіз — ЖИ оның жағдайын бағалайды', 'Сфотографируйте лист — ИИ оценит его состояние', 'Take a photo of a leaf — AI will assess its health'],
    'onb.t2': ['Өзгерістерді байқаңыз', 'Замечайте изменения', 'Track changes'],
    'onb.d2': ['Жапырақ түсін талдап, ауруды ерте анықтаңыз', 'Анализ цвета листа помогает заметить болезнь рано', 'Leaf colour analysis helps spot problems early'],
    'onb.t3': ['Тарихты сақтаңыз', 'Храните историю', 'Keep the history'],
    'onb.d3': ['Әр скан күнделікке сақталады, өзіңіз жоймайынша қалады', 'Каждый скан сохраняется в истории, пока вы его не удалите', 'Every scan stays in your history until you delete it'],

    // --- басты бет
    'home.greeting': ['Қайырлы күн!', 'Добрый день!', 'Good day!'],
    'home.title': ['Өсімдіктеріңіз қалай?', 'Как ваши растения?', 'How are your plants?'],
    'home.emptyTitle': ['Өсімдікті сканерлеңіз', 'Отсканируйте растение', 'Scan a plant'],
    'home.emptyText': ['Жапырақты суретке түсіріңіз — ЖИ оның жағдайын бағалайды. Скан тарихқа автоматты сақталады.', 'Сфотографируйте лист — ИИ оценит состояние. Скан автоматически сохранится в истории.', 'Photograph a leaf — AI will assess it. The scan is saved to your history automatically.'],
    'home.scanBtn': ['Фото сканерлеу', 'Сканировать фото', 'Scan a photo'],
    'home.addManual': ['Өсімдікті қолмен қосу', 'Добавить вручную', 'Add manually'],
    'home.addPlant': ['Өсімдік қосу', 'Добавить растение', 'Add plant'],
    'home.statTotal': ['Барлық өсімдік', 'Всего растений', 'Total plants'],
    'home.statHealthy': ['Дені сау', 'Здоровы', 'Healthy'],
    'home.statAttention': ['Назар аудару қажет', 'Требуют внимания', 'Need attention'],
    'home.recent': ['Соңғы скандар', 'Последние сканы', 'Recent scans'],
    'home.popular': ['Қызылордада танымал', 'Популярны в Кызылорде', 'Popular in Kyzylorda'],
    'home.seeAll': ['Барлығы', 'Все', 'See all'],
    'home.lastObs': ['Соңғы бақылау: {date}', 'Последний осмотр: {date}', 'Last check: {date}'],
    'home.noObs': ['Әлі бақылау жоқ', 'Осмотров пока нет', 'No checks yet'],

    // --- өсімдіктер
    'plants.title': ['Өсімдіктер', 'Растения', 'Plants'],
    'plants.tabMine': ['Менің өсімдіктерім', 'Мои растения', 'My plants'],
    'plants.tabCatalog': ['Анықтамалық', 'Справочник', 'Encyclopedia'],
    'plants.search': ['Өсімдікті іздеу...', 'Поиск растения...', 'Search plants...'],
    'plants.notFound': ['Өсімдік табылмады', 'Растения не найдены', 'No plants found'],
    'plants.emptyTitle': ['Әзірге өсімдік жоқ', 'Пока нет растений', 'No plants yet'],
    'plants.emptyText': ['Анықтамалықтан таңдаңыз немесе фото сканерлеңіз.', 'Выберите из справочника или отсканируйте фото.', 'Pick one from the encyclopedia or scan a photo.'],
    'plants.fromCatalog': ['Анықтамалықтан таңдау', 'Выбрать из справочника', 'Browse encyclopedia'],

    // --- анықтамалық
    'cat.title': ['Қызылорда облысының өсімдіктері', 'Растения Кызылординской области', 'Plants of Kyzylorda region'],
    'cat.subtitle': ['{n} өсімдік · фото, сипаттама, күтім', '{n} растений · фото, описание, уход', '{n} plants · photos, descriptions, care'],
    'cat.search': ['Анықтамалықтан іздеу...', 'Поиск в справочнике...', 'Search the encyclopedia...'],
    'cat.indoor': ['Бөлме', 'Комнатные', 'Indoor'],
    'cat.garden': ['Бақша', 'Садовые', 'Garden'],
    'cat.native': ['Жергілікті', 'Местные', 'Native'],
    'cat.indoorLong': ['Бөлме өсімдігі', 'Комнатное растение', 'Houseplant'],
    'cat.gardenLong': ['Бақша гүлі', 'Садовое растение', 'Garden plant'],
    'cat.nativeLong': ['Қызылорданың табиғи өсімдігі', 'Природное растение Кызылорды', 'Native to Kyzylorda'],
    'cat.latin': ['Латынша атауы', 'Латинское название', 'Latin name'],
    'cat.family': ['Тұқымдасы', 'Семейство', 'Family'],
    'cat.about': ['Сипаттама', 'Описание', 'Description'],
    'cat.inKyzylorda': ['Қызылорда жағдайында', 'В условиях Кызылорды', 'In Kyzylorda conditions'],
    'cat.care': ['Күтім талаптары', 'Уход', 'Care'],
    'cat.toxicity': ['Уыттылығы', 'Токсичность', 'Toxicity'],
    'cat.addToMine': ['Менің өсімдіктеріме қосу', 'Добавить в мои растения', 'Add to my plants'],
    'cat.alreadyMine': ['Менің өсімдіктерімде бар — ашу', 'Уже в моих растениях — открыть', 'Already in my plants — open'],
    'cat.added': ['Өсімдік қосылды', 'Растение добавлено', 'Plant added'],
    'cat.photo': ['Фото: {author} · {license} · Wikimedia Commons', 'Фото: {author} · {license} · Wikimedia Commons', 'Photo: {author} · {license} · Wikimedia Commons'],
    'cat.notFound': ['Ештеңе табылмады', 'Ничего не найдено', 'Nothing found'],
    'cat.match': ['Анықтамалықта: {name}', 'В справочнике: {name}', 'In encyclopedia: {name}'],

    // --- өсімдік қосу
    'add.title': ['Жаңа өсімдік қосу', 'Новое растение', 'New plant'],
    'add.name': ['Өсімдіктің атауы *', 'Название растения *', 'Plant name *'],
    'add.nameHint': ['Мысалы, Фикус', 'Например, Фикус', 'e.g. Ficus'],
    'add.species': ['Өсімдік түрі', 'Вид растения', 'Species'],
    'add.location': ['Орналасқан жері', 'Где стоит', 'Location'],
    'add.locationHint': ['Қонақ бөлме, терезе жанында...', 'Гостиная, у окна...', 'Living room, by the window...'],
    'add.save': ['Сақтау', 'Сохранить', 'Save'],
    'add.saving': ['Сақталуда...', 'Сохранение...', 'Saving...'],
    'add.saved': ['Өсімдік сақталды', 'Растение сохранено', 'Plant saved'],

    // --- сканер
    'scan.title': ['Өсімдікті сканерлеу', 'Сканирование растения', 'Scan a plant'],
    'scan.subtitle': ['Жапырақты суретке түсіріңіз — ЖИ жағдайын бағалайды', 'Сфотографируйте лист — ИИ оценит состояние', 'Photograph a leaf — AI will assess its condition'],
    'scan.pick': ['Фото түсіру немесе таңдау', 'Сделать или выбрать фото', 'Take or choose a photo'],
    'scan.formats': ['JPG, PNG, WEBP · 10 МБ дейін', 'JPG, PNG, WEBP · до 10 МБ', 'JPG, PNG, WEBP · up to 10 MB'],
    'scan.camera': ['Камерадан', 'Камера', 'Camera'],
    'scan.gallery': ['Галереядан', 'Галерея', 'Gallery'],
    'scan.plant': ['Өсімдік', 'Растение', 'Plant'],
    'scan.plantHint': ['(міндетті емес — ЖИ-ге контекст)', '(необязательно — подсказка для ИИ)', '(optional — context for AI)'],
    'scan.none': ['— Таңдалмаған —', '— Не выбрано —', '— Not selected —'],
    'scan.btn': ['Сканерлеу', 'Сканировать', 'Scan'],
    'scan.busy': ['Сканерленуде...', 'Сканирование...', 'Scanning...'],
    'scan.hintPick': ['Алдымен фото таңдаңыз', 'Сначала выберите фото', 'Choose a photo first'],
    'scan.hintReady': ['Талдауды FloraCare ЖИ жасайды', 'Анализ выполняет ИИ FloraCare', 'Analysis by FloraCare AI'],
    'scan.aiOff': ['ЖИ қызметі қолжетімсіз', 'Сервис ИИ недоступен', 'AI service unavailable'],
    'scan.result': ['Талдау нәтижесі', 'Результат анализа', 'Analysis result'],
    'scan.saved': ['Скан тарихқа сақталды', 'Скан сохранён в истории', 'Scan saved to history'],
    'scan.assignTitle': ['Қай өсімдікке тіркеу?', 'К какому растению привязать?', 'Attach to which plant?'],
    'scan.newPlant': ['＋ Жаңа өсімдік қосу', '＋ Новое растение', '＋ New plant'],
    'scan.newName': ['Жаңа өсімдік атауы', 'Название нового растения', 'New plant name'],
    'scan.speciesAi': ['Түрі (ЖИ анықтады): {s}', 'Вид (определил ИИ): {s}', 'Species (by AI): {s}'],
    'scan.note': ['Жазба (міндетті емес)...', 'Заметка (необязательно)...', 'Note (optional)...'],
    'scan.assignBtn': ['Өсімдікке тіркеу', 'Привязать к растению', 'Attach to plant'],
    'scan.assigned': ['Өсімдікке тіркелді', 'Привязано к растению', 'Attached to plant'],
    'scan.newScan': ['Жаңа скан', 'Новый скан', 'New scan'],
    'scan.disclaimer': ['ЖИ бағасы — көмекші ақпарат, дәл фитопатологиялық диагноз емес. Жақсы нәтиже үшін жапырақты жарық жерде, кадр ортасында түсіріңіз.', 'Оценка ИИ — вспомогательная информация, а не точный диагноз. Для лучшего результата снимайте лист при хорошем свете, по центру кадра.', 'The AI assessment is guidance, not an exact diagnosis. For best results, photograph the leaf in good light, centred in the frame.'],

    // --- камера
    'cam.title': ['Фото түсіру', 'Сделать фото', 'Take a photo'],
    'cam.starting': ['Камера қосылуда…', 'Камера запускается…', 'Starting the camera…'],
    'cam.switch': ['Камераны ауыстыру', 'Сменить камеру', 'Switch camera'],
    'cam.denied': ['Камераға рұқсат берілмеді. Браузер/жүйе параметрлерінен рұқсат беріңіз немесе галереядан таңдаңыз.', 'Доступ к камере не разрешён. Разрешите его в настройках браузера или системы либо выберите фото из галереи.', 'Camera access was denied. Allow it in your browser or system settings, or pick a photo from the gallery.'],
    'cam.none': ['Камера табылмады. Галереядан таңдаңыз.', 'Камера не найдена. Выберите фото из галереи.', 'No camera found. Pick a photo from the gallery instead.'],
    'cam.failed': ['Камераны қосу мүмкін болмады.', 'Не удалось включить камеру.', 'Could not start the camera.'],

    // --- ЖИ карточкасы
    'ai.analyzing': ['Сурет талдануда…', 'Анализ фото…', 'Analysing photo…'],
    'ai.usually': ['Әдетте 5–15 секунд', 'Обычно 5–15 секунд', 'Usually 5–15 seconds'],
    'ai.failed': ['Талдау орындалмады', 'Анализ не выполнен', 'Analysis failed'],
    'ai.tag': ['ЖИ талдауы', 'Анализ ИИ', 'AI analysis'],
    'ai.colorTitle': ['Жапырақ түсінің жіктелуі', 'Классификация цвета листа', 'Leaf colour classification'],
    'ai.green': ['Сау жасыл', 'Здоровый зелёный', 'Healthy green'],
    'ai.yellow': ['Сарғаю', 'Пожелтение', 'Yellowing'],
    'ai.brown': ['Қоңырлану', 'Побурение', 'Browning'],
    'ai.symptoms': ['Байқалған белгілер', 'Симптомы', 'Symptoms'],
    'ai.causes': ['Ықтимал себептер', 'Возможные причины', 'Likely causes'],
    'ai.advice': ['Не істеу керек', 'Что делать', 'What to do'],
    'ai.prognosis': ['Болжам', 'Прогноз', 'Prognosis'],
    'ai.confidence': ['Сенімділік {p}%', 'Уверенность {p}%', 'Confidence {p}%'],
    'ai.nextCheck': ['Келесі тексеру: {n} күннен кейін', 'Следующая проверка: через {n} дн.', 'Next check: in {n} days'],
    'ai.nextCheckDate': ['Келесі тексеру: {date}', 'Следующая проверка: {date}', 'Next check: {date}'],
    'ai.noPlant': ['Суретте өсімдік анық көрінбейді', 'Растение на фото плохо видно', 'No plant clearly visible in the photo'],
    'ai.plantInfo': ['Өсімдік туралы', 'О растении', 'About the plant'],
    'ai.care': ['Күтім талаптары', 'Уход', 'Care'],
    'ai.origin': ['Отаны', 'Родина', 'Origin'],
    'ai.funFact': ['Қызықты дерек', 'Интересный факт', 'Fun fact'],
    'ai.adviceTitle': ['ЖИ кеңесі', 'Совет ИИ', 'AI advice'],

    // --- тарих (күнделік)
    'diary.title': ['Скан тарихы', 'История сканов', 'Scan history'],
    'diary.search': ['Іздеу (атауы, жазба)...', 'Поиск (название, заметка)...', 'Search (name, note)...'],
    'diary.empty': ['Әзірге скан жоқ', 'Пока нет сканов', 'No scans yet'],
    'diary.deleteTitle': ['Сканды жою', 'Удалить скан', 'Delete scan'],
    'diary.deleteText': ['Бұл сканды тарихтан жою керек пе? Қайтару мүмкін емес.', 'Удалить этот скан из истории? Отменить нельзя.', 'Delete this scan from history? This cannot be undone.'],
    'diary.unassigned': ['Өсімдікке тіркелмеген', 'Не привязан к растению', 'Not attached'],
    'diary.assign': ['Тіркеу', 'Привязать', 'Attach'],

    // --- өсімдік беті
    'det.notFound': ['Өсімдік табылмады', 'Растение не найдено', 'Plant not found'],
    'det.about': ['Өсімдік туралы', 'О растении', 'About'],
    'det.location': ['Орналасқан жері', 'Где стоит', 'Location'],
    'det.added': ['Қосылған күні', 'Добавлено', 'Added'],
    'det.scans': ['Скан саны', 'Сканов', 'Scans'],
    'det.lastObs': ['Соңғы бақылау', 'Последний осмотр', 'Last check'],
    'det.trend': ['Үрдіс', 'Динамика', 'Trend'],
    'det.chart': ['Жасыл үлесінің өзгеруі', 'Изменение доли зелёного', 'Green share over time'],
    'det.noAi': ['Әзірге ЖИ талдауы жоқ', 'Пока нет анализа ИИ', 'No AI analysis yet'],
    'det.history': ['Скан тарихы', 'История сканов', 'Scan history'],
    'det.newScan': ['Жаңа скан', 'Новый скан', 'New scan'],
    'det.delete': ['Өсімдікті жою', 'Удалить растение', 'Delete plant'],
    'det.deleteText': ['Өсімдік және оның барлық скандары жойылады. Жалғастырасыз ба?', 'Растение и все его сканы будут удалены. Продолжить?', 'The plant and all its scans will be deleted. Continue?'],

    // --- профиль
    'prof.title': ['Менің профилім', 'Мой профиль', 'My profile'],
    'prof.defaultName': ['Пайдаланушы', 'Пользователь', 'User'],
    'prof.editName': ['Атыңыз', 'Ваше имя', 'Your name'],
    'prof.role': ['Өсімдік сүйер', 'Любитель растений', 'Plant lover'],
    'prof.statPlants': ['Өсімдік', 'Растений', 'Plants'],
    'prof.statScans': ['Скан', 'Сканов', 'Scans'],
    'prof.statHealthy': ['Дені сау', 'Здоровы', 'Healthy'],
    'prof.dark': ['Қараңғы тақырып', 'Тёмная тема', 'Dark theme'],
    'prof.privacy': ['Құпиялылық', 'Конфиденциальность', 'Privacy'],
    'prof.privacyToast': ['Аккаунт қажет емес. Фото тек талдау кезінде ЖИ қызметіне жіберіледі; тарих пен фотолар құрылғыңызда қалады.', 'Аккаунт не нужен. Фото отправляется в сервис ИИ только для анализа; история и фото остаются на устройстве.', 'No account needed. Photos are sent to the AI service only for analysis; history and photos stay on your device.'],
    'prof.lang': ['Тіл', 'Язык', 'Language'],
    'prof.chooseLang': ['Тілді таңдаңыз', 'Выберите язык', 'Choose language'],
    'prof.about': ['Қосымша туралы', 'О приложении', 'About'],
    'prof.save': ['Сақтау', 'Сохранить', 'Save'],

    // --- қателер
    'err.nameRequired': ['Өсімдік атауын енгізіңіз.', 'Введите название растения.', 'Enter a plant name.'],
    'err.nameTooLong': ['Атау 60 таңбадан аспауы керек.', 'Название — не более 60 символов.', 'Name must be at most 60 characters.'],
    'err.noteTooLong': ['Жазба 500 таңбадан аспауы керек.', 'Заметка — не более 500 символов.', 'Note must be at most 500 characters.'],
    'err.photoFormat': ['Тек JPG, PNG немесе WEBP файлдарына рұқсат.', 'Допустимы только JPG, PNG или WEBP.', 'Only JPG, PNG or WEBP files are allowed.'],
    'err.photoEmpty': ['Фото бос немесе өлшемі анықталмады.', 'Фото пустое или размер не определён.', 'The photo is empty or its size is unknown.'],
    'err.photoTooBig': ['Файл тым үлкен (10 МБ-тан аспауы керек).', 'Файл слишком большой (до 10 МБ).', 'File is too large (max 10 MB).'],
    'err.imageBroken': ['Файл бұзылған немесе сурет емес.', 'Файл повреждён или это не изображение.', 'The file is damaged or not an image.'],
    'err.imageTooLarge': ['Сурет өлшемі тым үлкен (40 мегапиксельден аспауы керек).', 'Слишком большое изображение (до 40 Мп).', 'Image is too large (max 40 MP).'],
    'err.plantNotFound': ['Өсімдік табылмады.', 'Растение не найдено.', 'Plant not found.'],
    'err.pickFailed': ['Фото таңдау мүмкін болмады.', 'Не удалось выбрать фото.', 'Could not pick the photo.'],
    'err.processFailed': ['Фотоны өңдеу мүмкін болмады.', 'Не удалось обработать фото.', 'Could not process the photo.'],
    'err.selectPlant': ['Өсімдікті таңдаңыз.', 'Выберите растение.', 'Choose a plant.'],
    'err.ai.busy': ['Талдау сервері қазір жүктелген. Бірнеше секундтан кейін «Қайталау» басыңыз.', 'Сервер анализа сейчас перегружен. Нажмите «Повторить» через несколько секунд.', 'The analysis server is busy. Tap “Retry” in a few seconds.'],
    'err.ai.unavailable': ['ЖИ талдауы қазір қолжетімсіз. Кейінірек қайталаңыз.', 'Анализ ИИ сейчас недоступен. Попробуйте позже.', 'AI analysis is unavailable right now. Try again later.'],
    'err.ai.network': ['Серверге қосылу мүмкін болмады. Интернетті тексеріңіз.', 'Не удалось подключиться к серверу. Проверьте интернет.', 'Could not reach the server. Check your connection.'],
    'err.ai.key': ['ЖИ қызметінің кілті жарамсыз.', 'Неверный ключ сервиса ИИ.', 'The AI service key is invalid.'],
    'err.ai.format': ['ЖИ жауабының форматы күтілгендей емес.', 'Неожиданный формат ответа ИИ.', 'Unexpected AI response format.'],
    'err.ai.notConfigured': ['ЖИ қызметі баптаулмаған.', 'Сервис ИИ не настроен.', 'The AI service is not configured.'],
    'err.ai.badImage': ['Фото форматы дұрыс емес.', 'Неверный формат фото.', 'Invalid photo format.'],
  };
}

/// Қысқа шақыру.
String tr(String key, [Map<String, Object?> args = const {}]) => L10n.t(key, args);
