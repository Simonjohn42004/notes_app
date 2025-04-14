import 'package:flutter/widgets.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete Note",
    content: "Do you want to delete this note?",
    optionsBuilder: () {
      return {"Yes": true, "Cancel": false};
    },
  ).then((value) => false,);
}
