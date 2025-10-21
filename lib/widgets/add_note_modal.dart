// lib/widgets/add_note_modal.dart
import 'package:flutter/material.dart';
import '../services/note_service.dart';

class AddNoteModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onNoteAdded;

  const AddNoteModal({
    Key? key,
    required this.onNoteAdded,
  }) : super(key: key);

  @override
  _AddNoteModalState createState() => _AddNoteModalState();
}

class _AddNoteModalState extends State<AddNoteModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Reset form state
  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _error = null;
    });
  }

  // Save the new note
  Future<void> _handleSave() async {
    // Basic form validation
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(() {
        _error = 'Please fill in both title and content';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Prepare note data
      final noteData = {
        'title': title,
        'content': content,
        'userId': 'current-user-id', // We'll replace this with actual user ID later
      };

      // Call create note service
      final newNote = await _noteService.createNote(noteData);

      // Reset form
      _resetForm();

      // Notify parent component and close modal
      widget.onNoteAdded(newNote.data);
      Navigator.pop(context);

    } catch (e) {
      print('Error creating note: $e');
      setState(() {
        _error = 'Failed to save note. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add New Note',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Show error message if there is one
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Title input field
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),

          // Content input field
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              hintText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 20),

          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel button
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: Text(_isLoading ? 'Saving...' : 'Save Note'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}