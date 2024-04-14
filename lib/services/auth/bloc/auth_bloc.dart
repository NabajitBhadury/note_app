// Here we will have the logic of the AuthBloc i.e. the things that will be done in the background using the auth state and auth event and do all the things here.

import 'package:bloc/bloc.dart';
import 'package:noteapp/services/auth/auth_provider.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Here we are initializing the AuthBloc with the AuthProvider and the initial state of the bloc is AuthStateLoading.
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUniniatlzied(
          isLoading: true,
        )) {
    // Forgot Password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        isLoading: false,
        exception: null,
        hasSentEmail: false,
      ));
      final email = event.email;
      if (email == null) {
        return; // User just wants to go to the forgot password screen
      }
      // User has entered an email and wants to reset the password
      emit(const AuthStateForgotPassword(
        isLoading: true,
        exception: null,
        hasSentEmail: false,
      ));

      bool didSendEmail;
      Exception? exception;
      // Now send the password reset email
      try {
        await provider.sendPasswordReset(
          toEmail: email,
        );
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        exception = e;
        didSendEmail = false;
      }
      // Emit the state with the result of the email sending
      emit(AuthStateForgotPassword(
        isLoading: false,
        exception: exception,
        hasSentEmail: didSendEmail,
      ));
    });

    // Go back to the registration screen
    on<AuthEventShouldRegister>((event, emit) {
      emit(
        const AuthStateRegistering(
          isLoading: false,
          exception: null,
        ),
      );
    });

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      // For email verification, we are sending an email verification to the user and then emitting the current state as email verification dosen't gives any other state.
      emit(state);
    });

    //auth evenet register

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(
          const AuthStateNeedsVerification(isLoading: false),
        );
      } on Exception catch (e) {
        emit(
          AuthStateRegistering(exception: e, isLoading: false),
        );
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    on<AuthEventLogin>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while we log you in'),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLoggedOut(exception: null, isLoading: false),
          );
        }
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          isLoading: false,
          exception: e,
        ));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logout();
        emit(
          const AuthStateLoggedOut(exception: null, isLoading: false),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(exception: e, isLoading: false),
        );
      }
    });
  }
}
