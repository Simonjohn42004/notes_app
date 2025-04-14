import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/cloud_storage_exceptions.dart';
import 'package:notes_app/services/crud/crud_exceptions.dart';
import 'cloud_storage_constants.dart';

class FirebaseCloudStorage {
  static final shared = FirebaseCloudStorage._();
  FirebaseCloudStorage._();
  factory FirebaseCloudStorage() => shared;

  final notes = FirebaseFirestore.instance.collection("notes");

  void createNewNote({required String ownerUserId}) async {
    await notes.add({ownerUserIdFieldName: ownerUserId, textFieldName: ""});
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((note) {
              return CloudNote(
                documentId: note.id,
                ownerUserId: note.data()[ownerUserIdFieldName] as String,
                text: note.data()[textFieldName] as String,
              );
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
      throw CouldNoteUpdateNote();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNote();
    }
  }
}
