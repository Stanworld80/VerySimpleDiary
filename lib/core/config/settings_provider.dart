import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class SettingsState {
  final String geminiApiKey;
  final bool useGemini;
  final String geminiMode;
  final String geminiProxyUrl;

  const SettingsState({
    required this.geminiApiKey,
    required this.useGemini,
    this.geminiMode = 'proxy',
    this.geminiProxyUrl = 'https://us-central1-stanverysimplediary-dev.cloudfunctions.net/getGeminiInsight',
  });

  SettingsState copyWith({
    String? geminiApiKey,
    bool? useGemini,
    String? geminiMode,
    String? geminiProxyUrl,
  }) {
    return SettingsState(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      useGemini: useGemini ?? this.useGemini,
      geminiMode: geminiMode ?? this.geminiMode,
      geminiProxyUrl: geminiProxyUrl ?? this.geminiProxyUrl,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  SettingsNotifier(this._prefs, this._secureStorage)
      : super(SettingsState(
          geminiApiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
          useGemini: _prefs.getBool('use_gemini') ?? false,
          geminiMode: _prefs.getString('gemini_mode') ?? 'proxy',
          geminiProxyUrl: _prefs.getString('gemini_proxy_url') ??
              'https://us-central1-stanverysimplediary-dev.cloudfunctions.net/getGeminiInsight',
        )) {
    _loadSecureKey();
  }

  Future<void> _loadSecureKey() async {
    try {
      final securedKey = await _secureStorage.read(key: 'gemini_api_key');
      if (securedKey != null && securedKey.isNotEmpty) {
        state = state.copyWith(geminiApiKey: securedKey);
      }
    } catch (_) {
      // In case secure storage fails on a specific platform (e.g. desktop/test), fall back to preferences if available
      final fallbackKey = _prefs.getString('gemini_api_key') ?? '';
      if (fallbackKey.isNotEmpty) {
        state = state.copyWith(geminiApiKey: fallbackKey);
      }
    }
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    final cleanKey = apiKey.trim();
    try {
      await _secureStorage.write(key: 'gemini_api_key', value: cleanKey);
      // Clean up the key from shared preferences if it was stored there previously
      await _prefs.remove('gemini_api_key');
    } catch (_) {
      // Fallback to shared preferences if secure storage fails
      await _prefs.setString('gemini_api_key', cleanKey);
    }
    state = state.copyWith(geminiApiKey: cleanKey);
  }

  Future<void> setUseGemini(bool useGemini) async {
    await _prefs.setBool('use_gemini', useGemini);
    state = state.copyWith(useGemini: useGemini);
  }

  Future<void> setGeminiMode(String mode) async {
    await _prefs.setString('gemini_mode', mode);
    state = state.copyWith(geminiMode: mode);
  }

  Future<void> setGeminiProxyUrl(String url) async {
    await _prefs.setString('gemini_proxy_url', url);
    state = state.copyWith(geminiProxyUrl: url);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return SettingsNotifier(prefs, secureStorage);
});
