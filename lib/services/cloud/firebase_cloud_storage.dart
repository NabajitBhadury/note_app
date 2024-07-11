import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noteapp/services/cloud/cloud_note.dart';
import 'package:noteapp/services/cloud/cloud_storage_constants.dart';
import 'package:noteapp/services/cloud/cloud_storage_exception.dart';

class FirebaseCloudStorage {
  // Grab all the firebase notes from the notes collection
  final notes = FirebaseFirestore.instance.collection('notes');

  // Delete the note with the documentId from the notes collection
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // Update the note with the documentId in the notes collection with the text
  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text, titleFieldName: title});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Get the notes of a definite user id from the Stream of all the notes in the notes collection
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => CloudNote.fromSnapshot(doc),
          ),
        );
    return allNotes;
  }

  // Create a new note in the notes collection with the ownerUserId using the add function of firebase
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
      createdAtFieldName: FieldValue.serverTimestamp(),
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '', 
      title: '',
      createdAt: (fetchedNote.get(createdAtFieldName) as Timestamp).toDate(),
    );
  }

  // Make FirebaseCloudStorage a singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
