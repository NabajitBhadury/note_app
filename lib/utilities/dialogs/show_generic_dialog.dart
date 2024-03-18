import 'package:flutter/material.dart';

// This generic dialog requires two strings title and content and we also pass a build context for sending for the builder and finally we send a function named optionBuilder that takes no parameter but returns a  map with an optional T that stands for the type of the type
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required Map<String, T?> Function() optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          // here the action will expected to determine the text which is displayed in the text button and the action what will be executed on the press of the button so we here send the function options here that is actually a map of string and type which is here determine the action which will be executed
          actions: options.keys.map((optionTitle) {
            final T? value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionTitle),
            );
          }).toList(), // Here now the actons will send the list of widgets so have to convert it to a list
        );
      });
}
