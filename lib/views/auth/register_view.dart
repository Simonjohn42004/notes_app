import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_service.dart';
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
    return Scaffold(
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
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                if (!context.mounted) return;
                await AuthService.firebase().sendEmailVerification();
                if (!context.mounted) return;
                Navigator.of(context).pushNamed(verfiyEmailRoute);
              } on WeakPasswordAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "Weak Password! Please try again",
                );
              } on EmailAlreadyInUseAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "Email already in use, please try an email that is not registered",
                );
              } on InvalidEmailAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "Invalid email! please enter a proper email",
                );
              } on GenericAuthException catch (_) {
                await showErrorDialog(
                  context,
                  "An unknown authentication error occured",
                );
              }
            },
            child: Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: Text("Already registered? Login here!"),
          ),
        ],
      ),
    );
  }
}
