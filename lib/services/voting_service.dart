import 'database_helper.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotingService {
  static final List<Map<String, dynamic>> _positions = [
    {'name': 'President', 'seats': 1},
    {'name': 'Executive Vice President', 'seats': 1},
    {'name': 'Vice President for External Affairs', 'seats': 1},
    {'name': 'Vice President for Internal Affairs', 'seats': 1},
    {'name': 'Secretary', 'seats': 1},
    {'name': 'Assistant Secretary', 'seats': 1},
    {'name': 'Treasurer', 'seats': 1},
    {'name': 'Auditor', 'seats': 1},
    {'name': 'Two (2) Press Information Officers', 'seats': 2},
    {'name': 'Three (3) Business Managers', 'seats': 3},
    {'name': 'Event Coordinator', 'seats': 1},
    {'name': 'Sports Coordinator', 'seats': 1},
    {'name': 'Four (4) Sentinels', 'seats': 4},
  ];

  static List<String> getPositions() {
    return _positions.map((p) => p['name'] as String).toList();
  }

  static int getSeatCount(String position) {
    final p = _positions.firstWhere(
      (e) => e['name'] == position,
      orElse: () => {'name': position, 'seats': 1},
    );
    return p['seats'] as int;
  }

  static Map<String, dynamic>? _cachedStats;
  static Map<String, dynamic>? _cachedResults;
  static DateTime? _statsCacheTime;
  static DateTime? _resultsCacheTime;
  static const Duration _cacheTtl = Duration(seconds: 30);

  static void _invalidateCaches() {
    _cachedStats = null;
    _cachedResults = null;
    _statsCacheTime = null;
    _resultsCacheTime = null;
  }
  // Get candidates by position
  static Future<List<Map<String, dynamic>>> getCandidatesByPosition(
    String position,
  ) async {
    if (await AuthService.isLoggedIn() && _useFirebase()) {
      final snapshot = await FirebaseFirestore.instance
          .collection('candidates')
          .where('position', isEqualTo: position)
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } else {
      final db = DatabaseHelper();
      return await db.getCandidatesByPosition(position);
    }
  }

  // Submit vote
  static Future<Map<String, dynamic>> submitVote(
    Map<String, String> votes,
  ) async {
    try {
      final uid = await AuthService.getCurrentUserId();

      if (uid == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Check if user has already voted
      final hasVoted = await hasUserVoted();
      if (hasVoted) {
        return {
          'success': false,
          'message': 'You have already voted in this election',
        };
      }

      for (final position in getPositions()) {
        if (!votes.containsKey(position) || votes[position]!.isEmpty) {
          return {
            'success': false,
            'message': 'Please vote for all positions or select "Abstain"',
          };
        }
      }

      // Validate that voting is enabled
      if (!isVotingEnabled()) {
        return {
          'success': false,
          'message': 'Voting is currently disabled',
        };
      }

      if (_useFirebase()) {
        final selections = <String, List<String>>{};
        for (final position in getPositions()) {
          selections[position] = [votes[position] ?? ''];
        }
        final voteData = <String, Object>{
          'userId': uid,
          'selections': selections,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await FirebaseFirestore.instance.collection('votes').add(voteData);
        await FirebaseFirestore.instance.collection('users').doc(uid).update({'hasVoted': 1});
      } else {
        final db = DatabaseHelper();
        final voteData = <String, Object>{
          'userId': uid,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await db.insertVote(voteData);
        await AuthService.updateUserData(uid, {'hasVoted': 1});
      }

      return {
        'success': true,
        'message': 'Your vote has been recorded successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit vote: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitVoteDynamic(
    Map<String, List<String>> votes,
  ) async {
    try {
      final uid = await AuthService.getCurrentUserId();
      if (uid == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }
      final hasVoted = await hasUserVoted();
      if (hasVoted) {
        return {
          'success': false,
          'message': 'You have already voted in this election',
        };
      }
      for (final position in getPositions()) {
        final seats = getSeatCount(position);
        final sel = votes[position] ?? <String>[];
        if (sel.isEmpty) {
          return {
            'success': false,
            'message': 'Please vote for all positions or select "Abstain"',
          };
        }
        if (seats > 1 && sel.first != 'Abstain' && sel.length > seats) {
          return {
            'success': false,
            'message': 'Please select $seats candidates for $position',
          };
        }
      }
      if (!isVotingEnabled()) {
        return {
          'success': false,
          'message': 'Voting is currently disabled',
        };
      }
      if (_useFirebase()) {
        final voteData = <String, Object>{
          'userId': uid,
          'selections': votes,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await FirebaseFirestore.instance.collection('votes').add(voteData);
        await FirebaseFirestore.instance.collection('users').doc(uid).update({'hasVoted': 1});
      } else {
        final db = DatabaseHelper();
        final voteData = <String, Object>{
          'userId': uid,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await db.insertVote(voteData);
        await AuthService.updateUserData(uid, {'hasVoted': 1});
      }
      return {
        'success': true,
        'message': 'Your vote has been recorded successfully',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit vote: $e'};
    }
  }

  // Check if user has voted
  static Future<bool> hasUserVoted() async {
    try {
      final uid = await AuthService.getCurrentUserId();
      if (uid != null) {
        if (_useFirebase()) {
          final snapshot = await FirebaseFirestore.instance
              .collection('votes')
              .where('userId', isEqualTo: uid)
              .limit(1)
              .get();
          return snapshot.docs.isNotEmpty;
        } else {
          final db = DatabaseHelper();
          return await db.hasUserVoted(uid);
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get all candidates
  static Future<List<Map<String, dynamic>>> getCandidates() async {
    if (_useFirebase()) {
      final snapshot = await FirebaseFirestore.instance.collection('candidates').get();
      return snapshot.docs.map((d) => d.data()).toList();
    } else {
      final db = DatabaseHelper();
      return await db.getCandidates();
    }
  }

  static Future<void> addCandidate(Map<String, dynamic> candidate) async {
    if (_useFirebase()) {
      await FirebaseFirestore.instance
          .collection('candidates')
          .doc(candidate['id'] as String)
          .set(candidate);
      _invalidateCaches();
    } else {
      final db = DatabaseHelper();
      await db.insertCandidate(candidate);
      _invalidateCaches();
    }
  }

  static Future<void> removeCandidate(String candidateId) async {
    if (_useFirebase()) {
      await FirebaseFirestore.instance
          .collection('candidates')
          .doc(candidateId)
          .delete();
      _invalidateCaches();
    } else {
      final db = DatabaseHelper();
      await db.deleteCandidate(candidateId);
      _invalidateCaches();
    }
  }

  static Future<void> seedDemoCandidates() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_useFirebase()) {
      final batch = FirebaseFirestore.instance.batch();
      final candidatesRef = FirebaseFirestore.instance.collection('candidates');
      for (final position in getPositions()) {
        final seats = getSeatCount(position);
        final count = seats + 2; // Provide extra options beyond seat count
        for (int i = 1; i <= count; i++) {
          final id = '${position.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "_")}_${now}_$i';
          final candidate = {
            'id': id,
            'name': '$position Candidate $i',
            'year': '2026-2027',
            'position': position,
            'description': 'Demo candidate $i for $position',
            'imageUrl': 'https://picsum.photos/seed/$id/150/150',
          };
          batch.set(candidatesRef.doc(id), candidate);
        }
      }
      await batch.commit();
      _invalidateCaches();
    } else {
      final db = DatabaseHelper();
      for (final position in getPositions()) {
        final seats = getSeatCount(position);
        final count = seats + 2;
        for (int i = 1; i <= count; i++) {
          final id = '${position.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "_")}_${now}_$i';
          final candidate = {
            'id': id,
            'name': '$position Candidate $i',
            'year': '2026-2027',
            'position': position,
            'description': 'Demo candidate $i for $position',
            'imageUrl': 'https://picsum.photos/seed/$id/150/150',
          };
          await db.insertCandidate(candidate);
        }
      }
      _invalidateCaches();
    }
  }

  // Get voting results
  static Future<Map<String, dynamic>> getVotingResults() async {
    if (_cachedResults != null && _resultsCacheTime != null) {
      final age = DateTime.now().difference(_resultsCacheTime!);
      if (age <= _cacheTtl) return _cachedResults!;
    }
    if (_useFirebase()) {
      final candidatesSnap = await FirebaseFirestore.instance.collection('candidates').get();
      final votingResults = <String, dynamic>{};
      for (final p in getPositions()) {
        votingResults[p] = <String, dynamic>{};
      }
      final votesSnap = await FirebaseFirestore.instance.collection('votes').get();
      int totalVotes = 0;
      for (final d in votesSnap.docs) {
        final data = d.data();
        final selections = data['selections'] as Map<String, dynamic>?;
        if (selections != null) {
          for (final entry in selections.entries) {
            final position = entry.key;
            final list = (entry.value as List?)?.cast<String>() ?? <String>[];
            if (votingResults[position] == null) {
              votingResults[position] = <String, dynamic>{};
            }
            for (final name in list) {
              if (name != 'Abstain' && name.isNotEmpty) {
                votingResults[position][name] = (votingResults[position][name] ?? 0) + 1;
                totalVotes += 1;
              }
            }
          }
        }
      }
      for (final c in candidatesSnap.docs) {
        final data = c.data();
        final position = data['position'] as String;
        final name = data['name'] as String;
        if (votingResults[position] == null) {
          votingResults[position] = <String, dynamic>{};
        }
        votingResults[position][name] = votingResults[position][name] ?? 0;
      }
      votingResults['totalVotes'] = totalVotes;
      _cachedResults = votingResults;
      _resultsCacheTime = DateTime.now();
      return votingResults;
    } else {
      final db = DatabaseHelper();
      return await db.getVotingResults();
    }
  }

  // Admin: Reset all users' voting status
  static Future<void> resetAllVotingStatus() async {
    if (_useFirebase()) {
      final batch = FirebaseFirestore.instance.batch();
      final votes = await FirebaseFirestore.instance.collection('votes').get();
      for (final d in votes.docs) {
        batch.delete(d.reference);
      }
      final users = await FirebaseFirestore.instance.collection('users').get();
      for (final u in users.docs) {
        batch.update(u.reference, {'hasVoted': 0});
      }
      await batch.commit();
      _invalidateCaches();
    } else {
      final db = DatabaseHelper();
      await db.resetVotes();
      _invalidateCaches();
    }
  }

  // Admin: Toggle voting enabled/disabled
  static bool _votingEnabled = true; // Default to enabled

  static bool isVotingEnabled() {
    return _votingEnabled;
  }

  static void toggleVotingEnabled() {
    _votingEnabled = !_votingEnabled;
  }

  // Admin: Get admin statistics
  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      if (_cachedStats != null && _statsCacheTime != null) {
        final age = DateTime.now().difference(_statsCacheTime!);
        if (age <= _cacheTtl) return _cachedStats!;
      }
      int totalUsers = 0;
      int votedUsers = 0;
      if (_useFirebase()) {
        try {
          final usersCount = await FirebaseFirestore.instance.collection('users').count().get();
          totalUsers = usersCount.count ?? 0;
          final votedCount = await FirebaseFirestore.instance
              .collection('users')
              .where('hasVoted', isEqualTo: 1)
              .count()
              .get();
          votedUsers = votedCount.count ?? 0;
        } catch (_) {
          final usersSnap = await FirebaseFirestore.instance.collection('users').get();
          totalUsers = usersSnap.docs.length;
          for (final d in usersSnap.docs) {
            final data = d.data();
            final hv = data['hasVoted'];
            if (hv == 1 || hv == true || (hv is String && hv == '1')) {
              votedUsers++;
            }
          }
        }
      } else {
        final users = await AuthService.getAllUsers();
        totalUsers = users.length;
        votedUsers = users.where((u) {
          final hv = u['hasVoted'];
          return hv == 1 || hv == true || (hv is String && hv == '1');
        }).length;
      }

      final turnoutPercentage = totalUsers > 0
          ? (votedUsers / totalUsers * 100).round()
          : 0;

      final stats = {
        'totalUsers': totalUsers,
        'votedUsers': votedUsers,
        'turnoutPercentage': turnoutPercentage,
        'votingEnabled': isVotingEnabled(),
        'electionStatus': 'Active',
      };
      _cachedStats = stats;
      _statsCacheTime = DateTime.now();
      return stats;
    } catch (e) {
      // Return zero stats instead of mock data for transparency
      return {
        'totalUsers': 0,
        'votedUsers': 0,
        'turnoutPercentage': 0,
        'votingEnabled': isVotingEnabled(),
        'electionStatus': 'Error loading data',
      };
    }
  }

  static bool _useFirebase() {
    return AuthService.isFirebaseReady();
  }
}
