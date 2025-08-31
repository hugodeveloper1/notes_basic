// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_services.dart';
import 'note_editor_view.dart';

const Color lightGray = Color(0xFFF9F9F9);

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  bool isLoading = true;
  List<NoteModel> notes = const [];
  bool isDelete = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /// 📥 Obtiene todas las notas almacenadas
  void _loadNotes() async {
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
        onWillPop: () async {
          if (isDelete) {
            final list =
                notes.map((e) {
                  return e.copyWith(isSelected: false);
                }).toList();
            notes = list;
            isDelete = false;
            setState(() {});
            return false;
          } else {
            return false;
          }
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
                            final item = notes[index];

                            final backgroundCard =
                                item.isSelected
                                    ? Colors.amberAccent
                                    : lightGray;

                            return GestureDetector(
                              onTap: () {
                                if (isDelete) {
                                  itemSelected(item);
                                } else {
                                  _openEditor(note: item);
                                }
                              },
                              onLongPress: () async {
                                itemSelected(item);
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
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item.content,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          formatDate(item.updatedAt),
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
          if (isDelete) {
            final list = notes.where((e) => e.isSelected).toList();
            await NotesService().deleteNote(list);
            _loadNotes();
            isDelete = false;
          } else {
            _openEditor();
          }
        },
        backgroundColor: isDelete ? Colors.red : null,
        child:
            isDelete
                ? const Icon(Icons.delete_outline_rounded, color: Colors.white)
                : const Icon(Icons.add),
      ),
    );
  }

  void itemSelected(NoteModel note) {
    final list =
        notes.map((e) {
          if (e.id == note.id) {
            final isSelected = e.isSelected;
            return note.copyWith(isSelected: !isSelected);
          }
          return e;
        }).toList();

    notes = list;

    final res = list.where((e) => e.isSelected).toList();

    if (res.isNotEmpty) {
      isDelete = true;
    } else {
      isDelete = false;
    }

    setState(() {});
  }

  /// 📝 Abre el editor de notas para crear o editar
  void _openEditor({NoteModel? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteEditorView(note: note, refreshNotes: _loadNotes),
      ),
    );
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return "$day / $month / $year";
  }
}
