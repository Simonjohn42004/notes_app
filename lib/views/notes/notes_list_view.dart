import 'package:flutter/material.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/utilities/dialogs/delete_dialog.dart';
// import 'dart:developer' as devtools show log;

typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTapped;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onTapped(note);
          },
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
