import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

/// SQLite database service for local-first persistence.
///
/// Wraps [AppDatabase] for backward compatibility.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  /// Get the database instance.
  Future<Database> get database => AppDatabase.instance.database;

  /// Initialize the database service.
  Future<void> initialize() async {
    await AppDatabase.instance.initialize();
  }
}
