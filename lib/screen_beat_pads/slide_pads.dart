import 'package:beat_pads/screen_beat_pads/slide_pad.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';
import 'package:beat_pads/shared_components/_shared.dart';
import 'package:beat_pads/services/services.dart';

class SlidePads extends StatefulWidget {
  const SlidePads({Key? key}) : super(key: key);

  @override
  State<SlidePads> createState() => _SlidePadsState();
}

class _SlidePadsState extends State<SlidePads> with TickerProviderStateMixin {
  final GlobalKey _padsWidgetKey = GlobalKey();

  PlayMode? disposeMode;

  int? _detectTappedItem(PointerEvent event) {
    final BuildContext? context = _padsWidgetKey.currentContext;
    if (context == null) return null;

    final RenderBox? box = context.findAncestorRenderObjectOfType<RenderBox>();
    if (box == null) return null;

    final Offset localOffset = box.globalToLocal(event.position);
    final BoxHitTestResult results = BoxHitTestResult();

    if (box.hitTest(results, position: localOffset)) {
      for (final HitTestEntry<HitTestTarget> hit in results.path) {
        final HitTestTarget target = hit.target;
        if (target is TestProxyBox) {
          return target.index >= 0 && target.index < 128 ? target.index : null;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, Settings settings, _) {
        down(PointerEvent touch) {
          int? result = _detectTappedItem(touch);

          if (mounted && result != null) {
            context.read<MidiSender>().handleNewTouch(
                CustomPointer(touch.pointer, touch.position), result);
          }
        }

        move(PointerEvent touch) {
          if (settings.playMode == PlayMode.noSlide) return;

          if (mounted) {
            int? result = _detectTappedItem(touch);
            context.read<MidiSender>().handlePan(
                CustomPointer(touch.pointer, touch.position), result);

            // if (settings.playMode == PlayMode.slide) {
            //   context.read<MidiSender>().handleSlide(
            //       CustomPointer(touch.pointer, touch.position), result);
            // } //
            // else if (settings.playMode.modulatable) {
            //   context.read<MidiSender>().handleModulate(
            //       CustomPointer(touch.pointer, touch.position), result);
            // }
          }
        }

        upAndCancel(PointerEvent touch) {
          if (mounted) {
            context
                .read<MidiSender>()
                .handleEndTouch(CustomPointer(touch.pointer, touch.position));

            if (settings.sustainTimeUsable > 0 &&
                settings.playMode.modulatable) {
              TouchEvent? event = context
                  .read<MidiSender>()
                  .playMode
                  .releaseBuffer
                  .getByID(touch.pointer);
              if (event == null || event.newPosition == event.origin) return;

              AnimationController controller = AnimationController(
                duration: Duration(milliseconds: settings.sustainTimeUsable),
                vsync: this,
              );
              Animation<double> curve = CurvedAnimation(
                parent: controller,
                curve: Curves.easeIn,
              );
              Animation<double> animation = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(curve);

              Offset constrainedPosition = settings.modulation2D
                  ? Utils.limitToSquare(event.origin, touch.position,
                      settings.absoluteRadius(context))
                  : Utils.limitToCircle(event.origin, touch.position,
                      settings.absoluteRadius(context));

              animation.addListener(() {
                if (animation.isCompleted ||
                    !context
                        .read<MidiSender>()
                        .playMode
                        .releaseBuffer
                        .isNoteInBuffer(event.noteEvent.note) ||
                    !mounted) {
                  controller.dispose();
                  return;
                } else {
                  context.read<MidiSender>().handlePan(
                      CustomPointer(
                          touch.pointer,
                          Offset.lerp(constrainedPosition, event.origin,
                              animation.value)!),
                      null);
                  setState(() {});
                }
              });
              controller.forward();
            }
          }
        }

        return Stack(
          children: [
            Listener(
              onPointerDown: down,
              onPointerMove: move,
              onPointerUp: upAndCancel,
              onPointerCancel: upAndCancel,
              child: Column(
                // Hit testing happens on this keyed Widget, which contains all the pads:
                key: _padsWidgetKey,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...settings.rows.map(
                    (row) {
                      return Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...row.map(
                              (note) {
                                return Expanded(
                                  flex: 1,
                                  child: HitTestObject(
                                    index: note,
                                    child: SlideBeatPad(note: note),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (settings.playMode.modulatable) const PaintModulation(),
          ],
        );
      },
    );
  }
}
