// Here we will define the state of the AuthBloc i.e. the things that will be shown in the UI.
import 'package:flutter/foundation.dart' show immutable;
import 'package:noteapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

// AuthStateLoggedIn will hold the user object of the class AuthUser as while loggin in we need the authenticated user.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}


class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// Here the auth state will be logged out and we will hold the exception object in case of failure like the user isn't created but is trying to login then at that case the user will get an exception and the state is still loggedout.
class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  const AuthStateLoggedOut(this.exception);
}

// In case of loggin out failure we will hold the exception object.
class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}
