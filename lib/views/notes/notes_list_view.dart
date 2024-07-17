import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/utilities/dialogs/show_delete_dialog.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:share_plus/share_plus.dart';

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final void Function(CloudNote note) onDeleteNote;
  final void Function(CloudNote note) onTap;
  final String searchQuery;
  final void Function(CloudNote note) onPinNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onPinNote,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final sortedNotes = notes.toList()
      ..sort(
        (a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0;
        },
      );

    return MasonryGridView.builder(
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        final creationDate = note.createdAt;
        return ContextMenuRegion(
          contextMenu: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GenericContextMenu(
              buttonConfigs: [
                ContextMenuButtonConfig(
                  note.isPinned ? 'Unpin' : 'Pin',
                  onPressed: () {
                    onPinNote(note);
                  },
                  icon: note.isPinned
                      ? const Icon(Icons.push_pin)
                      : const Icon(Icons.push_pin_outlined),
                ),
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
              child: Stack(
                children: [
                  Container(
                    color: Colors.blue[100 * (index % 9 + 1)],
                    child: ListTile(
                      onTap: () {
                        onTap(note);
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildHighlightedText(note.title, 1, isTitle: true),
                          const SizedBox(height: 4),
                          _buildHighlightedText(note.text, 8),
                        ],
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(creationDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Image.asset(
                        'assets/pin.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );
  }

  Widget _buildHighlightedText(String text, int maxLines,
      {bool isTitle = false}) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: isTitle
            ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            : null,
      );
    } else {
      final spans = <TextSpan>[];
      final lowerCaseText = text.toLowerCase();
      final lowerCaseSearchQuery = searchQuery.toLowerCase();
      int start = 0;

      while (start < text.length) {
        final startIndex = lowerCaseText.indexOf(lowerCaseSearchQuery, start);
        if (startIndex == -1) {
          spans.add(TextSpan(text: text.substring(start)));
          break;
        }
        if (startIndex > start) {
          spans.add(TextSpan(text: text.substring(start, startIndex)));
        }
        final endIndex = startIndex + lowerCaseSearchQuery.length;
        spans.add(TextSpan(
          text: text.substring(startIndex, endIndex),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
          ),
        ));
        start = endIndex;
      }

      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: spans,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
