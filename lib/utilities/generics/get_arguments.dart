import 'package:flutter/material.dart' show BuildContext, ModalRoute;

// Here in this code we make an extension that takes an optional argument T and checks that is this argument matches with the argument which we are expecting to pass if both the type are same return the argument else return null
extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
