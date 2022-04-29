import 'package:beat_pads/services/_services.dart';
import 'package:beat_pads/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SustainButtonRect extends StatefulWidget {
  const SustainButtonRect({Key? key}) : super(key: key);

  @override
  State<SustainButtonRect> createState() => _SustainButtonRectState();
}

class _SustainButtonRectState extends State<SustainButtonRect> {
  final key = GlobalKey();
  bool sustainState = false;
  int? disposeChannel;

  bool notOnButtonRect(Offset touchPosition) {
    if (key.currentContext == null) return true;

    final RenderBox childRenderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Size childSize = childRenderBox.size;
    final Offset childPosition = childRenderBox.localToGlobal(Offset.zero);

    return touchPosition.dx < childPosition.dx ||
        touchPosition.dx > childPosition.dx + childSize.width ||
        touchPosition.dy < childPosition.dy ||
        touchPosition.dy > childPosition.dy + childSize.height;
  }

  @override
  void dispose() {
    if (disposeChannel != null && sustainState == true) {
      MidiUtils.sustainMessage(disposeChannel!, false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int channel = Provider.of<Settings>(context, listen: true).channel;
    disposeChannel = channel;
    double padSize = screenWidth * 0.005;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, padSize, padSize, padSize),
      child: Listener(
        onPointerDown: (_) {
          if (!sustainState) {
            MidiUtils.sustainMessage(channel, true);
            setState(() {
              sustainState = true;
            });
          }
        },
        onPointerUp: (touch) {
          if (!notOnButtonRect(touch.position)) {
            MidiUtils.sustainMessage(channel, false);
            if (mounted) {
              setState(() {
                sustainState = false;
              });
            }
          }
        },
        child: Container(
          key: key,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(screenWidth * 0.008)),
            color: sustainState
                ? Palette.lightPink.color
                : Palette.lightPink.color.withAlpha(120),
          ),
          child: RotatedBox(
            quarterTurns: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'Sustain',
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w500,
                  color: Palette.darkGrey.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
