import 'package:beat_pads/shared/_shared.dart';
import 'package:beat_pads/screen_home/_screen_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OctaveButtons extends StatelessWidget {
  const OctaveButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
      width: size.width * 0.08,
      child: FittedBox(
        child: Consumer<Settings>(
          builder: (context, settings, child) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      settings.baseOctave++;
                    },
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      primary: Palette.cadetBlue.color,
                      onPrimary: Palette.darkGrey.color,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      settings.baseOctave--;
                    },
                    child: Icon(
                      Icons.remove,
                      size: 30,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                      primary: Palette.laserLemon.color,
                      onPrimary: Palette.darkGrey.color,
                    ),
                  ),
                ]);
          },
        ),
      ),
    );
  }
}
