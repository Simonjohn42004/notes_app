import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing Note",
    content: "You cannot share an empty note",
    optionsBuilder: () {
      return {"OK": null};
    },
  );
}
