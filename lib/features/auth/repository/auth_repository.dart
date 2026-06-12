import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockUser implements User {
  @override
  String get uid => 'mock_user_123';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Mock User';
  
  @override
  bool get emailVerified => true;
  @override
  bool get isAnonymous => false;
  @override
  List<UserInfo> get providerData => [];
  @override
  UserMetadata get metadata => throw UnimplementedError();
  
  @override
  Future<void> delete() async {}
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => throw UnimplementedError();
  @override
  Future<void> reload() async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class AuthRepository {
  FirebaseAuth? _auth;
  User? _mockUser;

  AuthRepository() {
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase Auth not available. Initializing in Local-Only Mock Mode.");
      // Auto login in mock mode for instant usage
      _mockUser = MockUser();
    }
  }

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return Stream.value(_mockUser);
  }

  User? get currentUser {
    if (_auth != null) {
      return _auth!.currentUser;
    }
    return _mockUser;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } else {
      _mockUser = MockUser();
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } else {
      _mockUser = MockUser();
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    } else {
      _mockUser = null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
