import 'dart:async';
import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class Metronome {
  late ValueNotifier<int> bitTimeNotifier;
  late ValueNotifier<double> bpmNotifier;
  late ValueNotifier<int> compassoNotifier;
  late ValueNotifier<MetronomeSound> metronomeSoundNotifier;

  final List<int> compassos;

  final double maxSpeed;
  final double minSpeed;

  Metronome({
    int compasso = 4,
    double bpm = 120,
    MetronomeSound metronomeSound = MetronomeSound.digital,
    this.maxSpeed = 244,
    this.minSpeed = 30,
    this.compassos = const [1, 2, 3, 4, 5, 6, 7, 8],
  }) {
    metronomeSoundNotifier = ValueNotifier(metronomeSound);
    compassoNotifier = ValueNotifier(compasso);
    bpmNotifier = ValueNotifier(bpm);
    bitTimeNotifier = ValueNotifier(0);
    setSound(metronomeSound);

    _audioPlayerHigh.setVolume(2.0);
    _audioPlayerLow.setVolume(2.0);
  }

  final AudioPlayer _audioPlayerHigh = AudioPlayer();
  final AudioPlayer _audioPlayerLow = AudioPlayer();

  bool isPlaying = false;
  Timer? _timer;

  bool setBPM(double bpm) {
    if (bpm < minSpeed || bpm > maxSpeed) {
      return false;
    }
    this.bpmNotifier.value = bpm;

    if (isPlaying) {
      _stopTimer();
      _startTimer();
    }

    return true;
  }

  void start() {
    if (!isPlaying) {
      isPlaying = true;
      _playClick();
      _startTimer();
    }
  }

  void stop() {
    if (isPlaying) {
      isPlaying = false;
      bitTimeNotifier.value = 0;
      _audioPlayerHigh.pause();
      _audioPlayerLow.pause();
      _stopTimer();
    }
  }

  void _playClick() async {
    var bitTime = bitTimeNotifier.value;
    bitTime = bitTime < compassoNotifier.value ? bitTime + 1 : 1;
    bitTimeNotifier.value = bitTime;

    var audioPlayer = bitTime == 1 ? _audioPlayerHigh : _audioPlayerLow;

    await audioPlayer.seek(Duration.zero);
    audioPlayer.play();
  }

  void _startTimer() {
    _timer = Timer.periodic(_getInterval(), (_) {
      _playClick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<int>> audioFileToBytes(String filePath) async {
    final File audioFile = File(filePath);
    if (!await audioFile.exists()) {
      throw Exception('O arquivo de áudio não existe.');
    }

    final List<int> bytes = await audioFile.readAsBytes();
    return bytes;
  }

  void dispose() async {
    _stopTimer();
    await _audioPlayerHigh.pause();
    await _audioPlayerLow.pause();
    await _audioPlayerHigh.dispose();
    await _audioPlayerLow.dispose();
  }

  void setSound(MetronomeSound metronomeSound) async {
    var _isPlaying = isPlaying;

    if (_isPlaying) {
      stop();
    }

    metronomeSoundNotifier.value = metronomeSound;

    await _audioPlayerHigh.setAudioSource(
      AudioSource.asset(
        'assets/audio/${metronomeSound.folder}/hi.wav',
        package: 'flutter_metronome',
      ),
    );
    await _audioPlayerLow.setAudioSource(
      AudioSource.asset(
        'assets/audio/${metronomeSound.folder}/lo.wav',
        package: 'flutter_metronome',
      ),
    );

    if (_isPlaying) {
      start();
    }
  }

  void setHits(int compasso) {
    compassoNotifier.value = compasso;
  }

  Duration _getInterval() {
    return Duration(milliseconds: (60000 / bpmNotifier.value).round());
  }
}

enum MetronomeSound {
  bell,
  clicks,
  cowbells,
  digital,
  pings,
  seiko,
  sticks,
  vegas,
  yamaha,
}

extension MetronomeSoundExtension on MetronomeSound {
  String get folder => _getFolder();

  String _getFolder() {
    switch (this) {
      case MetronomeSound.bell:
        return 'bell';
      case MetronomeSound.clicks:
        return 'clicks';
      case MetronomeSound.cowbells:
        return 'cowbells';
      case MetronomeSound.digital:
        return 'digital';
      case MetronomeSound.pings:
        return 'pings';
      case MetronomeSound.seiko:
        return 'seiko';
      case MetronomeSound.sticks:
        return 'sticks';
      case MetronomeSound.vegas:
        return 'vegas';
      case MetronomeSound.yamaha:
        return 'yamaha';
      default:
        return '';
    }
  }
}
