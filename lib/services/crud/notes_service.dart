import 'dart:async';
import 'package:flutter/foundation.dart' show immutable;
import 'package:notes_app/constants/database.dart';
import 'package:notes_app/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNote> _list = [];
  // creating a singleton for the notes service
  static final NotesService _shared = NotesService._();
  NotesService._(){
    _notesStreamController = StreamController.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_list);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final db = await getUser(email: email);
      return db;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    final notes = allNotes.toList();
    _notesStreamController.add(notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(
      noteTable,
      where: "id = ?",
      whereArgs: [note.id],
      {textColumn: text},
    );

    if (updatesCount == 0) {
      throw CouldNoteUpdateNote();
    }
    final newNote = await getNote(id: note.id);

    _list.removeWhere((note) => note.id == newNote.id);
    _list.add(newNote);
    _notesStreamController.add(_list);
    return newNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }

    final note = DatabaseNote.fromRow(notes.first);
    _list.removeWhere((note) => note.id == id);
    _list.add(note);
    _notesStreamController.add(_list);

    return note;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);
    _list = [];
    _notesStreamController.add(_list);

    return deletedCount;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final count = await db.delete(noteTable, where: "id = ?", whereArgs: [id]);
    if (count == 0) {
      throw CouldNotDeleteNote();
    }
    _list.removeWhere((note) => note.id == id);
    _notesStreamController.add(_list);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    //making sure owner exists in the database with the correct id
    if (owner != dbUser) {
      throw CouldNotFindUser();
    }
    const text = "";

    // create the notes

    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
    });

    final note = DatabaseNote(id: noteId, userId: owner.id, text: text);
    _list.add(note);
    _notesStreamController.add(_list);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    int userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    }
    return db;
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException catch (_) {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() {
    return "Person, ID = $id, email = $email";
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;

  DatabaseNote({required this.id, required this.userId, required this.text});

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String;

  @override
  String toString() {
    return "Note, ID = $id, userId = $id, text = $text";
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
