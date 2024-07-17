import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/constants/routes/routes.dart';
import 'package:noteapp/services/auth/auth_service.dart';
import 'package:noteapp/services/auth/bloc/auth_bloc.dart';
import 'package:noteapp/services/auth/bloc/auth_event.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:noteapp/services/cloud/firebase_cloud_storage.dart';
import 'package:noteapp/utilities/dialogs/logout_dialog.dart';
import 'package:noteapp/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  final String username;
  const NotesView({super.key, required this.username});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  bool _isSearchVisible = false;
  late final TextEditingController _searchKeyController;
  String _searchQuery = '';

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    super.initState();
    _searchKeyController = TextEditingController();
    _searchKeyController.addListener(_onSearchTextChanged);
    _notesService = FirebaseCloudStorage();
  }

  @override
  void dispose() {
    _searchKeyController.removeListener(_onSearchTextChanged);
    _searchKeyController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {
      _searchQuery = _searchKeyController.text.toLowerCase();
      print('Search query: $_searchQuery');
    });
  }

  List<CloudNote> _filterNotes(List<CloudNote> notes, String queryText) {
    if (queryText.isEmpty) {
      return notes;
    } else {
      return notes
          .where((note) =>
              note.title.toLowerCase().contains(queryText) ||
              note.text.toLowerCase().contains(queryText))
          .toList();
    }
  }

  // Get the user email from the firebase user so that we should have the notes of the user with the corresponding logged in gmail

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchKeyController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : Row(
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
                  Text(
                    'Welcome ${widget.username}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  )
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                _searchQuery = '';
                _searchKeyController.clear();
              });
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () async {
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
                // ignore: use_build_context_synchronously
                context.read<AuthBloc>().add(const AuthEventLogout());
              }
            },
            icon: const Icon(Icons.logout),
          ),
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
                      final filteredNotes =
                          _filterNotes(allNotes.toList(), _searchQuery);
                      return NotesListView(
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                          );
                        },
                        notes: filteredNotes,
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
                        searchQuery: _searchQuery,
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
