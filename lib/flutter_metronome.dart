library flutter_metronome;

import 'dart:async';

import 'package:flutter_metronome/enities/metronome_sound.dart';
import 'package:just_audio/just_audio.dart';

class Metronome {
  late int _beatIndex;
  late double _bpm;
  late int _beats;
  late final double _maxBpm;
  late final double _minBpm;
  late MetronomeSound _sound;
  final AudioPlayer _audioPlayerHigh = AudioPlayer();
  final AudioPlayer _audioPlayerLow = AudioPlayer();
  Timer? _timer;

  final Function(int index)? onBeat;

  double get bpm => _bpm;
  int get beats => _beats;
  double get maxBpm => _maxBpm;
  double get minBpm => _minBpm;
  MetronomeSound get sound => _sound;
  bool isPlaying = false;

  Metronome({
    int beats = 4,
    double initialBpm = 120.0,
    MetronomeSound? sound,
    double maxBpm = 244.0,
    double minBpm = 30.0,
    this.onBeat,
  }) {
    _minBpm = minBpm;
    _maxBpm = maxBpm;
    _beats = beats;
    _bpm = initialBpm;
    _beatIndex = 0;

    setSound(sound ?? MetronomeSounds.digital);

    _audioPlayerHigh.setVolume(2.0);
    _audioPlayerLow.setVolume(2.0);
  }

  bool setBPM(double bpm) {
    if (bpm < _minBpm || bpm > _maxBpm) {
      return false;
    }
    _bpm = bpm;
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

  Future<void> stop() async {
    if (isPlaying) {
      isPlaying = false;
      _beatIndex = 0;
      await _audioPlayerHigh.pause();
      await _audioPlayerLow.pause();
      _stopTimer();
    }
  }

  void setBeats(int beats) => _beats = beats;

  void setSound(MetronomeSound metronomeSound) async {
    var keepPlaying = isPlaying;

    if (isPlaying) {
      await stop();
    }

    _sound = metronomeSound;

    await _audioPlayerHigh.setAudioSource(_sound.high);
    await _audioPlayerLow.setAudioSource(_sound.low);

    if (keepPlaying) {
      start();
    }
  }

  void _playClick() async {
    _beatIndex = _beatIndex < _beats ? _beatIndex + 1 : 1;
    onBeat?.call(_beatIndex);
    var audioPlayer = _beatIndex == 1 ? _audioPlayerHigh : _audioPlayerLow;

    audioPlayer.play();

    Future.delayed(const Duration(milliseconds: 120), () async {
      await audioPlayer.pause();
      audioPlayer.seek(Duration.zero);
    });
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

  void dispose() async {
    _stopTimer();
    await _audioPlayerHigh.pause();
    await _audioPlayerLow.pause();
    await _audioPlayerHigh.dispose();
    await _audioPlayerLow.dispose();
  }

  Duration _getInterval() {
    return Duration(milliseconds: (60000 / _bpm).round());
  }
}
