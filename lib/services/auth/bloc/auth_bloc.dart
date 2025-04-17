import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // initialise event
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialise();
      final user = provider.user;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    // login event
    on<AuthEventLogIn>((event, emit) async {
      final String email = event.email;
      final String password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);
        if (user.isEmailVerified) {
          emit(AuthStateLoggedIn(user));
        } else {
          emit(AuthStateNeedsVerification());
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
