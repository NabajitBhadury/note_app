// Here we will define the state of the AuthBloc i.e. the things that will be shown in the UI.
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:noteapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait for a moment',
  });
}

class AuthStateUniniatlzied extends AuthState {
  const AuthStateUniniatlzied({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

// AuthStateLoggedIn will hold the user object of the class AuthUser as while loggin in we need the authenticated user.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required isLoading})
      : super(isLoading: isLoading);
}

// Here the auth state will be logged out and we will hold the exception object in case of failure like the user isn't created but is trying to login then at that case the user will get an exception and the state is still loggedout.
// Here we will also hold the isLoading boolean to show the progress indicator based on different states.
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  // Here we have used wquatable mixin to compare the objects using the equality as the isLoading has different works for different app states.
  final Exception? exception;
  // ignore: use_super_parameters
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}
