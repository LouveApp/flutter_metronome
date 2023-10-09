import 'package:just_audio/just_audio.dart';

class MetronomeSound {
  final AudioSource high;
  final AudioSource low;
  final String? name;

  const MetronomeSound({
    required this.high,
    required this.low,
    this.name,
  });
}

abstract class MetronomeSounds {
  static final bell = MetronomeSound(
    name: 'bell',
    high: AudioSource.asset(
      'assets/audio/bell/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/bell/lo.wav',
      package: 'flutter_metronome',
    ),
  );

  static final clicks = MetronomeSound(
    name: 'clicks',
    high: AudioSource.asset(
      'assets/audio/clicks/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/clicks/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final cowbells = MetronomeSound(
    name: 'cowbells',
    high: AudioSource.asset(
      'assets/audio/cowbells/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/cowbells/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final digital = MetronomeSound(
    name: 'digital',
    high: AudioSource.asset(
      'assets/audio/digital/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/digital/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final pings = MetronomeSound(
    name: 'pings',
    high: AudioSource.asset(
      'assets/audio/pings/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/pings/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final seiko = MetronomeSound(
    name: 'seiko',
    high: AudioSource.asset(
      'assets/audio/seiko/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/seiko/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final sticks = MetronomeSound(
    name: 'sticks',
    high: AudioSource.asset(
      'assets/audio/sticks/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/sticks/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final vegas = MetronomeSound(
    name: 'vegas',
    high: AudioSource.asset(
      'assets/audio/vegas/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/vegas/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final yamaha = MetronomeSound(
    name: 'yamaha',
    high: AudioSource.asset(
      'assets/audio/yamaha/hi.wav',
      package: 'flutter_metronome',
    ),
    low: AudioSource.asset(
      'assets/audio/yamaha/lo.wav',
      package: 'flutter_metronome',
    ),
  );
}
