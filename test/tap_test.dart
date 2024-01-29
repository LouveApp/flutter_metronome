import 'package:flutter_metronome/flutter_metronome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool isBetween(double value, double start, double end) {
    return value >= start && value <= end;
  }

  test('deve calcular o bpm corretamente', () async {
    for (var i = 0; i < 6; i++) {
      Metronome.bpmCalculator.tap();
      await Future.delayed(const Duration(seconds: 1));
    }

    expect(isBetween(Metronome.bpmCalculator.tap(), 58.0, 60.0), true);
  });

  test('deve resetar o timer caso tenha passado o tempo de intervalo esperado',
      () async {
    for (var i = 0; i < 4; i++) {
      Metronome.bpmCalculator.tap();
      await Future.delayed(const Duration(seconds: 1));
    }

    expect(isBetween(Metronome.bpmCalculator.tap(), 58.0, 60.0), true);

    await Future.delayed(const Duration(seconds: 6));

    expect(isBetween(Metronome.bpmCalculator.tap(), 58.0, 60.0), false);
  });
}
