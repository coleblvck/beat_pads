import 'package:beat_pads/services/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CHANNEL
final channelSettingProv = NotifierProvider<SettingIntNotifier, int>(() {
  return SettingIntNotifier(
    key: 'channel',
    defaultValue: 0,
    max: 15,
  );
});

final channelUsableProv = Provider<int>(
  (ref) {
    final int channel = ref.watch(channelSettingProv);

    if (ref.watch(layoutProv) != Layout.progrChange) {
      if (ref.watch(playModeProv) == PlayMode.mpe ||
          ref.watch(playModeProv) == PlayMode.mpeTargetPb) {
        return channel > 7 ? 15 : 0;
      }
    }

    return channel;
  },
);

final mpeMemberChannelsProv = NotifierProvider<SettingIntNotifier, int>(() {
  return SettingIntNotifier(
    key: 'mpeMemberChannels',
    defaultValue: 8,
    min: 1,
    max: 15,
  );
});

final zoneProv = Provider<bool>((ref) {
  final int channel = ref.watch(channelSettingProv);
  return channel > 7;
});

// VELOCITY
final velocityProv = NotifierProvider<SettingIntNotifier, int>(() {
  return SettingIntNotifier(
    key: 'velocity',
    defaultValue: 110,
    max: 127,
  );
});

final velocityModeProv =
    NotifierProvider<SettingEnumNotifier<VelocityMode>, VelocityMode>(() {
  return SettingEnumNotifier<VelocityMode>(
    nameMap: VelocityMode.values.asNameMap(),
    key: 'velocityMode',
    defaultValue: VelocityMode.fixed,
  );
});

final velocityMinProv = NotifierProvider<SettingIntNotifier, int>(() {
  return SettingIntNotifier(
    key: 'velocityMin',
    defaultValue: 100,
    max: 126,
  );
});

final velocityMaxProv = NotifierProvider<SettingIntNotifier, int>(() {
  return SettingIntNotifier(
    key: 'velocityMax',
    defaultValue: 110,
    max: 127,
  );
});

final velocityRangeProv = Provider<int>((ref) {
  return ref.watch(velocityMaxProv) - ref.watch(velocityMinProv);
});
final velocityCenterProv = Provider<double>((ref) {
  return (ref.watch(velocityMaxProv) + ref.watch(velocityMinProv)) / 2;
});
