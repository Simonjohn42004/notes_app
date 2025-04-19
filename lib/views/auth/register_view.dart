import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          devtools.log("coming here because of the error");
          if (!context.mounted) return;
          devtools.log("has passed the above if statement");
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak Password");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email Already in use");
          } else if (state.exception is GenericAuthException) {
            devtools.log("i am in generic auth exception");
            await showErrorDialog(context, "Failed to register");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid email");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Register", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "Enter Email"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(hintText: "Enter Password"),
            ),
            TextButton(
              onPressed: () {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(
                  AuthEventRegister(email, password),
                );
              },
              child: Text("Register"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: Text("Already registered? Login here!"),
            ),
          ],
        ),
      ),
    );
  }
}
