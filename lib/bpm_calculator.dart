part of './flutter_metronome.dart';

class _BpmCalculator {
  static _BpmCalculator? _instance;
  List<DateTime> _tapTimes = [];

  Timer? _iddleTimer;
  ValueNotifier<double?> bpmNotifier = ValueNotifier<double?>(null);

  final int _minTaps = 2;
  final int _maxTaps = 12;

  final int _acceptableIddleTimeInSeconds = 3;

  _BpmCalculator._();

  static _BpmCalculator get instance {
    _instance ??= _BpmCalculator._();
    return _instance!;
  }

  double tap() {
    _iddleTimerInit();

    if (_tapTimes.length > _maxTaps) {
      _tapTimes.removeAt(0);
    }

    _tapTimes.add(DateTime.now());

    if (_tapTimes.length >= _minTaps) {
      double averageMilliseconds = _calculateAverageMilliseconds();
      double bpm = 60000 / averageMilliseconds;

      bpm = double.parse(bpm.toStringAsFixed(2));
      bpmNotifier.value = bpm;
      return bpm;
    }

    return 0.0;
  }

  double _calculateAverageMilliseconds() {
    int sum = 0;
    for (int i = 1; i < _tapTimes.length; i++) {
      sum += _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds;
    }

    return sum / (_tapTimes.length - 1);
  }

  void _iddleTimerInit() {
    _iddleTimer?.cancel();
    _iddleTimer = Timer(Duration(seconds: _acceptableIddleTimeInSeconds), () {
      bpmNotifier.value = null;
      _tapTimes = [];
    });
  }
}
