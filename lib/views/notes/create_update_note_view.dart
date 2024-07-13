import 'package:flutter/material.dart';
import 'package:noteapp/services/auth/auth_service.dart';
import 'package:noteapp/utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:noteapp/utilities/generics/get_arguments.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:noteapp/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateOrUpdateNoteView extends StatefulWidget {
  const CreateOrUpdateNoteView({super.key});

  @override
  State<CreateOrUpdateNoteView> createState() => _CreateOrUpdateNoteViewState();
}

class _CreateOrUpdateNoteViewState extends State<CreateOrUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleContriller;

  @override
  initState() {
    super.initState();
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleContriller = TextEditingController();
    super.initState();
  }

  // This takes the current text editing controller text and update that in the database note by default so that we don't need to save it manually as we don't have any save button
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    final title = _titleContriller.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
      title: title,
      isPinned: note.isPinned,
    );
  }

  // This function will setup the text controller listener so that we can listen to the changes in the text editor needed to do for the autometic updation of the notes and needs to be done else the previous won't work
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleContriller.removeListener(_textControllerListener);
    _titleContriller.addListener(_textControllerListener);
  }

  // This function will check if we have created a note in this view or not if new note is already created then return the note else create a new note so that on every refresh we don't create a new note
  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<
        CloudNote>(); // pass here CloudNote as argument to check with this extension

    // Here using our extension we now check if the widgetNote is not null it means that here is already a note in the database earlier so just return the widgetNote and repopulate the text controller with the text of widget note so that the user can update this note
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleContriller.text = widgetNote.title;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  // If the text inside the text editor is empty then delete the note
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty &&
        _titleContriller.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(
        documentId: note.documentId,
      );
    }
  }

  // Save the note when the user leaves the view if there is any note

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleContriller.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
        title: title,
        isPinned: note.isPinned,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    _titleContriller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
          actions: [
            IconButton(
              onPressed: () async {
                final text = _textController.text;
                final title = _titleContriller.text;
                if (_note == null || text.isEmpty || title.isEmpty) {
                  await showCannotShareEmptyNoteDialog(context);
                } else {
                  final shareContent = '$title\n\n$text';
                  Share.share(shareContent);
                }
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleContriller,
                        decoration: const InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            border: InputBorder.none),
                      ),
                      TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: 'Write your note here...',
                            border: InputBorder.none),
                      ),
                    ],
                  ),
                );

              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
