import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp();
    });

    setUp(() {
      authService = AuthService();
    });

    test('should have no current user initially', () {
      expect(authService.currentUser, isNull);
    });

    test('should provide auth state changes stream', () {
      expect(authService.authStateChanges, isA<Stream<User?>>());
    });

    test('should handle invalid email format', () async {
      try {
        await authService.signInWithEmailAndPassword('invalid-email', 'password');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('email'));
      }
    });

    test('should handle empty password', () async {
      try {
        await authService.signInWithEmailAndPassword('test@example.com', '');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('password'));
      }
    });
  });
} 