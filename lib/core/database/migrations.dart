import 'package:sqflite/sqflite.dart';

/// Database migrations handler.
class AppMigrations {
  AppMigrations._();

  static const int currentVersion = 3;

  /// creation logic (for fresh install).
  static Future<void> onCreate(Database db, int version) async {
    // V1 Tables (Legacy)
    await db.execute('''
      CREATE TABLE micro_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        duration_minutes INTEGER NOT NULL,
        energy_level TEXT NOT NULL,
        category TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE micro_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        result_type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE energy_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        energy_level INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE planned_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        estimated_duration INTEGER,
        priority TEXT NOT NULL,
        optimal_energy_level TEXT,
        scheduled_for TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        completed_at TEXT
      )
    ''');

    // V2 Tables (Energy Planner)
    await _createV2Tables(db);

    // V3 Updates (Foundation)
    await _applyV3Changes(db);
  }

  /// Upgrade logic.
  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
    if (oldVersion < 3) {
      await _applyV3Changes(db);
    }
  }

  static Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS learning_goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_outcome TEXT,
        deadline TEXT NOT NULL,
        total_effort_minutes INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS planner_tasks (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        description TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        energy_requirement TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        original_day_index INTEGER NOT NULL,
        current_day_index INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES learning_goals(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS task_dependencies (
        task_id TEXT NOT NULL,
        depends_on_task_id TEXT NOT NULL,
        PRIMARY KEY (task_id, depends_on_task_id),
        FOREIGN KEY (task_id) REFERENCES planner_tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (depends_on_task_id) REFERENCES planner_tasks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_energy_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id TEXT NOT NULL,
        date TEXT NOT NULL,
        reported_energy TEXT NOT NULL,
        recorded_at TEXT NOT NULL,
        UNIQUE(goal_id, date),
        FOREIGN KEY (goal_id) REFERENCES learning_goals(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS timeline_snapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id TEXT NOT NULL,
        version INTEGER NOT NULL,
        snapshot_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES learning_goals(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _applyV3Changes(Database db) async {
    // Add columns to planner_tasks
    // Check if column exists first to avoid error if re-running (though onUpgrade shouldn't re-run)
    // SQLite doesn't support IF NOT EXISTS for ADD COLUMN easily, but we assume strict versioning.
    try {
      await db.execute('ALTER TABLE planner_tasks ADD COLUMN title TEXT');
      await db.execute(
        'UPDATE planner_tasks SET title = description',
      ); // Backfill
    } catch (_) {
      // Column might already exist if we are developing
    }

    // New Tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS timeline_buckets (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        label TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES learning_goals(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS task_timeline_mappings (
        task_id TEXT NOT NULL,
        bucket_id TEXT NOT NULL,
        position_index INTEGER NOT NULL,
        PRIMARY KEY (task_id, bucket_id),
        FOREIGN KEY (task_id) REFERENCES planner_tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (bucket_id) REFERENCES timeline_buckets(id) ON DELETE CASCADE
      )
    ''');
  }
}
