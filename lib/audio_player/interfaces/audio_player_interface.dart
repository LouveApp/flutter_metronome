
import 'package:flutter_metronome/entities/metronome_sound.dart';

abstract class AudioPlayerInterface {
  Future<void> setSource(MetronomeAudioSource source);
  Future<void> play();
  Future<void> stop();
  Future<void> setVolume(double value);
  Future<void> dispose();
}
