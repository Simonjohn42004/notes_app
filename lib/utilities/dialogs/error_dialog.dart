import 'package:flutter/material.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: "An Error Occured",
    content: text,
    optionsBuilder: () {
      return {"OK" : null};
    },
  );
}
