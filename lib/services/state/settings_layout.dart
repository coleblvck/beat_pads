import 'package:beat_pads/main.dart';
import 'package:beat_pads/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// LAYOUT
final layoutProv = NotifierProvider<SettingEnum<Layout>, Layout>(() {
  return SettingEnum<Layout>(
    fromName: Layout.fromName,
    key: 'layout',
    defaultValue: Layout.majorThird,
  );
});

// NOTES AND OCTAVES
final rootProv = StateNotifierProvider<SettingInt, int>((ref) {
  ref.listen(layoutProv, (_, Layout next) {
    if (!next.props.resizable) {
      ref.read(sharedPrefProvider).settings.rootNote.reset();
    }
  });

  return ref.watch(sharedPrefProvider).settings.rootNote;
});

final baseProv = StateNotifierProvider<SettingInt, int>((ref) {
  return ref.watch(sharedPrefProvider).settings.base;
});

final baseNoteProv = Provider<int>(((ref) {
  return (ref.watch(baseOctaveProv) + 2) * 12 + ref.watch(baseProv);
}));

final baseOctaveProv = StateNotifierProvider<SettingInt, int>((ref) {
  return ref.watch(sharedPrefProvider).settings.baseOctave;
});

// GRID SIZE
final widthProv = StateNotifierProvider<SettingInt, int>((ref) {
  ref.listen(layoutProv, (_, Layout next) {
    if (next.props.defaultDimensions?.x != null) {
      ref
          .read(sharedPrefProvider)
          .settings
          .width
          .setAndSave(next.props.defaultDimensions!.x);
    }
  });
  return ref.watch(sharedPrefProvider).settings.width;
});
final heightProv = StateNotifierProvider<SettingInt, int>((ref) {
  ref.listen(layoutProv, (_, Layout next) {
    if (next.props.defaultDimensions?.y != null) {
      ref
          .read(sharedPrefProvider)
          .settings
          .height
          .setAndSave(next.props.defaultDimensions!.y);
    }
  });
  return ref.watch(sharedPrefProvider).settings.height;
});

final rowProv = Provider<List<List<CustomPad>>>(((ref) {
  return ref
      .watch(layoutProv)
      .getGrid(
        ref.watch(widthProv),
        ref.watch(heightProv),
        ref.watch(rootProv),
        ref.watch(baseNoteProv),
        ref.watch(scaleProv).intervals,
      )
      .rows;
}));

// LABELS AND COLOR
final padLabelsProv = NotifierProvider<SettingEnum<PadLabels>, PadLabels>(() {
  return SettingEnum<PadLabels>(
    fromName: PadLabels.fromName,
    key: "padLabels",
    defaultValue: PadLabels.note,
  );
});

final padColorsProv = NotifierProvider<SettingEnum<PadColors>, PadColors>(() {
  return SettingEnum<PadColors>(
    fromName: PadColors.fromName,
    key: "padColors",
    defaultValue: PadColors.highlightRoot,
  );
});

final baseHueProv = StateNotifierProvider<SettingInt, int>((ref) {
  return ref.watch(sharedPrefProvider).settings.baseHue;
});

// SCALES
final scaleProv = NotifierProvider<SettingEnum<Scale>, Scale>((ref) {
  ref.listen(layoutProv, (_, Layout next) {
    if (!next.props.resizable) {
      ref.read(sharedPrefProvider).settings.scale.reset();
    }
  });

  return ref.watch(sharedPrefProvider).settings.scale;
});

// BUTTONS AND SLIDERS
final octaveButtonsProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.octaveButtons;
});
final sustainButtonProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.sustainButton;
});
final velocitySliderProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.velocitySlider;
});
final modWheelProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.modWheel;
});

// PITCHBEND
final pitchBendProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.pitchBend;
});

final pitchBendEaseStepProv = StateNotifierProvider<SettingInt, int>((ref) {
  return ref.watch(sharedPrefProvider).settings.pitchBendEase;
});

final pitchBendEaseUsable = Provider<int>(
  (ref) {
    if (!ref.watch(pitchBendProv)) return 0;

    return Timing.releaseDelayTimes[ref
        .watch(pitchBendEaseStepProv)
        .clamp(0, Timing.releaseDelayTimes.length - 1)];
  },
);

// VELOCITY
final velocityVisualProv = StateNotifierProvider<SettingBool, bool>((ref) {
  return ref.watch(sharedPrefProvider).settings.velocityVisual;
});
