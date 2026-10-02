import 'package:auth/auth.dart' as module;
import 'package:auth/data/services/auth_service_imp.dart';
import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

class _Logger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(di.reset);
  test('service reads injected identity and awaits sign-out', () async {
    final auth = _Auth();
    final user = _User();
    final service = AuthServiceImp(firebaseAuth: auth, logger: _Logger());
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('test-user');
    when(auth.signOut).thenAnswer((_) async {
      when(() => auth.currentUser).thenReturn(null);
    });
    expect(service.uid, 'test-user');
    expect(service.isSignedIn, isTrue);
    await service.signOut();
    expect(service.uid, isEmpty);
    expect(service.isSignedIn, isFalse);
    verify(auth.signOut).called(1);
  });

  test('SDK sign-out errors remain visible to the caller', () async {
    final auth = _Auth();
    final error = FirebaseAuthException(code: 'network-request-failed');
    when(auth.signOut).thenThrow(error);
    final service = AuthServiceImp(firebaseAuth: auth, logger: _Logger());
    await expectLater(service.signOut(), throwsA(same(error)));
  });

  test(
    'deleteAccount deletes the signed-in user; none signed in is a no-op',
    () async {
      final auth = _Auth();
      final user = _User();
      final service = AuthServiceImp(firebaseAuth: auth, logger: _Logger());
      when(() => auth.currentUser).thenReturn(null);
      await service.deleteAccount();
      when(() => auth.currentUser).thenReturn(user);
      when(user.delete).thenAnswer((_) async {});
      await service.deleteAccount();
      verify(user.delete).called(1);
    },
  );

  test('deleteAccount failures (recent login required) are logged and '
      'rethrown', () async {
    final auth = _Auth();
    final user = _User();
    final logger = _Logger();
    final error = FirebaseAuthException(code: 'requires-recent-login');
    when(() => auth.currentUser).thenReturn(user);
    when(user.delete).thenThrow(error);
    final service = AuthServiceImp(firebaseAuth: auth, logger: logger);
    await expectLater(service.deleteAccount(), throwsA(same(error)));
    verify(() => logger.e(any(), error, any())).called(1);
  });

  test(
    'module composes injected SDK and disposes owned token provider',
    () async {
      di.register<Logger>(_Logger());
      final auth = _Auth();
      when(auth.idTokenChanges).thenAnswer((_) => const Stream<User?>.empty());
      await module.init(
        module.DefaultAuthConfig(clientId: 'client-id'),
        firebaseAuth: auth,
        configureProviders: (providers) =>
            expect(providers.length, greaterThanOrEqualTo(2)),
      );
      expect(di.get<module.AuthService>(), isA<AuthServiceImp>());
      final tokens = di.get<AuthTokenProvider>();
      await di.reset();
      expect(tokens.isAuthenticated, isFalse);
    },
  );
}
