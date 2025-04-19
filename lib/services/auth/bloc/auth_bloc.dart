import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'dart:developer' as devtools show log;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(AuthStateRegistering(null));
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        devtools.log("Register failure");
        provider.sendEmailVerification();
        emit(AuthStateNeedsVerification());
      } on Exception catch (e) {
        devtools.log(e.toString());
        emit(AuthStateRegistering(e));
      }
    });

    // initialise event
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialise();
      final user = provider.user;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    // login event
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
      final String email = event.email;
      final String password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);
        if (user.isEmailVerified) {
          emit(AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateNeedsVerification());
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
