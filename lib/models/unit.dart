class Unit {
  final String id;
  final int grade;
  final String title;
  final String description;
  final String assetPath;

  const Unit({
    required this.id,
    required this.grade,
    required this.title,
    required this.description,
    required this.assetPath,
  });
}

const units = <Unit>[
  // 中1 A 数と式
  Unit(
    id: 'seifu',
    grade: 1,
    title: '正負の数',
    description: '全30問(符号・大小比較・四則混合)',
    assetPath: 'assets/questions/grade1/seifu_no_kazu.json',
  ),
  Unit(
    id: 'moji',
    grade: 1,
    title: '文字式',
    description: '全25問(表し方・式の値・一次式の計算)',
    assetPath: 'assets/questions/grade1/moji_shiki.json',
  ),
  Unit(
    id: 'houteishiki',
    grade: 1,
    title: '方程式',
    description: '全28問(移項・かっこ・比例式・文章題)',
    assetPath: 'assets/questions/grade1/houteishiki.json',
  ),
  // 中1 B 図形
  Unit(
    id: 'heimen',
    grade: 1,
    title: '平面図形',
    description: '全26問(直線と角・作図と移動・おうぎ形)',
    assetPath: 'assets/questions/grade1/heimen_zukei.json',
  ),
  Unit(
    id: 'kukan',
    grade: 1,
    title: '空間図形',
    description: '全28問(立体・位置関係・表面積・体積)',
    assetPath: 'assets/questions/grade1/kukan_zukei.json',
  ),
  // 中1 C 関数
  Unit(
    id: 'hirei',
    grade: 1,
    title: '比例と反比例',
    description: '全27問(式・グラフ・利用)',
    assetPath: 'assets/questions/grade1/hirei_hanpirei.json',
  ),
  // 中1 D データの活用
  Unit(
    id: 'data',
    grade: 1,
    title: 'データの分布',
    description: '全26問(度数分布・代表値・相対度数)',
    assetPath: 'assets/questions/grade1/data_bunpu.json',
  ),
  Unit(
    id: 'kakuritsu1',
    grade: 1,
    title: '確率',
    description: '全18問(相対度数と確率)',
    assetPath: 'assets/questions/grade1/kakuritsu.json',
  ),
  // 中2 A 数と式
  Unit(
    id: 'shiki2',
    grade: 2,
    title: '式の計算',
    description: '全26問(多項式・単項式の計算・式の値・等式変形)',
    assetPath: 'assets/questions/grade2/shiki_no_keisan.json',
  ),
  Unit(
    id: 'renritsu',
    grade: 2,
    title: '連立方程式',
    description: '全26問(加減法・代入法・文章題)',
    assetPath: 'assets/questions/grade2/renritsu_houteishiki.json',
  ),
  // 中2 C 関数
  Unit(
    id: 'ichiji',
    grade: 2,
    title: '一次関数',
    description: '全28問(変化の割合・グラフ・式・利用)',
    assetPath: 'assets/questions/grade2/ichiji_kansu.json',
  ),
];
