import 'package:beat_pads/services/_services.dart';
import 'package:beat_pads/services/paint_circle.dart';
import 'package:beat_pads/shared/colors.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaintAfterTouchCircle extends StatelessWidget {
  const PaintAfterTouchCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get Renderbox for gloabl to local offset conversion:
    final RenderBox? box = context.findAncestorRenderObjectOfType<RenderBox>();
    if (box == null) return Stack();

    return Consumer<MidiSender>(
      builder: (context, midiSender, child) {
        final buffer = midiSender.touchBuffer.buffer;

        return Stack(
          children: [
            ...buffer.map(
              (atCircle) {
                return Stack(
                  children: [
                    PaintCircle(
                      box.globalToLocal(atCircle.origin),
                      atCircle.maxRadius,
                      Palette.lightPink.color.withOpacity(
                          atCircle.radialChange(curve: Curves.easeOut) * 0.6),
                      stroke: false,
                    ),
                    PaintCircle(
                      box.globalToLocal(atCircle.origin),
                      atCircle.radialChange() * atCircle.maxRadius,
                      Palette.laserLemon.color.withOpacity(
                          atCircle.radialChange(curve: Curves.easeOut) * 0.8),
                      stroke: true,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}