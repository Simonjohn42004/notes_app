
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utilities/menu_options.dart';
import 'package:notes_app/utilities/show_logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<MenuOptions>(
            onSelected: (value) async {
              devtools.log(value.toString());
              switch (value) {
                case MenuOptions.logOut:
                  bool shouldLogOut = await showLogOutDialog(context);
                  devtools.log(shouldLogOut.toString());
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuOptions>(
                  value: MenuOptions.logOut,
                  child: Text("Logout"),
                ),
              ];
            },
            color: Colors.white,
            iconColor: Colors.white,
          ),
        ],
      ),
      body: const Text("Hello World"),
    );
  }
}