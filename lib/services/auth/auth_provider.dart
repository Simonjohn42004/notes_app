import 'package:notes_app/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get user;
  Future<AuthUser> logIn({required String email, required String password});
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> initialise();
}
