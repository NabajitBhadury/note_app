// Here we have taken two typedefs for the functions that will be passed to the LoadingScreenController

import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close; // This close function will be used to close the loading screen
  final UpdateLoadingScreen update; // This update function will take a string text and will update the loading screen with that text

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
