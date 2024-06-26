import 'package:beat_pads/services/services.dart';
import 'package:flutter/material.dart';

class TouchEvent {
  /// Holds geometry, note and modulation information this.uniqueID, this.origin,
  TouchEvent(
    CustomPointer touch,
    this.noteEvent,
    SendSettings settings,
    Size screenSize,
    PadBox padBox,
    this.originXPercentage,
    this.originYPercentage,
  )   : origin = touch.position,
        originPadBox = padBox,
        newPosition = touch.position,
        newPadBox = padBox,
        uniqueID = touch.pointer,
        deadZone = settings.modulationDeadZone,
        maxRadius = screenSize.longestSide * settings.modulationRadius;
  final int uniqueID;

  bool leftInitialPad = false;

  // Note and modulation parameters:
  NoteEvent noteEvent;

  // Geometry parameters:
  final Offset origin;
  final PadBox originPadBox;
  final double maxRadius;
  final double deadZone;
  final double originYPercentage;
  final double originXPercentage;
  Offset newPosition;
  PadBox newPadBox;

  bool hasReturnAnimation = false;

  bool _kill = false;
  bool get kill => _kill;
  void markKillIfNoteOffAndNoAnimation() {
    if (!noteEvent.isPlaying && !hasReturnAnimation) _kill = true;
  }

  /// Prevents touchevent from receiving further position updates in move(). Irreversible!
  void markDirty() => _dirty = true;
  bool _dirty = false;
  bool get dirty => _dirty;

  /// Updates stored touch event with latest touch position. Used for geometry
  void updatePosition(Offset updatedPosition, [PadBox? updatedPadBox]) {
    newPosition = updatedPosition;
    if (updatedPadBox != null) {
      newPadBox = updatedPadBox;
    }
  }

  /// Get the radial change factor from the origin of the
  /// touch to the current position in the context of the maximum Radius.
  /// Produces values from 0 to 1 from center to maxium Radius.
  double radialChange({Curve curve = Curves.easeIn, bool deadZone = true}) {
    final double distanceFactor =
        (Utils.offsetDistance(origin, newPosition) / maxRadius).clamp(0, 1);

    return Utils.curveTransform(
      deadZone ? applyDeadZone(distanceFactor) : distanceFactor,
      curve,
    );
  }

  /// Get the directional change factor from the origin of the
  /// touch to the current position in the context of the maximum Radius.
  /// Produced values from -1 to 1 on X and Y Axis within the maximum Diameter.
  Offset directionalChangeFromCenter({
    Curve curve = Curves.easeIn,
    bool deadZone = true,
  }) {
    final double factorX =
        ((newPosition.dx - origin.dx) / maxRadius).clamp(-1, 1);
    final double factorY =
        ((-newPosition.dy + origin.dy) / maxRadius).clamp(-1, 1);

    return Offset(
      Utils.curveTransform(
        deadZone ? applyDeadZone(factorX) : factorX,
        curve,
      ),
      Utils.curveTransform(
        deadZone ? applyDeadZone(factorY) : factorY,
        curve,
      ),
    );
  }

  /// Get the directional change factor from the origin of the
  /// touch to the current position.
  Offset directionalChangeUnclamped(
      // Curve curve = Curves.easeIn,
      // bool deadZone = true,
      ) {
    // final double factorX =
    //     ((newPosition.dx - origin.dx) / maxRadius).clamp(-1, 1);
    // final double factorY =
    //     ((-newPosition.dy + origin.dy) / maxRadius).clamp(-1, 1);

    return Offset(newPosition.dx, newPosition.dy);
    // return Offset(newPosition.dx - origin.dx, newPosition.dy + origin.dy);
  }

  /// Applies a deadZone to an input value, which means that the function
  /// only returns a value when it is above the given threshhold.
  /// Then remaps range **from** 0 to 1.0 **to** deadZone to 1.0.
  double applyDeadZone(double input) {
    if (input.isNegative) {
      if (input > -deadZone) return 0;
      return Utils.mapValueToTargetRange(input, -1, -deadZone, -1, 0);
    }
    if (input < deadZone) return 0;
    return Utils.mapValueToTargetRange(input, deadZone, 1, 0, 1);
  }

  @override
  String toString() {
    return 'noteEvent: ${noteEvent.note} / isAnimated: $hasReturnAnimation / noteOn: ${noteEvent.isPlaying} / isDirty: $_dirty';
  }

  bool get isModulating {
    if (directionalChangeFromCenter() != Offset.zero && radialChange() != 0) {
      return true;
    }
    return false;
  }
}
