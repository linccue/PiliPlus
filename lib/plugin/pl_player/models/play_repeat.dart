import 'package:PiliPlus/models/common/enum_with_label.dart';

enum PlayRepeat implements EnumWithLabel {
  pause('播完暂停'),
  listOrder('顺序播放'),
  singleCycle('单个循环'),
  listCycle('列表循环'),
  autoPlayRelated('自动连播'),
  custom('自定义 (稍后再看顺序，其余暂停)'), // <--- 新增这一行
  ;

  @override
  final String label;
  const PlayRepeat(this.label);
}
