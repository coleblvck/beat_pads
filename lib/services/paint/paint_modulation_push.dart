import 'package:beat_pads/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaintPushStyle extends ConsumerWidget {
  PaintPushStyle({super.key});

  final dirtyColor = Palette.dirtyTranslucent;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get Renderbox for gloabl to local offset conversion:
    final RenderBox? box = context.findAncestorRenderObjectOfType<RenderBox>();
    if (box == null) return const Stack();

    final midiSender = ref.watch(senderProvider);

    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        ...[
          ...midiSender.playModeHandler.touchReleaseBuffer.buffer,
          ...midiSender.playModeHandler.touchBuffer.buffer,
        ]
            .where(
          (element) =>
              element.directionalChangeUnclamped() >=
              const Offset(1, 1), // filter out smaller than 1 px events
        )
            .map(
          (touchEvent) {
            return CustomPaint(
              painter: CustomPaintPushOverlay(
                relativeMode: !touchEvent.leftInitialPad &&
                    ref.watch(mpeRelativeModeProv),
                screenSize: screenSize,
                pitchDeadzonePercent: ref.watch(pitchDeadzone),
                dirty: touchEvent.dirty,
                origin: box.globalToLocal(touchEvent.origin),
                originPadBox: PadBox(
                    padPosition:
                        box.globalToLocal(touchEvent.originPadBox.padPosition),
                    padSize: touchEvent.originPadBox.padSize),
                padBox: PadBox(
                    padPosition:
                        box.globalToLocal(touchEvent.newPadBox.padPosition),
                    padSize: touchEvent.newPadBox.padSize),
                change: box.globalToLocal(touchEvent.newPosition),
                colorX: touchEvent.dirty ? dirtyColor : Colors.white,
                colorY: touchEvent.dirty ? dirtyColor : Palette.lightGrey,
                // colorX: Colors.white,
                // colorY: Palette.lightGrey,
              ),
            );
          },
        ),
      ],
    );
  }
}
