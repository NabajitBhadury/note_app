import 'package:flutter/widgets.dart';
import 'package:noteapp/utilities/dialogs/show_generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Password Reset',
      content:
          'We have now sent you a password reset link. Please check your email for more information',
      optionsBuilder: () => {
            'OK': null,
          });
}
