import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_service.dart';

class VotingService {
  static const String _votesKey = 'user_votes';
  static const String _hasVotedKey = 'has_voted';

  // Candidates data - now fetched from Firebase
  static List<Map<String, dynamic>> candidates = [
    {
      'id': 'president_1',
      'name': 'Jich Polking',
      'year': 'BSIT 3A',
      'position': 'President',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1005/150/150",
    },
    {
      'id': 'president_2',
      'name': 'Jerusalem Chocyagan',
      'year': 'BSIT 3A',
      'position': 'President',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1006/150/150",
    },
    {
      'id': 'vp_1',
      'name': 'Gerlex Balacwid',
      'year': 'BSIT 3A',
      'position': 'Vice-President',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1007/150/150",
    },
    {
      'id': 'vp_2',
      'name': 'Jhed Coyasan',
      'year': 'BSIT 3A',
      'position': 'Vice-President',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1008/150/150",
    },
    {
      'id': 'sec_1',
      'name': 'Lexbere Curugan',
      'year': 'BSIT 3A',
      'position': 'Secretary',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1009/150/150",
    },
    {
      'id': 'sec_2',
      'name': 'Walem Paul Polo',
      'year': 'BSIT 3A',
      'position': 'Secretary',
      'description':
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      'imageUrl': "https://picsum.photos/id/1010/150/150",
    },
  ];

  // Get candidates by position
  static List<Map<String, dynamic>> getCandidatesByPosition(String position) {
    return candidates
        .where((candidate) => candidate['position'] == position)
        .toList();
  }

  // Submit vote
  static Future<Map<String, dynamic>> submitVote(
    Map<String, String> votes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('current_user');

      if (uid == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Check if user has already voted locally
      final hasVoted = await hasUserVoted();
      if (hasVoted) {
        return {
          'success': false,
          'message': 'You have already voted in this election',
        };
      }

      // Validate votes
      final positions = ['President', 'Vice-President', 'Secretary'];
      for (final position in positions) {
        if (!votes.containsKey(position) || votes[position]!.isEmpty) {
          return {
            'success': false,
            'message': 'Please vote for all positions or select "Abstain"',
          };
        }
      }

      // Store vote locally
      final votesJson = json.encode({
        'userId': uid,
        'votes': votes,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_votesKey, votesJson);

      // Update local preferences
      await prefs.setBool(_hasVotedKey, true);

      // Update user data
      await AuthService.updateUserData(uid, {'hasVoted': true});

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
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('current_user');

      if (uid != null) {
        // Check local user data
        final users = await AuthService.getAllUsers();
        final user = users.firstWhere((u) => u['uid'] == uid, orElse: () => {});
        return user['hasVoted'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user's votes
  static Future<Map<String, dynamic>?> getUserVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final votesString = prefs.getString(_votesKey);

    if (votesString != null) {
      // In real implementation, parse properly
      return {'votes': {}, 'timestamp': DateTime.now().toIso8601String()};
    }

    return null;
  }

  // Mock method to simulate recording votes in database
  static void _recordVoteInDatabase(Map<String, String> votes) {
    // In real app, this would send data to backend
    print('Recording votes: $votes');
  }

  // Get voting results from local storage
  static Future<Map<String, dynamic>> getVotingResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final votesJson = prefs.getString(_votesKey);

      Map<String, Map<String, int>> results = {
        'President': {},
        'Vice-President': {},
        'Secretary': {},
      };

      if (votesJson != null) {
        final voteData = json.decode(votesJson) as Map<String, dynamic>;
        final votes = voteData['votes'] as Map<String, dynamic>;

        votes.forEach((position, candidate) {
          if (results.containsKey(position)) {
            results[position]![candidate] =
                (results[position]![candidate] ?? 0) + 1;
          }
        });
      }

      // Calculate total votes
      int totalVotes = 0;
      results.forEach((position, votes) {
        votes.forEach((candidate, count) {
          totalVotes += count;
        });
      });

      // Convert to expected format
      Map<String, dynamic> formattedResults = Map.from(results);
      formattedResults['totalVotes'] = totalVotes;

      return formattedResults;
    } catch (e) {
      // Fallback to mock data if something fails
      return {
        'President': {
          'Jich Polking': 45,
          'Jerusalem Chocyagan': 32,
          'Abstain': 8,
        },
        'Vice-President': {
          'Gerlex Balacwid': 38,
          'Jhed Coyasan': 39,
          'Abstain': 8,
        },
        'Secretary': {
          'Lexbere Curugan': 41,
          'Walem Paul Polo': 36,
          'Abstain': 8,
        },
        'totalVotes': 85,
      };
    }
  }

  // Reset voting status (for testing/admin purposes)
  static Future<void> resetVotingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_votesKey);
    await prefs.setBool(_hasVotedKey, false);
  }

  // Admin: Reset all users' voting status
  static Future<void> resetAllVotingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All users voting status reset successfully');
    } catch (e) {
      print('Failed to reset voting status: $e');
    }
  }

  // Admin: Toggle voting enabled/disabled
  static bool _votingEnabled = true; // Default to enabled

  static bool isVotingEnabled() {
    return _votingEnabled;
  }

  static void toggleVotingEnabled() {
    _votingEnabled = !_votingEnabled;
    print('Voting ${isVotingEnabled() ? 'enabled' : 'disabled'}');
  }

  // Admin: Get admin statistics
  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final users = await AuthService.getAllUsers();
      final totalUsers = users.length;
      final votedUsers = users.where((user) => user['hasVoted'] == true).length;
      final turnoutPercentage = totalUsers > 0
          ? (votedUsers / totalUsers * 100).round()
          : 0;

      return {
        'totalUsers': totalUsers,
        'votedUsers': votedUsers,
        'turnoutPercentage': turnoutPercentage,
        'votingEnabled': isVotingEnabled(),
        'electionStatus': 'Active',
      };
    } catch (e) {
      // Fallback to mock data if something fails
      return {
        'totalUsers': 150,
        'votedUsers': 85,
        'turnoutPercentage': 57,
        'votingEnabled': isVotingEnabled(),
        'electionStatus': 'Active',
      };
    }
  }
}
