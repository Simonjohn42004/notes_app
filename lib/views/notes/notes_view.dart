import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/notes_service.dart';
import 'package:notes_app/utilities/dialogs/logout_dialog.dart';
import 'package:notes_app/utilities/menu_options.dart';
import 'package:notes_app/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().user!.email!;
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: Icon(Icons.add),
          ),

          PopupMenuButton<MenuOptions>(
            onSelected: (value) async {
              devtools.log(value.toString());
              switch (value) {
                case MenuOptions.logOut:
                  bool shouldLogOut = await showLogoutDialog(context);
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        devtools.log(allNotes.toString());
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async{
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
