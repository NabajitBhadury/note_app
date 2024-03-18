import 'package:flutter/material.dart';
import 'package:noteapp/utilities/dialogs/show_generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occoured',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
