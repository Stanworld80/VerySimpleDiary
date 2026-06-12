import 'package:flutter_test/flutter_test.dart';
import 'package:verysimplediary/features/diary/trend_analyzer.dart';

void main() {
  group('TrendAnalyzer TDD Tests', () {
    test('Score is increasing (en hausse)', () {
      expect(TrendAnalyzer.analyzeTrend(1.5, 0.5), 'en hausse');
    });

    test('Score is decreasing (en baisse)', () {
      expect(TrendAnalyzer.analyzeTrend(0.5, 1.5), 'en baisse');
    });

    test('Score is stable (stable)', () {
      expect(TrendAnalyzer.analyzeTrend(1.0, 1.0), 'stable');
    });
  });
}
