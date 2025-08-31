import 'package:flutter/material.dart';
import 'package:notes_basic/models/note_model.dart';

import '../services/notes_services.dart';

class NoteEditorView extends StatefulWidget {
  const NoteEditorView({super.key, this.note, required this.refreshNotes});

  final NoteModel? note;
  final VoidCallback refreshNotes;

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  NoteModel? note;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      note = widget.note;
      titleController = TextEditingController(text: widget.note!.title);
      contentController = TextEditingController(text: widget.note!.content);
    }
  }

  @override
  void dispose() {
    // 🔄 Al cerrar la vista, actualizar la lista de notas en la pantalla anterior
    widget.refreshNotes.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note != null ? 'Edit Note' : 'New Note')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            _inputField(
              hint: 'Note title',
              maxLines: 1,
              controller: titleController,
              onChanged: (value) async {
                final newNote = await NotesService().saveNote(
                  note: note,
                  title: value.isNotEmpty ? value : 'Untitled',
                );
                note = newNote;
                setState(() {});
              },
            ),
            Expanded(
              child: _inputField(
                hint: 'Content',
                controller: contentController,
                onChanged: (value) async {
                  final newNote = await NotesService().saveNote(
                    note: note,
                    content: value.isNotEmpty ? value : 'No content',
                  );
                  note = newNote;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    String hint = '',
    Function(String)? onChanged,
    int? maxLines,
    TextEditingController? controller,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      style: textTheme.bodyMedium,
      onChanged: onChanged?.call,
      maxLines: maxLines,
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodySmall?.copyWith(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }
}
