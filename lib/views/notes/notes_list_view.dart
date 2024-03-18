import 'package:flutter/material.dart';
import 'package:noteapp/utilities/dialogs/show_delete_dialog.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';

class NotesListView extends StatelessWidget {
  // This will require the iterable of database notes and a void function that takes parameter databasenote
  final Iterable<CloudNote> notes;
  final void Function(CloudNote note)
      onDeleteNote; // this function is used to delete the notes at the specific index fo database note
  final void Function(CloudNote note) onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes
          .length, //not to make the listview builder infinite we should have to give the item count
      itemBuilder: (context, index) {
        final note = notes.elementAt(index); // show the note based on the index
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
