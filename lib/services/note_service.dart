// lib/services/note_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_config.dart';

class NoteService {
  final Client _client = getClient();
  late final Databases _databases;

  NoteService() {
    _databases = Databases(_client);
  }

  // Get all notes, potentially filtered by userId
  Future<List<Document>> getNotes({String? userId}) async {
    try {
      // Create query list - initially empty
      List<String> queries = [];

      // If userId is provided, add a filter
      if (userId != null) {
        queries.add(Query.equal('userId', userId));
      }

      // Add sorting by createdAt descending
      queries.add(Query.orderDesc('createdAt'));

      // Fetch documents from the database
      final response = await _databases.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        queries: queries,
      );

      return response.documents;
    } catch (e) {
      print('Error getting notes: $e');
      throw e;
    }
  }

  // Create a new note
  Future<Document> createNote(Map<String, dynamic> data) async {
    try {
      // Add timestamps to the note data
      final noteData = {
        ...data,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Create a document in the database
      final response = await _databases.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: ID.unique(), // Generate a unique ID
        data: noteData,
      );

      return response;
    } catch (e) {
      print('Error creating note: $e');
      throw e;
    }
  }

  // Delete a note by ID
  Future<bool> deleteNote(String noteId) async {
    try {
      // Delete the document with the specified ID
      await _databases.deleteDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: noteId,
      );

      return true;
    } on AppwriteException catch (e) {
      // If the document is not found (already deleted), treat as success (idempotent delete)
      final message = e.message?.toString() ?? '';
      if (message.contains('document_not_found') || (e.code != null && e.code == 404)) {
        // ignore: avoid_print
        print('Delete requested for non-existing document (treated as success): $noteId');
        return true;
      }
      // Other Appwrite exceptions should be rethrown
      // ignore: avoid_print
      print('Error deleting note: $e');
      throw e;
    } catch (e) {
      print('Error deleting note: $e');
      throw e;
    }
  }

  // Update an existing note
  Future<Document> updateNote(String noteId, Map<String, dynamic> data) async {
    try {
      // Add updated timestamp
      final noteData = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update the document in the database
      final response = await _databases.updateDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        documentId: noteId,
        data: noteData,
      );

      return response;
    } catch (e) {
      print('Error updating note: $e');
      throw e;
    }
  }
}