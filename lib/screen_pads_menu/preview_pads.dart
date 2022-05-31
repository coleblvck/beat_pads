import 'package:beat_pads/screen_beat_pads/_screen_beat_pads.dart';
import 'package:beat_pads/services/services.dart';
import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  const Preview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.lightGrey,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: IgnorePointer(
            child: DeviceUtils.isPortrait(context)
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: BeatPadsScreen(preview: true),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        width: double.infinity,
                        child: FittedBox(
                          child: Text(
                            "Preview",
                            style: TextStyle(
                              color: Palette.lightGrey.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: BeatPadsScreen(preview: true),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        width: double.infinity,
                        child: FittedBox(
                          child: Text(
                            "Preview",
                            style: TextStyle(
                              color: Palette.lightGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}