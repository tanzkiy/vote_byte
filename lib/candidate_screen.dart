import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'services/voting_service.dart';
import 'services/auth_service.dart';
import 'widgets/app_background.dart';

// --- Screen 1: Candidate Info (Based on your first image) ---

class CandidateInfoScreen extends StatelessWidget {
  const CandidateInfoScreen({super.key});

  // Dummy description text
  final String candidateDescription =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
      "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildMainAppBar(context), // Use shared AppBar
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // "For School Year..." info box
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Text(
                  "For School Year 2026 – 2027",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // "Due: Nov. 6" info box
              Transform.translate(
                offset: const Offset(0, -5),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Due: Nov. 6",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24.0), // Spacer
              // First candidate card
              CandidateProfileCard(
                name: "Jich Polking",
                year: "BSIT 3A",
                position: "President",
                description: candidateDescription,
                imageUrl: "https://picsum.photos/id/1005/150/150",
              ),
              const SizedBox(height: 20.0), // Spacer
              // Second candidate card
              CandidateProfileCard(
                name: "Jerusalem Chocyagan",
                year: "BSIT 3A",
                position: "President",
                description: candidateDescription,
                imageUrl: "https://picsum.photos/id/1006/150/150",
              ),
              const SizedBox(height: 80.0), // Spacer for FAB
            ],
          ),
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the Ballot Screen!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BallotScreen()),
          );
        },
        backgroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Makes it pill-shaped
        ),
        label: const Text(
          "Vote Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// A reusable widget for displaying a candidate's information card.
class CandidateProfileCard extends StatelessWidget {
  final String name;
  final String year;
  final String position;
  final String description;
  final String imageUrl;

  const CandidateProfileCard({
    super.key,
    required this.name,
    required this.year,
    required this.position,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    _buildInfoText("Name: ", name),
                    const SizedBox(height: 6.0),
                    _buildInfoText("Year: ", year),
                    const SizedBox(height: 6.0),
                    _buildInfoText("Position: ", position),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

// --- Screen 2: Ballot Screen (Based on your second image) ---

class BallotScreen extends StatefulWidget {
  const BallotScreen({super.key});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  // State variables to store the selected candidate for each position
  String? _selectedPresident;
  String? _selectedVicePresident;
  String? _selectedSecretary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildMainAppBar(context),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const InstructionsCard(),
              const SizedBox(height: 20.0),
              PositionCard(
                positionTitle: "President",
                candidates: const ["Jich Polking", "Jerusalem Chocyagan"],
                groupValue: _selectedPresident,
                onChanged: (value) {
                  setState(() {
                    _selectedPresident = value;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              PositionCard(
                positionTitle: "Vice-President",
                candidates: const ["Gerlex Balacwid", "Jhed Coyasan"],
                groupValue: _selectedVicePresident,
                onChanged: (value) {
                  setState(() {
                    _selectedVicePresident = value;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              PositionCard(
                positionTitle: "Secretary",
                candidates: const ["Lexbere Curugan", "Walem Paul Polo"],
                groupValue: _selectedSecretary,
                onChanged: (value) {
                  setState(() {
                    _selectedSecretary = value;
                  });
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // Handle submit vote logic here
                  // For example, show a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirm Vote"),
                      content: const Text(
                        "Are you sure you want to submit your vote? This action cannot be undone.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Add final submit logic here
                            try {
                              // Get current user
                              final currentUser = await AuthService.getCurrentUser();
                              if (currentUser == null) {
                                throw Exception('User not logged in');
                              }

                              // Check if user has already voted
                              final hasVoted = await VotingService.hasUserVoted();
                              if (hasVoted) {
                                Navigator.pop(ctx); // Close dialog
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('You have already voted!')),
                                  );
                                }
                                return;
                              }

                              // Validate that all positions have been selected
                              if (_selectedPresident == null || _selectedVicePresident == null || _selectedSecretary == null) {
                                Navigator.pop(ctx); // Close dialog
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select candidates for all positions!')),
                                  );
                                }
                                return;
                              }

                              // Submit the vote
                              final voteData = {
                                'President': _selectedPresident!,
                                'Vice-President': _selectedVicePresident!,
                                'Secretary': _selectedSecretary!,
                              };

                              final result = await VotingService.submitVote(voteData);
                              
                              if (!result['success']) {
                                throw Exception(result['message']);
                              }

                              // Show success message
                              Navigator.pop(ctx); // Close dialog
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vote submitted successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context); // Go back to info screen
                              }
                            } catch (e) {
                              Navigator.pop(ctx); // Close dialog
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error submitting vote: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  "Submit Vote",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      );
  }
}

/// A reusable widget for the "Instructions" card.
class InstructionsCard extends StatelessWidget {
  const InstructionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).colorScheme.secondary,
            child: const Text(
              "Instructions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionRow("You can only vote once."),
                const SizedBox(height: 4.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• ",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const Expanded(
                      child: Text(
                        "VOTE WISELY!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 16, color: Colors.black54)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

/// A reusable widget for displaying a position's candidates with radio buttons.
class PositionCard extends StatelessWidget {
  final String positionTitle;
  final List<String> candidates;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const PositionCard({
    super.key,
    required this.positionTitle,
    required this.candidates,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            child: Text(
              positionTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Expanded(
                      child: Text(
                        "Vote one.",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ...candidates.map((candidate) {
                  return _buildRadioTile(candidate);
                }),
                _buildRadioTile("Abstain"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.blue[600],
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// --- SHARED WIDGETS ---

/// A shared AppBar for both screens to keep the UI consistent.
AppBar _buildMainAppBar(BuildContext context) {
  return AppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    title: Text(
      "Vote BYTe",
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.settings,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          // Handle settings tap
        },
      ),
    ],
    backgroundColor: Colors.white,
    elevation: 1.0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(6.0),
      child: Container(
        height: 6.0,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E24AA), // Purple
              Color(0xFF673AB7), // Deep Purple
              Color(0xFF3F51B5), // Indigo
            ],
          ),
        ),
      ),
    ),
  );
}
