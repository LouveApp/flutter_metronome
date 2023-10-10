import 'package:flutter_metronome/audio_player/interfaces/audio_player_interface.dart';
import 'package:flutter_metronome/enities/metronome_sound.dart';
import 'package:just_audio/just_audio.dart';

class JustAudioImpl extends AudioPlayerInterface {
  late final AudioPlayer _player;

  JustAudioImpl() {
    _player = AudioPlayer();
  }

  @override
  Future<void> play() async {
    _player.play();
    Future.delayed(const Duration(milliseconds: 120), () {
      _player.pause();
      _player.seek(Duration.zero);
    });
  }

  @override
  Future<void> setSource(MetronomeAudioSource source) async {
    await _player.setAudioSource(
      AudioSource.asset(
        source.asset,
        package: source.package,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _player.pause();
    await _player.seek(const Duration(milliseconds: 0));
  }

  @override
  Future<void> setVolume(double value) async {
    await _player.setVolume(value);
  }

  @override
  Future<void> dispose() async {
    _player.dispose();
  }
}
