import 'package:flutter_test/flutter_test.dart';
import 'package:verysimplediary/features/diary/score_calculator.dart';

void main() {
  group('ScoreCalculator Tests', () {
    test('Empty values list handles correctly', () {
      final result = ScoreCalculator.calculate([]);
      expect(result.total, 0);
      expect(result.mean, 0.0);
      expect(result.median, 0.0);
      expect(result.level, 'Moyen');
    });

    test('Single value calculations', () {
      final result = ScoreCalculator.calculate([2]);
      expect(result.total, 2);
      expect(result.mean, 2.0);
      expect(result.median, 2.0);
      expect(result.level, 'Optimal');
    });

    test('Odd number of elements median calculation', () {
      final result = ScoreCalculator.calculate([-2, 0, 1, 2, 2]);
      // Sorted: -2, 0, 1, 2, 2
      // Median is 1
      expect(result.total, 3);
      expect(result.mean, 0.6); // 3 / 5
      expect(result.median, 1.0);
      expect(result.level, 'Bon');
    });

    test('Even number of elements median calculation', () {
      final result = ScoreCalculator.calculate([-1, 0, 1, 2]);
      // Sorted: -1, 0, 1, 2
      // Median is (0 + 1) / 2 = 0.5
      expect(result.total, 2);
      expect(result.mean, 0.5); // 2 / 4
      expect(result.median, 0.5);
      expect(result.level, 'Bon');
    });

    test('Levels mapping validation', () {
      // Optimal: >= 1.5
      expect(ScoreCalculator.calculate([2, 1, 2]).level, 'Optimal'); // mean = 1.66
      
      // Bon: [0.5, 1.5[
      expect(ScoreCalculator.calculate([1, 0, 1]).level, 'Bon'); // mean = 0.66
      
      // Moyen: [-0.5, 0.5[
      expect(ScoreCalculator.calculate([-1, 0, 1]).level, 'Moyen'); // mean = 0
      
      // Nul: [-1.5, -0.5[
      expect(ScoreCalculator.calculate([-2, -1, 0]).level, 'Nul'); // mean = -1.0
      
      // Négatif: < -1.5
      expect(ScoreCalculator.calculate([-2, -2, -1]).level, 'Négatif'); // mean = -1.66
    });
  });
}
