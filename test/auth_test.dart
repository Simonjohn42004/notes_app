import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if not initialised", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Should be able to be initialised", () async {
      await provider.initialise();
      expect(provider.isInitialized, true);
    });

    test("User should be null upon initialization", () {
      expect(provider.user, null);
    });

    test(
      "Should be able to initialse in 2 seconds",
      () async {
        await provider.initialise();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 3)),
    );

    test("Create user should deleate logIn function", () async {
      await provider.initialise();

      expect(
        provider.createUser(email: "foo@bar.com", password: "hellosimon"),
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      expect(
        provider.createUser(email: "somethign@gmail.com", password: "foobar"),
        throwsA(TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(
        email: "something@gmail.com",
        password: "somethingissomething",
      );
      expect(provider.user, user);

      expect(user.isEmailVerified, false);
    });

    test("login user should be able to get verfied", () async {
      await provider.sendEmailVerification();
      final user = provider.user;
      expect(user, isNotNull);

      expect(user?.isEmailVerified, true);
    });

    test("should be able to logout and login again", () async {
      await provider.logOut();
      await provider.logIn(email: "something", password: "also something");

      final user = provider.user;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  Future<void> initialise() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (email == "foo@bar.com") {
      throw UserNotFoundAuthException();
    }
    if (password == "foobar") {
      throw WrongPasswordAuthException();
    }
    const user = AuthUser(isEmailVerified: false, email: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (_user == null) {
      throw UserNotFoundAuthException();
    }
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    }
    const newUser = AuthUser(isEmailVerified: true, email: 'something@gmail.com');
    _user = newUser;
  }

  @override
  AuthUser? get user => _user;
}
