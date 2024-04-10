// This will contain the events that will be used to trigger the state changes in the AuthBloc.

import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// For login we will need email and password.
class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogin(this.email, this.password);
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}
