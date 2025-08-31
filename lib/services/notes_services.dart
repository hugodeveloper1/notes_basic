import 'package:notes_basic/models/note_model.dart';
import '../database/notes_database.dart';

class NotesService {
  final _db = NotesDatabase();

  /// Crear o actualizar una nota
  Future<NoteModel> saveNote({
    NoteModel? note,
    String title = '',
    String content = '',
  }) async {
    if (note == null) {
      // Crear nueva nota
      final newNote = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.addNote(newNote);
      return newNote;
    } else {
      // Actualizar nota existente
      final updatedNote = note.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      await _db.updateNote(updatedNote);
      return updatedNote;
    }
  }

  /// Obtener todas las notas
  Future<List<NoteModel>> getNotes() async {
    return await _db.getNotes();
  }

  /// Eliminar una nota
  Future<void> deleteNote(List<NoteModel> notes) async {
    final ids = notes.map((e) => e.id).toList();
    await _db.deleteNotes(ids);
  }
}
