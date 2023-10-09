library flutter_metronome;

import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

class Metronome {
  late int _beatTime;
  late double _bpm;
  late int _hits;
  late final double _maxSpeed;
  late final double _minSpeed;
  late MetronomeSound _sound;

  final Function(int index)? onBeat;

  int get bitTime => _beatTime;
  double get bpm => _bpm;
  int get hits => _hits;
  double get maxSpeed => _maxSpeed;
  double get minSpeed => _minSpeed;
  MetronomeSound get sound => _sound;

  Metronome({
    int hits = 4,
    double initialBPM = 120,
    MetronomeSound metronomeSound = MetronomeSound.digital,
    double maxSpeed = 244,
    double minSpeed = 30,
    this.onBeat,
  }) {
    _minSpeed = minSpeed;
    _maxSpeed = maxSpeed;
    _hits = hits;
    _bpm = initialBPM;
    _beatTime = 0;
    setSound(metronomeSound);

    _audioPlayerHigh.setVolume(2.0);
    _audioPlayerLow.setVolume(2.0);
  }

  final AudioPlayer _audioPlayerHigh = AudioPlayer();
  final AudioPlayer _audioPlayerLow = AudioPlayer();

  bool isPlaying = false;
  Timer? _timer;

  bool setBPM(double bpm) {
    if (bpm < _minSpeed || bpm > _maxSpeed) {
      return false;
    }
    this._bpm = bpm;

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
      _beatTime = 0;
      _audioPlayerHigh.pause();
      _audioPlayerLow.pause();
      _stopTimer();
    }
  }

  void _playClick() async {
    var bitTime = _beatTime;
    bitTime = bitTime < _hits ? bitTime + 1 : 1;
    _beatTime = bitTime;

    onBeat?.call(bitTime);

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

    _sound = metronomeSound;

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
    _hits = compasso;
  }

  Duration _getInterval() {
    return Duration(milliseconds: (60000 / _bpm).round());
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
