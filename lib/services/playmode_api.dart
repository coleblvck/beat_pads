import 'package:beat_pads/services/services.dart';
import 'package:flutter/material.dart';

abstract class PlayModeHandler {
  final Settings settings;
  final Function notifyParent;
  final VelocityProvider velocityProvider;

  final TouchBuffer touchBuffer;
  late TouchReleaseBuffer touchReleaseBuffer;

  PlayModeHandler(
    this.settings,
    this.notifyParent,
  )   : touchBuffer = TouchBuffer(settings),
        velocityProvider = VelocityProvider(settings, notifyParent) {
    touchReleaseBuffer = TouchReleaseBuffer(
      settings,
      releaseChannel,
      notifyParent,
    );
  }

  void handleNewTouch(CustomPointer touch, int noteTapped, Size screenSize) {
    if (settings.modSustainTimeUsable > 0 ||
        settings.noteSustainTimeUsable > 0) {
      touchReleaseBuffer.removeNoteFromReleaseBuffer(noteTapped);
    }

    NoteEvent noteOn =
        NoteEvent(settings.channel, noteTapped, velocityProvider.velocity)
          ..noteOn(cc: settings.sendCC);

    touchBuffer.addNoteOn(touch, noteOn, screenSize);
    notifyParent();
  }

  void handlePan(CustomPointer touch, int? note) {}

  void handleEndTouch(CustomPointer touch) {
    TouchEvent? eventInBuffer = touchBuffer.getByID(touch.pointer);
    if (eventInBuffer == null) return;

    if (settings.modSustainTimeUsable == 0 &&
        settings.noteSustainTimeUsable == 0) {
      eventInBuffer.noteEvent.noteOff();
      releaseChannel(eventInBuffer.noteEvent.channel);
      touchBuffer.remove(eventInBuffer);

      notifyParent();
    } else {
      if (settings.modSustainTimeUsable == 0 &&
          settings.noteSustainTimeUsable > 0) {
        eventInBuffer.newPosition = eventInBuffer.origin;
      }
      touchReleaseBuffer.updateReleasedEvent(
          eventInBuffer); // instead of note off, event passed to release buffer
      touchBuffer.remove(eventInBuffer);
    }
  }

  void dispose() {
    print("disposing");
    for (TouchEvent touch in touchBuffer.buffer) {
      if (touch.noteEvent.isPlaying) touch.noteEvent.noteOff();
    }
    for (TouchEvent touch in touchReleaseBuffer.buffer) {
      if (touch.noteEvent.isPlaying) touch.noteEvent.noteOff();
    }
  }

  void markDirty() {
    // TODO working with riverpod ????!!!
    for (var event in touchBuffer.buffer) {
      event.markDirty();
    }
    for (var event in touchReleaseBuffer.buffer) {
      event.markDirty();
    }
  }

  /// Returns if a given note is ON in any channel, or, if provided, in a specific channel.
  /// Checks releasebuffer and active touchbuffer
  bool isNoteOn(int note, [int? channel]) {
    for (TouchEvent touch in touchBuffer.buffer) {
      if (channel == null &&
          touch.noteEvent.note == note &&
          touch.noteEvent.isPlaying) return true;
      if (channel == channel &&
          touch.noteEvent.note == note &&
          touch.noteEvent.isPlaying) return true;
    }
    if (settings.modSustainTimeUsable > 0 ||
        settings.noteSustainTimeUsable > 0) {
      for (TouchEvent event in touchReleaseBuffer.buffer) {
        if (channel == null &&
            event.noteEvent.note == note &&
            event.noteEvent.isPlaying) return true;
        if (channel == channel &&
            event.noteEvent.note == note &&
            event.noteEvent.isPlaying) return true;
      }
    }
    return false;
  }

  /// Does nothing, unless overridden in MPE
  void releaseChannel(int channel) {}
}

class PlayModeNoSlide extends PlayModeHandler {
  PlayModeNoSlide(super.settings, super.notifyParent);
  // Uses default PlayModeHandler behaviour
}
