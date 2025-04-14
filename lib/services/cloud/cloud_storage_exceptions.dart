class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

//implementing the CRUD exceptions here using the super class CloudStorageExcepttions
class CouldNotCreateNoteException extends CloudStorageExceptions {}

class CouldNotGetAllNotesException extends CloudStorageExceptions {}

class CouldNotUpdateNoteException extends CloudStorageExceptions {}

class CouldNotDeleteNoteException extends CloudStorageExceptions {}
