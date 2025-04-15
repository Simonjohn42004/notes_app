import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/cloud_storage_exceptions.dart';
import 'cloud_storage_constants.dart';

class FirebaseCloudStorage {
  static final shared = FirebaseCloudStorage._();
  FirebaseCloudStorage._();
  factory FirebaseCloudStorage() => shared;

  final notes = FirebaseFirestore.instance.collection("notes");

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
    final note = await document.get();
    return CloudNote(documentId: note.id, ownerUserId: ownerUserId, text: "");
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((note) {
              return CloudNote.fromSnapshot(note);
            }),
          );
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) {
      return event.docs
          .map((note) {
            return CloudNote.fromSnapshot(note);
          })
          .where((note) {
            return note.ownerUserId == ownerUserId;
          });
    });
  }

  Future<void> updateNotes({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
}
