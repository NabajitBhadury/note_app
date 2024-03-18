import 'package:flutter/material.dart';
import 'package:noteapp/utilities/dialogs/show_generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this note?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true
    }, // in the option builder we send here the map of text and bool which goes for the type T
  ).then(
    (value) => value ?? false,
  ); // this then is used as if nothing is send in the value it will take the value as false else it will take the value as true
}
