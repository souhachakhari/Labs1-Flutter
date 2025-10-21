// lib/services/database_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_config.dart';

class DatabaseService {
  // Get the Appwrite client from our config
  final Client _client = getClient();
  late final Databases _databases;

  // Constructor initializes the Databases instance
  DatabaseService() {
    _databases = Databases(_client);
  }

  // List all documents/notes in the collection
  Future<List<Document>> listDocuments({List<String>? queries}) async {
    try {
      // Fetch documents from the specified database and collection
      final response = await _databases.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_COLLECTION_ID']!,
        queries: queries,
      );
      // Return the documents list from the response
      return response.documents;
    } catch (e) {
      // Log and rethrow any errors
      print('Error listing documents: $e');
      throw e;
    }
  }
}