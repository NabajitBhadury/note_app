import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/utilities/dialogs/show_delete_dialog.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:share_plus/share_plus.dart';

class NotesListView extends StatelessWidget {
  // This will require the iterable of database notes and a void function that takes parameter databasenote
  final Iterable<CloudNote> notes;
  final void Function(CloudNote note)
      onDeleteNote; // this function is used to delete the notes at the specific index fo database note
  final void Function(CloudNote note) onTap;
  // final void Function(CloudNote note) onLongTap;

  final void Function(CloudNote note) onPinNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onPinNote,
  });

  @override
  Widget build(BuildContext context) {
    final sortedNote = notes.toList()
      ..sort(
        (a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0;
        },
      );
    return MasonryGridView.builder(
      itemCount: notes
          .length, //not to make the listview builder infinite we should have to give the item count
      itemBuilder: (context, index) {
        final note = sortedNote[index]; // show the note based on the index
        final creationDate = note.createdAt;
        return ContextMenuRegion(
          contextMenu: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GenericContextMenu(
              buttonConfigs: [
                ContextMenuButtonConfig(note.isPinned ? 'Unpin' : 'Pin',
                    onPressed: () {
                  onPinNote(note);
                },
                    icon: note.isPinned
                        ? const Icon(Icons.push_pin)
                        : const Icon(Icons.push_pin_outlined)),
                ContextMenuButtonConfig(
                  'Share',
                  onPressed: () {
                    String title = note.title;
                    String body = note.text;
                    Share.share('$title \n \n $body');
                  },
                  icon: const Icon(Icons.share),
                ),
                ContextMenuButtonConfig(
                  'Delete',
                  onPressed: () async {
                    final shouldDeleteNote = await showDeleteDialog(context);
                    if (shouldDeleteNote) {
                      onDeleteNote(note);
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.blue[100 * (index % 9 + 1)],
                child: ListTile(
                  onTap: () {
                    onTap(note);
                  },
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        note.text,
                        maxLines: 8,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(creationDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
    );
  }
}
