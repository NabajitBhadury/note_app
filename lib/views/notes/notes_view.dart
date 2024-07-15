import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/services/auth/auth_service.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/auth/bloc/auth_state.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:noteapp/services/cloud/firebase_cloud_storage.dart';
import 'package:noteapp/utilities/dialogs/logout_dialog.dart';
import 'package:noteapp/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  // Get the user email from the firebase user so that we should have the notes of the user with the corresponding logged in gmail
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // Create an instance of the notes service class
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/icon/icon.png')),
            ),
            const SizedBox(
              width: 10,
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthStateLoggedIn) {
                  return Text(
                    'Welcome, ${state.user.userName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  );
                } else {
                  return const Text(
                    'Your Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
                // ignore: use_build_context_synchronously
                context.read<AuthBloc>().add(const AuthEventLogout());
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Your Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _notesService.allNotes(
                  ownerUserId:
                      userId), // this will get all the notes from the notes stream controller
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      return NotesListView(
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                          );
                        },
                        notes: allNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                            documentId: note.documentId,
                          );
                        },
                        onPinNote: (CloudNote note) async {
                          await _notesService.updateNote(
                            documentId: note.documentId,
                            text: note.text,
                            title: note.title,
                            isPinned: !note.isPinned,
                          );
                          setState(() {});
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            createOrUpdateNoteRoute,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
