class CloudStorageException implements Exception {
  const CloudStorageException();
}
// Custom exceptions will inherit CloudStorageException
class CouldNotCreateNoteException implements CloudStorageException {}

class CouldNotGetAllNotesException implements CloudStorageException {}

class CouldNotUpdateNoteException implements CloudStorageException {}

class CouldNotDeleteNoteException implements CloudStorageException {}
