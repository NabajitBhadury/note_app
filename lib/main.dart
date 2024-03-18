import 'package:flutter/material.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/services/auth/auth_service.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateOrUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize the firebase app within the future of future builder so that we didn't have to initialize the firebase app all the time for asynchronous calls from firebase
      future: AuthService.firebase().initialize(),

      // And in the builder we pass the remaining columns to the future
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
