import 'package:beat_pads/screen_beat_pads/pads_and_controls.dart';
import 'package:beat_pads/screen_midi_devices/_drawer_devices.dart';
import 'package:beat_pads/services/services.dart';
import 'package:flutter/material.dart';

class BeatPadsScreen extends StatelessWidget {
  const BeatPadsScreen();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(
          Duration(milliseconds: Timing.screenTransitionTime), () async {
        final bool result = await DeviceUtils.landscapeOnly();
        await Future<void>.delayed(
          Duration(milliseconds: Timing.screenTransitionTime),
        );
        return result;
      }),
      builder: (context, AsyncSnapshot<bool?> done) {
        if (done.data == false || done.data == null) {
          return const Scaffold(body: SizedBox.expand());
        }
        return const Scaffold(
          body: SafeArea(
            child: BeatPadsAndControls(
              preview: false,
            ),
          ),
          drawer: Drawer(
            child: MidiConfig(),
          ),
        );
      },
    );
  }
}
