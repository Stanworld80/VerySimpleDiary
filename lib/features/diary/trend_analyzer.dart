class TrendAnalyzer {
  static String analyzeTrend(double today, double yesterday) {
    if (today > yesterday) return 'en hausse';
    if (today < yesterday) return 'en baisse';
    return 'stable';
  }
}
