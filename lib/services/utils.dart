import 'package:flutter/foundation.dart';

/// Prints only in  Debug Mode
void log(String input) {
  if (kDebugMode) {
    print(input);
  }
}

// MIDI UTILS
Map<int, String> midiNotesSharps = {
  0: "C",
  1: "C#",
  2: "D",
  3: "D#",
  4: "E",
  5: "F",
  6: "F#",
  7: "G",
  8: "G#",
  9: "A",
  10: "A#",
  11: "B",
};

Map<int, String> midiNotesFlats = {
  ...midiNotesSharps,
  1: "Db",
  3: "Eb",
  6: "Gb",
  8: "Ab",
  10: "Bb",
};

enum NoteSigns { sharps, flats }

/// Get Note Name String from Midi Value (0 - 127) as NoteSigns.sharps (default) or NoteSigns.flats
String getNoteName(int value, {NoteSigns sign = NoteSigns.sharps}) {
  if (value < 0 || value > 127) {
    return "Out of range";
  }

  int octave = value ~/ 12;
  int note = value % 12;

  if (sign == NoteSigns.sharps) {
    return "${midiNotesSharps[note]}${octave - 2}";
  } else {
    return "${midiNotesFlats[note]}${octave - 2}";
  }
}
