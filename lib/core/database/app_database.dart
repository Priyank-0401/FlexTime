import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations.dart';

/// Central database access point.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _init();
    return _database!;
  }

  Future<void> initialize() async {
    _database = await _init();
  }

  Future<Database> _init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, 'flextime.db');

    return openDatabase(
      dbPath,
      version: AppMigrations.currentVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: AppMigrations.onCreate,
      onUpgrade: AppMigrations.onUpgrade,
    );
  }
}
