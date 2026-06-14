import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../firebase_options.dart';

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
  static User? _mockUser = MockUser();
  static final StreamController<User?> _mockUserStreamController = StreamController<User?>.broadcast();
  static bool forceMock = false;

  AuthRepository() {
    if (forceMock) {
      debugPrint("Forced Local-Only Mock Mode.");
      return;
    }
    try {
      Firebase.app();
      _auth = FirebaseAuth.instance;
    } catch (e) {
      debugPrint("Firebase Auth not available. Initializing in Local-Only Mock Mode.");
    }
  }

  Stream<User?> get authStateChanges {
    if (_auth != null) {
      return _auth!.authStateChanges();
    }
    return _getMockStream();
  }

  Stream<User?> _getMockStream() async* {
    yield _mockUser;
    yield* _mockUserStreamController.stream;
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
      _mockUserStreamController.add(_mockUser);
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    if (_auth != null) {
      await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } else {
      _mockUser = MockUser();
      _mockUserStreamController.add(_mockUser);
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    } else {
      _mockUser = null;
      _mockUserStreamController.add(_mockUser);
    }
  }

  Future<void> signInWithGoogle() async {
    if (_auth != null) {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? DefaultFirebaseOptions.googleClientId : null,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth!.signInWithCredential(credential);
      }
    } else {
      _mockUser = MockUser();
      _mockUserStreamController.add(_mockUser);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
