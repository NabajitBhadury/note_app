import 'package:flutter/material.dart';
import 'package:noteapp/extensions/list/buildcontext/loc.dart';
import 'package:noteapp/utilities/dialogs/show_generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true
    }, // in the option builder we send here the map of text and bool which goes for the type T
  ).then(
    (value) => value ?? false,
  ); // this then is used as if nothing is send in the value it will take the value as false else it will take the value as true
}
