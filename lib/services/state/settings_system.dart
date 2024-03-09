import 'package:beat_pads/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sliderTapAndSlideProv = NotifierProvider<SettingBoolNotifier, bool>(() {
  return SettingBoolNotifier(
    key: 'sliderTapAndSlide',
    defaultValue: true,
    resettable: false,
    usesPresets: false,
  );
});
