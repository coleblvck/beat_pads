import 'package:beat_pads/screen_pads_menu/slider_int.dart';
import 'package:beat_pads/services/state/model_settings.dart';
import 'package:flutter/material.dart';
import 'package:beat_pads/services/services.dart';
import 'package:beat_pads/screen_pads_menu/slider_int_range.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuMidi extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Divider(),
          trailing: Text(
            "Midi Settings",
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline5!.fontSize),
          ),
        ),
        IntSliderTile(
          resetValue: settings.resetChannel,
          min: 1,
          max: 16,
          label: "Master Channel",
          subtitle:
              "Midi Channel to send and receive on. Only 1 or 16 with MPE.",
          trailing: Text((settings.channel + 1).toString()),
          setValue: (v) => settings.channel = v - 1,
          readValue: settings.channel + 1,
          onChangeEnd: settings.prefs.settings.channel.save,
        ),
        IntSliderTile(
          min: 1,
          max: 15,
          label: "MPE Member Channels",
          subtitle: "Number of member channels to allocate in MPE mode",
          trailing: Text(settings.upperZone
              ? "${settings.mpeMemberChannels} (${15 - settings.mpeMemberChannels} to 15)"
              : "${settings.mpeMemberChannels} (2 to ${settings.mpeMemberChannels + 1})"),
          setValue: (v) => settings.mpeMemberChannels = v,
          readValue: settings.mpeMemberChannels,
          onChangeEnd: settings.prefs.settings.mpeMemberChannels.save,
        ),
        const Divider(),
        ListTile(
          title: const Text("Random Velocity"),
          subtitle: const Text("Random Velocity within a given Range"),
          trailing: Switch(
              value: settings.randomVelocity,
              onChanged: (value) => settings.randomizeVelocity = value),
        ),
        if (!settings.randomVelocity)
          IntSliderTile(
            min: 10,
            max: 127,
            label: "Fixed Velocity",
            subtitle: "Velocity to send when pressing a Pad",
            trailing: Text(settings.velocity.toString()),
            readValue: settings.velocity,
            setValue: (v) => settings.setVelocity(v),
            resetValue: settings.resetVelocity,
            onChangeEnd: settings.prefs.settings.velocity.save,
          ),
        if (settings.randomVelocity)
          MidiRangeSelectorTile(
            label: "Random Velocity Range",
            readMin: settings.velocityMin,
            readMax: settings.velocityMax,
            setMin: (v) => settings.velocityMin = v,
            setMax: (v) => settings.velocityMax = v,
            resetFunction: settings.resetVelocity,
            onChangeEnd: settings.saveVelocityMinMax,
          ),
      ],
    );
  }
}
