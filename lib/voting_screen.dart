import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/voting_service.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final Map<String, String> _selectedCandidates = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // This helps style the status bar (time, battery icons)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent, // Make status bar transparent
      ),
    );

    return Scaffold(
      // Set a light grey background for the whole screen
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        // The main title
        title: const Text(
          "Vote BYTe",
          style: TextStyle(
            color: Color(0xFF0D47A1), // A dark, strong blue
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // The settings icon on the right
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF0D47A1)),
            onPressed: () {
              // Handle settings tap
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1.0, // A subtle shadow
        // This is the purple progress bar at the top
        // We use 'bottom' which places it just below the app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Container(
            height: 6.0,
            decoration: const BoxDecoration(
              // A gradient to match the purple bar
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
      ),

      // The main scrollable body of the app
      body: SingleChildScrollView(
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
              // We use a small negative margin to make it overlap the blue box
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
                        color: Colors.black.withOpacity(0.1),
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
              // President candidates
              ...VotingService.getCandidatesByPosition('President').map((
                candidate,
              ) {
                return Column(
                  children: [
                    CandidateCard(
                      name: candidate['name'],
                      year: candidate['year'],
                      position: candidate['position'],
                      description: candidate['description'],
                      imageUrl: candidate['imageUrl'],
                      isSelected:
                          _selectedCandidates['President'] == candidate['name'],
                      onTap: () {
                        setState(() {
                          _selectedCandidates['President'] = candidate['name'];
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                  ],
                );
              }),
              // Abstain option for President
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _selectedCandidates['President'] == 'Abstain'
                      ? Colors.orange[100]
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _selectedCandidates['President'] == 'Abstain'
                        ? Colors.orange
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  title: const Text(
                    'Abstain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  subtitle: const Text('Choose not to vote for President'),
                  trailing: _selectedCandidates['President'] == 'Abstain'
                      ? const Icon(Icons.check_circle, color: Colors.orange)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedCandidates['President'] = 'Abstain';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // Vice-President candidates
              ...VotingService.getCandidatesByPosition('Vice-President').map((
                candidate,
              ) {
                return Column(
                  children: [
                    CandidateCard(
                      name: candidate['name'],
                      year: candidate['year'],
                      position: candidate['position'],
                      description: candidate['description'],
                      imageUrl: candidate['imageUrl'],
                      isSelected:
                          _selectedCandidates['Vice-President'] ==
                          candidate['name'],
                      onTap: () {
                        setState(() {
                          _selectedCandidates['Vice-President'] =
                              candidate['name'];
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                  ],
                );
              }),
              // Abstain option for Vice-President
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _selectedCandidates['Vice-President'] == 'Abstain'
                      ? Colors.orange[100]
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _selectedCandidates['Vice-President'] == 'Abstain'
                        ? Colors.orange
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  title: const Text(
                    'Abstain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  subtitle: const Text('Choose not to vote for Vice-President'),
                  trailing: _selectedCandidates['Vice-President'] == 'Abstain'
                      ? const Icon(Icons.check_circle, color: Colors.orange)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedCandidates['Vice-President'] = 'Abstain';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              // Secretary candidates
              ...VotingService.getCandidatesByPosition('Secretary').map((
                candidate,
              ) {
                return Column(
                  children: [
                    CandidateCard(
                      name: candidate['name'],
                      year: candidate['year'],
                      position: candidate['position'],
                      description: candidate['description'],
                      imageUrl: candidate['imageUrl'],
                      isSelected:
                          _selectedCandidates['Secretary'] == candidate['name'],
                      onTap: () {
                        setState(() {
                          _selectedCandidates['Secretary'] = candidate['name'];
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                  ],
                );
              }),
              // Abstain option for Secretary
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _selectedCandidates['Secretary'] == 'Abstain'
                      ? Colors.orange[100]
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _selectedCandidates['Secretary'] == 'Abstain'
                        ? Colors.orange
                        : Colors.transparent,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  title: const Text(
                    'Abstain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  subtitle: const Text('Choose not to vote for Secretary'),
                  trailing: _selectedCandidates['Secretary'] == 'Abstain'
                      ? const Icon(Icons.check_circle, color: Colors.orange)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedCandidates['Secretary'] = 'Abstain';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20.0),

              const SizedBox(height: 80.0), // Spacer for FAB
            ],
          ),
        ),
      ),

      // The "Vote Now" button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : () async {
                if (_selectedCandidates.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a candidate to vote for.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Show vote confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return VoteConfirmationDialog(
                      selectedCandidates: _selectedCandidates,
                    );
                  },
                );

                if (confirmed == true) {
                  setState(() {
                    _isLoading = true;
                  });

                  final result = await VotingService.submitVote(
                    _selectedCandidates,
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vote submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // Go back to home page
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        backgroundColor: _isLoading ? Colors.grey : Colors.blue[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Makes it pill-shaped
        ),
        label: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Vote Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      // Position the FAB at the bottom right
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// A reusable widget for displaying a candidate's information card.
class CandidateCard extends StatelessWidget {
  final String name;
  final String year;
  final String position;
  final String description;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CandidateCard({
    super.key,
    required this.name,
    required this.year,
    required this.position,
    required this.description,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[100]
              : const Color(0xFFE3F2FD), // Light blue background
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with image and details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Candidate Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    // Fallback in case image fails to load
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
                // Candidate Info (Name, Year, Position)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0), // Align text better
                      _buildInfoText("Name: ", name),
                      const SizedBox(height: 6.0),
                      _buildInfoText("Year: ", year),
                      const SizedBox(height: 6.0),
                      _buildInfoText("Position: ", position),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.blue, size: 24),
              ],
            ),
            const SizedBox(height: 16.0),
            // Description text
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4, // Line spacing
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A small helper widget to build the "Key: Value" text rows
  // This makes the bolding and alignment consistent
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

/// Vote confirmation dialog widget
class VoteConfirmationDialog extends StatelessWidget {
  final Map<String, String> selectedCandidates;

  const VoteConfirmationDialog({super.key, required this.selectedCandidates});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Confirm Your Vote',
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review your selections before submitting:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...selectedCandidates.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Once submitted, your vote cannot be changed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit Vote'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
