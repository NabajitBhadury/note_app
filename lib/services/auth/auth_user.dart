import 'package:flutter/foundation.dart' show immutable;
import 'package:firebase_auth/firebase_auth.dart' show User;

// Here we abstracted the firebase user with the AuthUser class so that our app directly don't talk to the Firebase and without retreving the firebase user we will hereafter use the AuthUser class

@immutable
class AuthUser {
  final String email;
  final bool isEmailVerified;
  final String id;
  final String? userName;

  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.id,
    this.userName,
  });

  factory AuthUser.fromFirebase(User user, {String? userName}) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email!,
        id: user.uid,
        userName: userName,
      );
}
