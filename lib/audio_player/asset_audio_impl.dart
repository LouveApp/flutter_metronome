// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:flutter_metronome/audio_player/audio_player.dart';
// import 'package:flutter_metronome/enities/metronome_sound.dart';

// class AssetAudioPlayerImpl extends IAudioPlayer {
//   late final AssetsAudioPlayer _player;

//   AssetAudioPlayerImpl() {
//     _player = AssetsAudioPlayer.newPlayer();
//   }

//   @override
//   Future<void> play() async {
//     _player.play();

//     Future.delayed(Duration(milliseconds: 140), () {
//       _player.stop();
//     });
//   }

//   @override
//   Future<void> setSource(MetronomeAudioSource source) async {
//     await _player.open(
//       Audio(
//         source.asset,
//         package: source.package,
//       ),
//       autoStart: false,
//       showNotification: false,
//     );
//   }

//   @override
//   Future<void> stop() async {
//     await _player.pause();
//     await _player.seek(Duration.zero);
//   }

//   @override
//   Future<void> setVolume(double value) async {
//     await _player.setVolume(value);
//   }

//   @override
//   Future<void> dispose() async {
//     _player.dispose();
//   }
// }
