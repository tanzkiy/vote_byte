import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _webFallbackMode = false;
  static final Map<String, List<Map<String, dynamic>>> _webStorage = {};
  static bool _webStorageLoaded = false;
  static const String _webStorageKey = 'voting_app_web_storage';

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    _initializeWebFallbackData();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb && _webFallbackMode) {
      // Return a simple mock for web fallback mode
      return _createSimpleMockDatabase();
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      try {
        // Try web SQLite first
        return await databaseFactoryFfiWeb.openDatabase(
          'voting_app.db',
          options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
        );
      } catch (e) {
        print('Warning: Web SQLite failed, using fallback mode: $e');
        _webFallbackMode = true;
        return _createSimpleMockDatabase();
      }
    } else {
      String path = join(await getDatabasesPath(), 'voting_app.db');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    }
  }

  // Create a simple mock database for web fallback
  Database _createSimpleMockDatabase() {
    return SimpleMockDatabase(this);
  }

  void _initializeWebFallbackData() {
    if (_webStorage.isEmpty) {
      // Initialize with default admin user
      _webStorage['users'] = [
        {
          'id': 'admin_001',
          'name': 'Admin User',
          'email': 'admin@byte.edu.ph',
          'password': 'admin123',
          'role': 'admin',
          'hasVoted': 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];

      // Initialize with default candidates
      _webStorage['candidates'] = _getDefaultCandidates();

      // Initialize empty votes
      _webStorage['votes'] = [];
    }
  }

  Future<void> _ensureWebStorageLoaded() async {
    if (!(kIsWeb && _webFallbackMode)) return;
    if (_webStorageLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_webStorageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final users = (decoded['users'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final candidates = (decoded['candidates'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final votes = (decoded['votes'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      _webStorage['users'] = users;
      _webStorage['candidates'] = candidates;
      _webStorage['votes'] = votes;
    } else {
      _initializeWebFallbackData();
      await _persistWebStorage();
    }
    _webStorageLoaded = true;
  }

  Future<void> _persistWebStorage() async {
    if (!(kIsWeb && _webFallbackMode)) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'users': _webStorage['users'] ?? [],
      'candidates': _webStorage['candidates'] ?? [],
      'votes': _webStorage['votes'] ?? [],
    };
    await prefs.setString(_webStorageKey, jsonEncode(data));
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Tables creation for non-web platforms
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          role TEXT DEFAULT 'user',
          hasVoted INTEGER DEFAULT 0,
          createdAt TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS votes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          president TEXT,
          vicePresident TEXT,
          secretary TEXT,
          timestamp TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS candidates (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          year TEXT,
          position TEXT NOT NULL,
          description TEXT,
          imageUrl TEXT
        )
      ''');

      // Insert default data
      await _insertDefaultData(db);
    } catch (e) {
      print('Error in _onCreate: $e');
      rethrow;
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    try {
      // Insert default admin user
      await db.insert('users', {
        'id': 'admin_001',
        'name': 'Admin User',
        'email': 'admin@byte.edu.ph',
        'password': 'admin123',
        'role': 'admin',
        'hasVoted': 0,
        'createdAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Insert default candidates
      final defaultCandidates = [
        {
          'id': 'president_001',
          'name': 'Jich Polking',
          'year': 'BSIT 3A',
          'position': 'President',
          'description':
              'Experienced leader with strong organizational skills and vision for the future.',
          'imageUrl': 'https://picsum.photos/id/1005/150/150',
        },
        {
          'id': 'president_002',
          'name': 'Jerusalem Chocyagan',
          'year': 'BSIT 3A',
          'position': 'President',
          'description':
              'Dedicated student advocate with innovative ideas for campus improvement.',
          'imageUrl': 'https://picsum.photos/id/1006/150/150',
        },
        {
          'id': 'vp_001',
          'name': 'Gerlex Balacwid',
          'year': 'BSIT 3B',
          'position': 'Vice-President',
          'description':
              'Strong communicator with experience in student government.',
          'imageUrl': 'https://picsum.photos/id/1007/150/150',
        },
        {
          'id': 'vp_002',
          'name': 'Jhed Coyasan',
          'year': 'BSIT 3B',
          'position': 'Vice-President',
          'description':
              'Collaborative leader focused on student engagement and activities.',
          'imageUrl': 'https://picsum.photos/id/1008/150/150',
        },
        {
          'id': 'secretary_001',
          'name': 'Lexbere Curugan',
          'year': 'BSIT 2A',
          'position': 'Secretary',
          'description':
              'Detail-oriented organizer with excellent record-keeping skills.',
          'imageUrl': 'https://picsum.photos/id/1009/150/150',
        },
        {
          'id': 'secretary_002',
          'name': 'Walem Paul Polo',
          'year': 'BSIT 2A',
          'position': 'Secretary',
          'description':
              'Efficient administrator with strong communication abilities.',
          'imageUrl': 'https://picsum.photos/id/1010/150/150',
        },
      ];

      for (final candidate in defaultCandidates) {
        await db.insert(
          'candidates',
          candidate,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (e) {
      print('Warning: Could not insert default data: $e');
    }
  }

  // ----------------- Users -----------------
  Future<void> insertUser(Map<String, dynamic> user) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      _webStorage['users']!.add(user);
      await _persistWebStorage();
      return;
    }

    final db = await database;
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final users = _webStorage['users'] ?? [];
      try {
        return users.firstWhere((user) => user['email'] == email);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final users = _webStorage['users'] ?? [];
      try {
        return users.firstWhere((user) => user['id'] == userId);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      return _webStorage['users'] ?? [];
    }

    final db = await database;
    return await db.query('users');
  }

  Future<void> updateUser(String userId, Map<String, Object> data) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final users = _webStorage['users'] ?? [];
      for (int i = 0; i < users.length; i++) {
        if (users[i]['id'] == userId) {
          users[i].addAll(data);
          break;
        }
      }
      await _persistWebStorage();
      return;
    }

    final db = await database;
    final updateData = <String, Object?>{};
    data.forEach((k, v) => updateData[k] = v);
    await db.update('users', updateData, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> updateUserHasVoted(String userId, bool hasVoted) async {
    return await updateUser(userId, {'hasVoted': hasVoted ? 1 : 0});
  }

  // ----------------- Candidates -----------------
  Future<List<Map<String, dynamic>>> getCandidates() async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      return _webStorage['candidates'] ?? _getDefaultCandidates();
    }

    final db = await database;
    return await db.query('candidates');
  }

  Future<List<Map<String, dynamic>>> getCandidatesByPosition(
    String position,
  ) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final candidates = _webStorage['candidates'] ?? _getDefaultCandidates();
      return candidates.where((c) => c['position'] == position).toList();
    }

    final db = await database;
    return await db.query(
      'candidates',
      where: 'position = ?',
      whereArgs: [position],
    );
  }

  Future<void> insertCandidate(Map<String, dynamic> candidate) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      _webStorage['candidates']!.add(candidate);
      await _persistWebStorage();
      return;
    }

    final db = await database;
    await db.insert(
      'candidates',
      candidate,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCandidate(String candidateId) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final candidates = _webStorage['candidates'] ?? [];
      candidates.removeWhere((c) => c['id'] == candidateId);
      await _persistWebStorage();
      return;
    }

    final db = await database;
    await db.delete('candidates', where: 'id = ?', whereArgs: [candidateId]);
  }

  // ----------------- Votes -----------------
  Future<bool> hasUserVoted(String userId) async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      final votes = _webStorage['votes'] ?? [];
      return votes.any((vote) => vote['userId'] == userId);
    }

    final db = await database;
    final votes = await db.query(
      'votes',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return votes.isNotEmpty;
  }

  Future<void> submitVote(Map<String, Object> voteData) async {
    print(
      'DatabaseHelper.submitVote fallbackMode=$_webFallbackMode mapType=${voteData.runtimeType}',
    );
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      _webStorage['votes']!.add(Map<String, Object>.from(voteData));
      await updateUserHasVoted(voteData['userId'] as String, true);
      await _persistWebStorage();
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      // Convert to Map<String, Object?> to ensure SQLite compatibility
      final convertedData = Map<String, Object>.from(voteData);
      print('txn.insert votes payload type=${convertedData.runtimeType}');

      await txn.insert('votes', convertedData);
      final userUpdate = <String, Object>{'hasVoted': 1};
      print('txn.update users payload type=${userUpdate.runtimeType}');
      await txn.update(
        'users',
        userUpdate,
        where: 'id = ?',
        whereArgs: [voteData['userId']],
      );
    });
  }

  Future<void> insertVote(Map<String, Object> voteData) async {
    return await submitVote(voteData);
  }

  Future<List<Map<String, dynamic>>> getVotes() async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      return _webStorage['votes'] ?? [];
    }

    final db = await database;
    return await db.query('votes');
  }

  Future<Map<String, int>> getVoteResults() async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      return _calculateFallbackResults();
    }

    final db = await database;
    final votes = await db.query('votes');

    final results = <String, int>{};
    for (final vote in votes) {
      // Get all position columns dynamically
      for (final entry in vote.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Only process position columns (skip metadata columns like userId, timestamp)
        if (key != 'userId' && key != 'timestamp' && key != 'id' && 
            value is String && value.isNotEmpty) {
          results[value] = (results[value] ?? 0) + 1;
        }
      }
    }
    return results;
  }

  Future<Map<String, dynamic>> getVotingResults() async {
    final results = await getVoteResults();
    final candidates = await getCandidates();

    final votingResults = <String, dynamic>{};
    int totalVotes = 0;

    // Group results by position
    for (final candidate in candidates) {
      final position = candidate['position'] as String;
      final name = candidate['name'] as String;
      final votes = results[name] ?? 0;

      if (!votingResults.containsKey(position)) {
        votingResults[position] = <String, dynamic>{};
      }

      votingResults[position][name] = votes;
      totalVotes += votes;
    }

    // Add total votes count
    votingResults['totalVotes'] = totalVotes;

    return votingResults;
  }

  Future<void> resetVotes() async {
    if (kIsWeb && _webFallbackMode) {
      await _ensureWebStorageLoaded();
      _webStorage['votes'] = [];

      // Reset all users' hasVoted status
      final users = _webStorage['users'] ?? [];
      for (int i = 0; i < users.length; i++) {
        users[i]['hasVoted'] = 0;
      }
      await _persistWebStorage();
      return;
    }

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('votes');
      await txn.update('users', {'hasVoted': 0});
    });
  }

  // Fallback methods for web
  List<Map<String, dynamic>> _getDefaultCandidates() {
    return [
      {
        'id': 'president_001',
        'name': 'Jich Polking',
        'year': 'BSIT 3A',
        'position': 'President',
        'description':
            'Experienced leader with strong organizational skills and vision for the future.',
        'imageUrl': 'https://picsum.photos/id/1005/150/150',
      },
      {
        'id': 'president_002',
        'name': 'Jerusalem Chocyagan',
        'year': 'BSIT 3A',
        'position': 'President',
        'description':
            'Dedicated student advocate with innovative ideas for campus improvement.',
        'imageUrl': 'https://picsum.photos/id/1006/150/150',
      },
      {
        'id': 'vp_001',
        'name': 'Gerlex Balacwid',
        'year': 'BSIT 3B',
        'position': 'Vice-President',
        'description':
            'Strong communicator with experience in student government.',
        'imageUrl': 'https://picsum.photos/id/1007/150/150',
      },
      {
        'id': 'vp_002',
        'name': 'Jhed Coyasan',
        'year': 'BSIT 3B',
        'position': 'Vice-President',
        'description':
            'Collaborative leader focused on student engagement and activities.',
        'imageUrl': 'https://picsum.photos/id/1008/150/150',
      },
      {
        'id': 'secretary_001',
        'name': 'Lexbere Curugan',
        'year': 'BSIT 2A',
        'position': 'Secretary',
        'description':
            'Detail-oriented organizer with excellent record-keeping skills.',
        'imageUrl': 'https://picsum.photos/id/1009/150/150',
      },
      {
        'id': 'secretary_002',
        'name': 'Walem Paul Polo',
        'year': 'BSIT 2A',
        'position': 'Secretary',
        'description':
            'Efficient administrator with strong communication abilities.',
        'imageUrl': 'https://picsum.photos/id/1010/150/150',
      },
    ];
  }

  Map<String, int> _calculateFallbackResults() {
    final votes = _webStorage['votes'] ?? [];
    final results = <String, int>{};

    for (final vote in votes.cast<Map<String, dynamic>>()) {
      for (final position in ['president', 'vicePresident', 'secretary']) {
        final candidate = vote[position] as String?;
        if (candidate != null && candidate.isNotEmpty) {
          results[candidate] = (results[candidate] ?? 0) + 1;
        }
      }
    }
    return results;
  }
}

// Simple Mock Database that just delegates to our in-memory storage
class SimpleMockDatabase implements Database {
  final DatabaseHelper _helper;

  SimpleMockDatabase(this._helper);

  @override
  Future<void> close() async {}

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (table == 'candidates') {
      final candidates = DatabaseHelper._webStorage['candidates'] ?? [];
      if (whereArgs != null && whereArgs.isNotEmpty) {
        candidates.removeWhere((c) => c['id'] == whereArgs.first);
      }
    } else if (table == 'votes') {
      DatabaseHelper._webStorage['votes'] = [];
    }
    return 0;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    final mockTxn = SimpleMockTransaction();
    return await action(mockTxn);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (table == 'users') {
      final users = DatabaseHelper._webStorage['users'] ?? [];
      if (whereArgs != null && whereArgs.isNotEmpty) {
        for (final user in users) {
          if (user['id'] == whereArgs.first) {
            user.addAll(values);
            break;
          }
        }
      }
    }
    return 1;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (table == 'users') {
      DatabaseHelper._webStorage['users']!.add(values);
    } else if (table == 'candidates') {
      DatabaseHelper._webStorage['candidates']!.add(values);
    } else if (table == 'votes') {
      DatabaseHelper._webStorage['votes']!.add(values);
    }
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'users') {
      final users = DatabaseHelper._webStorage['users'] ?? [];
      if (where != null && whereArgs != null) {
        if (where.contains('email = ?')) {
          try {
            return [users.firstWhere((u) => u['email'] == whereArgs.first)];
          } catch (e) {
            return [];
          }
        } else if (where.contains('id = ?')) {
          try {
            return [users.firstWhere((u) => u['id'] == whereArgs.first)];
          } catch (e) {
            return [];
          }
        }
      }
      return users;
    } else if (table == 'candidates') {
      final candidates = DatabaseHelper._webStorage['candidates'] ?? [];
      if (where != null &&
          whereArgs != null &&
          where.contains('position = ?')) {
        return candidates
            .where((c) => c['position'] == whereArgs.first)
            .toList();
      }
      return candidates;
    } else if (table == 'votes') {
      return DatabaseHelper._webStorage['votes'] ?? [];
    }
    return [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return [];
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return 1;
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return 1;
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    return 0;
  }

  @override
  int get version => 1;

  @override
  bool get isOpen => true;

  @override
  String get path => ':memory:';

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) async {
    throw UnimplementedError('devInvokeMethod not implemented');
  }

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) async {
    throw UnimplementedError('devInvokeSqlMethod not implemented');
  }

  @override
  Future<T> readTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    return await transaction(action);
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    throw UnimplementedError('rawQueryCursor not implemented');
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    throw UnimplementedError('queryCursor not implemented');
  }

  @override
  Batch batch() {
    throw UnimplementedError('batch not implemented');
  }

  @override
  Database get database => this;
}

class SimpleMockTransaction implements Transaction {
  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return 0;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {}

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return [];
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    return 1;
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    return 1;
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    return 0;
  }

  @override
  Batch batch() {
    throw UnimplementedError('batch not implemented');
  }

  @override
  Database get database => throw UnimplementedError('database not implemented');

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) async {
    throw UnimplementedError('rawQueryCursor not implemented');
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) async {
    throw UnimplementedError('queryCursor not implemented');
  }
}
