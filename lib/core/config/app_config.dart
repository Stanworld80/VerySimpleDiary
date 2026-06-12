class AppConfig {
  static const version = String.fromEnvironment('VERSION', defaultValue: '1.0.0');
  static const buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: 'local');
  static const deployDate = String.fromEnvironment('DEPLOY_DATE', defaultValue: 'Not deployed (local)');
}
