/// Анықтамалық фотоларының авторлары (Wikimedia Commons). Автоматты жасалған — credits.json.
library;

class PhotoCredit {
  final String file;
  final String author;
  final String license;
  final String source;
  const PhotoCredit(this.file, this.author, this.license, this.source);
}

const Map<String, PhotoCredit> catalogCredits = {
  'alhagi': PhotoCredit('alhagi.jpg', 'Eitan Ferman', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Camel_Thorn_flower.JPG'),
  'aloe': PhotoCredit('aloe.jpg', 'Collage by en:User:MidgleyDJ, original images from Wikimedia commons (Image:Aloe', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Aloe_vera_flower_inset.png'),
  'calendula': PhotoCredit('calendula.jpg', 'Betty Cai', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Calendula_officinalis,_pot_marigold.JPG'),
  'calligonum': PhotoCredit('calligonum.jpg', 'LRBurdak', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Calligonum_polygonoides.JPG'),
  'canna': PhotoCredit('canna.jpg', 'Muhammad Mahdi Karim, edited by Fir0002', 'GFDL 1.2', 'https://commons.wikimedia.org/wiki/File:Canna_sp.jpg'),
  'chlorophytum': PhotoCredit('chlorophytum.jpg', 'Hierbabuena_0611.JPG: Dtarazona', 'Public domain', 'https://commons.wikimedia.org/wiki/File:Hierbabuena_0611_Revised.jpg'),
  'chrysanthemum': PhotoCredit('chrysanthemum.jpg', 'Aruna at Malayalam Wikipedia', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Chrysanthemum.JPG'),
  'crassula': PhotoCredit('crassula.jpg', 'author is sannse.', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Crassula_ovata_700.jpg'),
  'elaeagnus': PhotoCredit('elaeagnus.jpg', 'Katrin Schneider / korina.info', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Korina_2012-05-15_Elaeagnus_angustifolia_1.jpg'),
  'ficus': PhotoCredit('ficus.jpg', 'B.navez', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ficus_elastica_leaves_02.JPG'),
  'hibiscus': PhotoCredit('hibiscus.jpg', 'Andy / Andrew Fogg from near Cambridge, UK', 'CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hibiscus_Brilliant.jpg'),
  'iris': PhotoCredit('iris.jpg', 'User:GinoMM', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Iris_Germanica_2012-2.jpg'),
  'kalanchoe': PhotoCredit('kalanchoe.jpg', 'বাক্যবাগীশ', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Kalanchoe_blossfeldiana_3.jpg'),
  'licorice': PhotoCredit('licorice.jpg', 'Krzysztof Ziarnek, Kenraiz', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Glycyrrhiza_glabra_kz01.jpg'),
  'lilac': PhotoCredit('lilac.jpg', 'Jjron', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Lilac_Flower%26Leaves,_SC,_Vic,_13.10.2007.jpg'),
  'pelargonium': PhotoCredit('pelargonium.jpg', 'Peter Warren', 'CC0', 'https://commons.wikimedia.org/wiki/File:Pelargonium_zonale_in_wild.jpg'),
  'petunia': PhotoCredit('petunia.jpg', 'Gabriel Collares', 'CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Pet%C3%BAnia_(do_tupi_petyma,_%27tabaco%27).jpg'),
  'portulaca': PhotoCredit('portulaca.jpg', 'Anshik Kumar Tiwari', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:PortulacaGrandiflora.jpg'),
  'rose': PhotoCredit('rose.jpg', 'Stan Shebs', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Rosa_rubiginosa_1.jpg'),
  'saintpaulia': PhotoCredit('saintpaulia.jpg', 'RobertoMM', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Saintpaulia_ionantha.jpg'),
  'sansevieria': PhotoCredit('sansevieria.jpg', 'Mokkie', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Snake_Plant_(Sansevieria_trifasciata_%27Laurentii%27).jpg'),
  'saxaul': PhotoCredit('saxaul.jpg', 'Wikimedia Commons', 'CC BY-SA 2.5', 'https://commons.wikimedia.org/wiki/File:Saxaul-baum.JPG'),
  'schlumbergera': PhotoCredit('schlumbergera.jpg', 'Cactus_de_noël.jpg: Empereur Day', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Cactus_de_no%C3%ABl_rev.jpg'),
  'spathiphyllum': PhotoCredit('spathiphyllum.jpg', 'JJ Harrison (https://www.jjharrison.com.au/)', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Spathiphyllum_cochlearispathum_RTBG.jpg'),
  'tagetes': PhotoCredit('tagetes.jpg', 'Wikimedia Commons', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Tagetes_x_erecta1.jpg'),
  'tamarix': PhotoCredit('tamarix.jpg', 'Jerzy Opioła', 'CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Tamarix_ramosissima_a2.jpg'),
  'zinnia': PhotoCredit('zinnia.jpg', 'Ermell', 'CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Zinnienbl%C3%BCte_Zinnia_elegans_stack15_20190722-RM-7222254.jpg'),
};
