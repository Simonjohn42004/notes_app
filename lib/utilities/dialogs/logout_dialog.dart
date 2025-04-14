import 'package:flutter/widgets.dart';
import 'package:notes_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Log Out",
    content: "Are you sure you want to log out?",
    optionsBuilder: () {
      return {"Cancel": false, "Log out": true};
    },
  ).then((value) => value ?? false);
}
