import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/helpers/loading/loading_screen.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/auth/bloc/auth_state.dart';
import 'package:noteapp/services/auth/firebase_auth_provider.dart';
import 'package:noteapp/views/email_verification_view.dart';
import 'package:noteapp/views/forgot_password_view.dart';
import 'package:noteapp/views/login_view.dart';
import 'package:noteapp/views/notes/create_update_note_view.dart';
import 'package:noteapp/views/notes/notes_view.dart';
import 'package:noteapp/views/register_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Need to wrap the material app with contextmenuoverlay to show the overlay for note deletion
    return ContextMenuOverlay(
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(57, 62, 65, 1.000)),
          scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 179, 1.000),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(255, 255, 179, 1.000),
          ),
          useMaterial3: true,
        ),
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            FirebaseAuthProvider(),
          ),
          child: const HomePage(),
        ),
        routes: {
          //   loginRoute: (context) => const LoginView(),
          //   registerRoute: (context) => const RegisterView(),
          //   notesRoute: (context) => const NotesView(),
          //   verifyEmailRoute: (context) => const VerifyEmailView(),
          createOrUpdateNoteRoute: (context) => const CreateOrUpdateNoteView(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // first initialize the AuthBloc with the AuthEventInitialize using the read function from the context and then add the event to the bloc
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return NotesView(
          username: state.user.userName ?? 'User',
        );
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
