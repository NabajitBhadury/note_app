// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/enums/menu_action.dart';
import 'package:noteapp/services/auth/auth_service.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:noteapp/services/cloud/firebase_cloud_storage.dart';
import 'package:noteapp/utilities/dialogs/logout_dialog.dart';
import 'package:noteapp/utilities/dialogs/show_delete_dialog.dart';
import 'package:noteapp/views/notes/notes_list_view.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';

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
        title: const Text('Your Notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(
            ownerUserId:
                userId), // this will get all the notes from the notes stream controlller
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
                  onLongTap: (note) {
                    _showSubMenu(context);
                  },
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(
                      documentId: note.documentId,
                    );
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



void _showSubMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        const Rect.fromLTWH(100, 100, 200, 200),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Text('Option 1'),
          onTap: ()async{
            final shouldDeleteNote = await showDeleteDialog(context);
            if(shouldDeleteNote){
              deleteNote();
            }
          },
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Option 2'),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text('Option 3'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        print('Selected option: $value');
        // Handle the selected option here
      }
    });
  }
