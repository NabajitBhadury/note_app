import 'package:flutter/material.dart';

void Function() showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(
          height: 10,
        ),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: false,
  );
  return Navigator.of(context).pop;
}
