import 'dart:convert';
import 'package:notes_basic/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesDatabase {
  static const String _notesKey = "notes";

  /// Guarda una nueva nota en SharedPreferences
  Future<void> addNote(NoteModel note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    notes.add(note);

    final notesJson = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesJson));
  }

  /// Obtiene todas las notas
  Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString(_notesKey);

    if (notesString == null) return [];

    final List<dynamic> notesJson = jsonDecode(notesString);
    final notes = notesJson.map((json) => NoteModel.fromJson(json)).toList();

    // Ordenar por fecha de actualización (más reciente primero)
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return notes;
  }

  /// Actualiza una nota sin perder datos previos
  Future<void> updateNote(NoteModel updatedNote) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    final index = notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      final existingNote = notes[index];

      // Solo reemplaza los campos no vacíos/nulos
      notes[index] = existingNote.copyWith(
        title:
            updatedNote.title.isNotEmpty
                ? updatedNote.title
                : existingNote.title,
        content:
            updatedNote.content.isNotEmpty
                ? updatedNote.content
                : existingNote.content,
        updatedAt: DateTime.now(),
      );
    }

    final notesJson = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesJson));
  }

  /// Elimina múltiples notas por sus IDs
  Future<void> deleteNotes(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await getNotes();

    notes.removeWhere((n) => ids.contains(n.id));

    final notesJson = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_notesKey, jsonEncode(notesJson));
  }
}
