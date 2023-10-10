class MetronomeSound {
  final MetronomeAudioSource high;
  final MetronomeAudioSource low;
  final String? name;

  const MetronomeSound({
    required this.high,
    required this.low,
    this.name,
  });
}

class MetronomeAudioSource {
  final String asset;
  final String package;

  String get fullPath => 'packages/$package/$asset';

  MetronomeAudioSource(this.asset, {required this.package});
}

abstract class MetronomeSounds {
  static final bell = MetronomeSound(
    name: 'bell',
    high: MetronomeAudioSource(
      'assets/audio/bell/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/bell/lo.wav',
      package: 'flutter_metronome',
    ),
  );

  static final clicks = MetronomeSound(
    name: 'clicks',
    high: MetronomeAudioSource(
      'assets/audio/clicks/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/clicks/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final cowbells = MetronomeSound(
    name: 'cowbells',
    high: MetronomeAudioSource(
      'assets/audio/cowbells/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/cowbells/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final digital = MetronomeSound(
    name: 'digital',
    high: MetronomeAudioSource(
      'assets/audio/digital/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/digital/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final pings = MetronomeSound(
    name: 'pings',
    high: MetronomeAudioSource(
      'assets/audio/pings/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/pings/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final seiko = MetronomeSound(
    name: 'seiko',
    high: MetronomeAudioSource(
      'assets/audio/seiko/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/seiko/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final sticks = MetronomeSound(
    name: 'sticks',
    high: MetronomeAudioSource(
      'assets/audio/sticks/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/sticks/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final vegas = MetronomeSound(
    name: 'vegas',
    high: MetronomeAudioSource(
      'assets/audio/vegas/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/vegas/lo.wav',
      package: 'flutter_metronome',
    ),
  );
  static final yamaha = MetronomeSound(
    name: 'yamaha',
    high: MetronomeAudioSource(
      'assets/audio/yamaha/hi.wav',
      package: 'flutter_metronome',
    ),
    low: MetronomeAudioSource(
      'assets/audio/yamaha/lo.wav',
      package: 'flutter_metronome',
    ),
  );
}
