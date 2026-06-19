import 'package:flutter_test/flutter_test.dart';
import 'package:verysimplediary/features/diary/score_calculator.dart';

void main() {
  group('ScoreCalculator Boundary and Limit Tests', () {
    test('All minimum values (-2)', () {
      final List<int> minValues = List.filled(96, -2); // 24 questions * 4 periods
      final result = ScoreCalculator.calculate(minValues);
      expect(result.total, -192);
      expect(result.mean, -2.0);
      expect(result.median, -2.0);
      expect(result.level, 'Négatif');
    });

    test('All maximum values (+2)', () {
      final List<int> maxValues = List.filled(96, 2);
      final result = ScoreCalculator.calculate(maxValues);
      expect(result.total, 192);
      expect(result.mean, 2.0);
      expect(result.median, 2.0);
      expect(result.level, 'Optimal');
    });

    test('Massive dataset performance and precision limit (100,000 values)', () {
      // Create a list of 100,000 values alternating between -1, 0, 1, 2
      final List<int> giantList = List.generate(100000, (index) => (index % 4) - 1);
      // Expected sum: -1 + 0 + 1 + 2 = 2 per block of 4.
      // 25,000 blocks. Total sum = 50,000.
      // Mean = 50,000 / 100,000 = 0.5.
      // Median of -1, 0, 1, 2 (sorted: 25k -1s, 25k 0s, 25k 1s, 25k 2s).
      // Middle elements are at index 49999 (0) and 50000 (1). Median is (0 + 1) / 2 = 0.5.
      
      final stopwatch = Stopwatch()..start();
      final result = ScoreCalculator.calculate(giantList);
      stopwatch.stop();
      
      expect(result.total, 50000);
      expect(result.mean, 0.5);
      expect(result.median, 0.5);
      expect(result.level, 'Bon'); // mean >= 0.5
      
      // Ensure it calculates giant lists in less than 3000 milliseconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    test('Handles out-of-bounds input values gracefully', () {
      // If the app somehow feeds out of bounds ratings (e.g. -5 or +10),
      // we check that the score calculation still works mathematically.
      final result = ScoreCalculator.calculate([-5, 10]);
      expect(result.total, 5);
      expect(result.mean, 2.5);
      expect(result.median, 2.5);
      expect(result.level, 'Optimal');
    });
  });
}
