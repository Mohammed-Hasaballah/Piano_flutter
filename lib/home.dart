// ignore_for_file: avoid_print, dead_code

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:piano/piano.dart';
import 'package:flutter/foundation.dart';

class PianoApp extends StatefulWidget {
  const PianoApp({Key? key}) : super(key: key);

  @override
  _PianoAppState createState() => _PianoAppState();
}

class _PianoAppState extends State<PianoApp> {
  final FlutterMidi _flutterMidi = FlutterMidi();
  late String _selectedFile;
  final Map<String, String> _sf2Files = {
    'Piano': 'assets/Piano.sf2',
    'Yamaha Grand Lite': 'assets/Yamaha-Grand-Lite-SF-v1.1.sf2',
    'XDrum Piano': 'assets/XDrum_Piano.sf2',
  };

  @override
  void initState() {
    _selectedFile = _sf2Files.keys.first;
    loadSelectedSF2File();
    super.initState();
  }

  Future<void> loadSelectedSF2File() async {
    final String assetPath = _sf2Files[_selectedFile]!;
    final ByteData byte = await rootBundle.load(assetPath);
    _flutterMidi.unmute();
    _flutterMidi.prepare(sf2: byte);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piano',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Music App'),
          actions: [
            DropdownButton<String>(
              // style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.black,
              value: _selectedFile,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFile = newValue;
                    loadSelectedSF2File();
                  });
                }
              },
              items: _sf2Files.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        body: Center(
          child: InteractivePiano(
            naturalColor: Colors.white,
            accidentalColor: Colors.black,
            keyWidth: 40,
            noteRange: NoteRange.forClefs([
              Clef.Treble,
            ]),
            onNotePositionTapped: (position) {
              _play(position);
            },
          ),
        ),
      ),
    );
  }

  void _play(NotePosition position) {
    if (kIsWeb) {
      // Play sound for web
    } else {
      int midi = position.note.index + position.octave * 12;
      _flutterMidi.playMidiNote(midi: midi);
    }
  }
}
