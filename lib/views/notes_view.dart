// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_services.dart';
import 'note_editor_view.dart';

const Color kLightGray = Color(0xFFF9F9F9);

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  bool isLoading = true;
  List<NoteModel> notes = const [];
  bool isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  /// 📥 Obtiene todas las notas almacenadas
  void _fetchNotes() async {
    final response = await NotesService().getNotes();
    notes = response;
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: WillPopScope(
        // 🔙 Si está en modo eliminar, al retroceder se desactiva en lugar de cerrar la vista
        onWillPop: () async {
          if (isDeleteMode) {
            notes = notes.map((e) => e.copyWith(isSelected: false)).toList();
            isDeleteMode = false;
            setState(() {});
            return false;
          }
          return false;
        },
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                shadowColor: Colors.black12,
                elevation: 4,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text('My Notes'),
              ),
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          itemCount: notes.length,
                          padding: const EdgeInsets.all(20),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemBuilder: (_, index) {
                            final note = notes[index];

                            final backgroundCard =
                                note.isSelected
                                    ? Color(0xFFC9C9C9)
                                    : kLightGray;

                            return GestureDetector(
                              onTap: () {
                                if (isDeleteMode) {
                                  _toggleSelection(note);
                                } else {
                                  _openEditor(note: note);
                                }
                              },
                              onLongPress: () {
                                _toggleSelection(note);
                              },
                              child: Card(
                                shadowColor: Colors.black12,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: backgroundCard,
                                surfaceTintColor: backgroundCard,
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Column(
                                    spacing: 7,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          note.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          note.content,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          _formatDate(note.updatedAt),
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isDeleteMode) {
            final selectedNotes = notes.where((e) => e.isSelected).toList();
            await NotesService().deleteNotes(selectedNotes);
            _fetchNotes();
            isDeleteMode = false;
          } else {
            _openEditor();
          }
        },
        backgroundColor: isDeleteMode ? Colors.red : null,
        child:
            isDeleteMode
                ? const Icon(Icons.delete_outline_rounded, color: Colors.white)
                : const Icon(Icons.add),
      ),
    );
  }

  /// 🔘 Alterna la selección de una nota (para borrado múltiple)
  void _toggleSelection(NoteModel note) {
    notes =
        notes.map((e) {
          if (e.id == note.id) {
            return note.copyWith(isSelected: !e.isSelected);
          }
          return e;
        }).toList();

    isDeleteMode = notes.any((e) => e.isSelected);
    setState(() {});
  }

  /// 📝 Abre el editor de notas para crear o editar
  void _openEditor({NoteModel? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteEditorView(note: note, refreshNotes: _fetchNotes),
      ),
    );
  }

  /// 📅 Formatea la fecha en dd / mm / yy
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return "$day / $month / $year";
  }
}
