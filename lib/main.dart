import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/helpers/loading/loading_screen.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/auth/bloc/auth_state.dart';
import 'package:noteapp/services/auth/firebase_auth_provider.dart';
import 'package:noteapp/views/email_verification_view.dart';
import 'package:noteapp/views/login_view.dart';
import 'package:noteapp/views/notes/create_update_note_view.dart';
import 'package:noteapp/views/notes/notes_view.dart';
import 'package:noteapp/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
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
