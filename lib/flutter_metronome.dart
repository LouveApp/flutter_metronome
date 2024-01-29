library flutter_metronome;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_metronome/audio_player/interfaces/audio_player_interface.dart';
import 'package:flutter_metronome/audio_player/just_audio_impl.dart';
import 'package:flutter_metronome/entities/metronome_sound.dart';

part './bpm_calculator.dart';

class Metronome {
  late double _bpm;
  late final double _maxBpm;
  late final double _minBpm;
  late int _beats;
  late int _beatIndex;
  late MetronomeSound _sound;
  final AudioPlayerInterface _audioPlayerHigh = JustAudioImpl();
  final AudioPlayerInterface _audioPlayerLow = JustAudioImpl();
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
  }

  static _BpmCalculator get bpmCalculator => _BpmCalculator.instance;

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
      await _audioPlayerHigh.stop();
      await _audioPlayerLow.stop();
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

    await _audioPlayerHigh.setSource(_sound.high);
    await _audioPlayerLow.setSource(_sound.low);

    if (keepPlaying) {
      start();
    }
  }

  void _playClick() async {
    _beatIndex = _beatIndex < _beats ? _beatIndex + 1 : 1;
    onBeat?.call(_beatIndex);
    var audioPlayer = _beatIndex == 1 ? _audioPlayerHigh : _audioPlayerLow;
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

  void dispose() async {
    _stopTimer();
    await _audioPlayerHigh.stop();
    await _audioPlayerLow.stop();
    await _audioPlayerHigh.dispose();
    await _audioPlayerLow.dispose();
  }

  Duration _getInterval() {
    return Duration(milliseconds: (60000 / _bpm).round());
  }
}
