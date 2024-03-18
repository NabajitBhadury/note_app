// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:noteapp/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:noteapp/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart' show join;
//
// class NotesService {
//   Database? _db;
//
//   List<DatabaseNote> _notes = [];
//
//   DatabaseUser? _user;
//
//   // Make the noteservice a singleton so that instance of it is created only once
//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//
//   factory NotesService() => _shared;
//
//   // In the streamcontroller we will track the changes that are happening in the notes list
//
//   late final StreamController<List<DatabaseNote>> _notesStreamController;
//
// // Here we will track the changes that are happening in the streamcontroller with the getter
//   Stream<List<DatabaseNote>> get allNotes =>
// // Here in the getter we will filter the notes after grabbing the currentuser and the notes for the current user form the streamcontroller
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       }); // getter for getting the notes form the stream controller but here we need to check if the current user is set or not
//
//   // It will fetch the user or if not the user is created then it will create the user
//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user; // If user is fetched then set it as the current user
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user =
//             createdUser; // here on creation of new user set it as the current user
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // In this method the notes list will be added to the stream so that we can cache the notes in the stream
//   Future<void> _cachedNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }
//
//   // This method will check if the database is open or not and if it is not open then it will throw an exception
//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }
//
//   // Opens the database
//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath =
//           await getApplicationDocumentsDirectory(); // get the documents directory where the notes where the database will be stored
//       final dbPath = join(docsPath.path,
//           dbName); // join the documents directory path with the database name
//       final db =
//           await openDatabase(dbPath); // Using that dbPath open the database
//       _db = db; // Now equate this db with the _db object
//
//       // Execute the SQL command to create the user table using execute method
//       await db.execute(createUserTable);
//       // Execute the SQL command to create the note table using execute method
//       await db.execute(createNoteTable);
//       await _cachedNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
//
//   // Close the database
//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }
//
//   // Delete the user
//   Future<void> deleteUser({required String email}) async {
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where:
//           'email = ?', // delete the user on the basis of email quering the user table
//       whereArgs: [
//         email.toLowerCase(),
//       ],
//     );
//
//     // Check whether the deleted count is 1 or not if it is not 1 then throw an exception
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//
//     // Query the user table to check whether the user already exists or not
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [
//         email.toLowerCase(),
//       ],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//
//     return DatabaseUser(id: userId, email: email);
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [
//         email.toLowerCase(),
//       ],
//     );
//
//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }
//
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final dbUser = await getUser(
//         email: owner
//             .email); // get the user from the database on the basis of email
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }
//
//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//
//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//
//     // After creating the notes cache add it in the list _notes and add this cache list to the stream
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//
//     return note;
//   }
//
//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//
//     if (deletedCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }
//
//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(notesTable);
//     _notes = []; // Reset the local cache and update the StreamController
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }
//
//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     } else {
//       final note = DatabaseNote.fromRow(notes.first);
//
//       // First remove the previous instance of the notes that is already present in the local cache and then then add the fetched notes from the database
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//
//       return note;
//     }
//   }
//
// // This method is used to get all notes from the database
//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(notesTable);
//
//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }
//
//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     // Check if the note exists
//     await getNote(id: note.id);
//     // Update the db
//     final updateCount = db.update(
//       notesTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//
//     if (updateCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }
//
//   // Function to ensuer the database is open so that we call it for every database operation
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }
// }
//
// // Here we made the DatabaseUser class that has two parameters id and email on basis of which the Database table will be created in the database.
//
// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });
//
//   // Here we made a constructor to convert the DatabaseUser object to a map so that it can be stored in the database table.
//
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
//
//   @override
//   String toString() => 'Person, ID = $id, email = $email';
//
// // Here we have implemented the equality operator and hashCode to compare the DatabaseUser objects on the basis of their id so that we can retrieve it in future.
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;
//
//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });
//
//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
//
//   @override
//   String toString() =>
//       'Note, ID = $id, User ID = $userId, Text = $text, isSyncedWithCloud = $isSyncedWithCloud, text = $text';
//
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;
//
//   @override
//   int get hashCode => id.hashCode;
// }
//
// const dbName = 'notes.db';
// const notesTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
//
// // Create the database table using SQL commands
//
// // Creating the user table
// const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user"(
//       "id" INTEGER NOT NULL ,
//       "email" TEXT NOT NULL UNIQUE,
//       PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
//
// // Creating the note table
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
