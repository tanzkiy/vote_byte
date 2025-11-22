import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/voting_service.dart';
import 'widgets/app_background.dart';
 

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final Map<String, List<String>> _selected = {};
  bool _isLoading = false;
  bool _isDataLoading = true;
  final Map<String, List<Map<String, dynamic>>> _candidatesByPosition = {};

  // Calculate voting progress
  double get _votingProgress {
    if (_candidatesByPosition.isEmpty) return 0.0;
    int totalPositions = _candidatesByPosition.length;
    int completedPositions = 0;
    
    for (final position in _candidatesByPosition.keys) {
      final selectedList = _selected[position] ?? [];
      if (selectedList.isNotEmpty) {
        completedPositions++;
      }
    }
    
    return completedPositions / totalPositions;
  }

  // Check if voting is complete
  bool get _isVotingComplete {
    if (_candidatesByPosition.isEmpty) return false;
    
    for (final position in _candidatesByPosition.keys) {
      final selectedList = _selected[position] ?? [];
      if (selectedList.isEmpty) {
        return false;
      }
    }
    return true;
  }

  // Get incomplete positions
  List<String> get _incompletePositions {
    List<String> incomplete = [];
    for (final position in _candidatesByPosition.keys) {
      final selectedList = _selected[position] ?? [];
      if (selectedList.isEmpty) {
        incomplete.add(position);
      }
    }
    return incomplete;
  }

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    for (final position in VotingService.getPositions()) {
      final list = await VotingService.getCandidatesByPosition(position);
      _candidatesByPosition[position] = list;
      _selected[position] = <String>[];
    }
    setState(() {
      _isDataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This helps style the status bar (time, battery icons)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent, // Make status bar transparent
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,

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
        // This is the voting progress indicator at the top
        // We use 'bottom' which places it just below the app bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote, color: Color(0xFF0D47A1)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: _votingProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _votingProgress < 0.5 ? Colors.orange : const Color(0xFF0D47A1),
                      ),
                      minHeight: 6.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${(_votingProgress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ),
        ),
      ),

      // The main scrollable body of the app
      body: AppBackground(
        child: _isDataLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Color(0xFF0D47A1)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "School Year 2026–2027 • Due: Nov. 6",
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...VotingService.getPositions().map((position) {
                      final candidates = _candidatesByPosition[position] ?? <Map<String, dynamic>>[];
                      final seats = VotingService.getSeatCount(position);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.05),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.badge,
                                    color: Color(0xFF0D47A1),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        position,
                                        style: const TextStyle(
                                          color: Color(0xFF0D47A1),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        seats > 1 ? 'Select $seats candidates' : 'Select 1 candidate',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                          ...candidates.map((candidate) {
                            final name = candidate['name'];
                            final selectedList = _selected[position] ?? <String>[];
                            final isSelected = selectedList.contains(name);
                            return Column(
                              children: [
                                CandidateCard(
                                  name: name,
                                  year: candidate['year'].toString(),
                                  position: candidate['position'],
                                  description: candidate['description'],
                                  imageUrl: candidate['imageUrl'],
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      final list = _selected[position] ?? <String>[];
                                      if (seats == 1) {
                                        _selected[position] = [name];
                                      } else {
                                        if (list.isNotEmpty && list.first == 'Abstain') {
                                          _selected[position] = <String>[];
                                        }
                                        if (list.contains(name)) {
                                          list.remove(name);
                                          _selected[position] = List<String>.from(list);
                                        } else if (list.length < seats) {
                                          list.add(name);
                                          _selected[position] = List<String>.from(list);
                                        }
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            );
                          }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                            leading: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.orange),
                            title: const Text(
                              'Abstain',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                            subtitle: Text('Choose not to vote for $position'),
                            trailing: ((_selected[position]?.isNotEmpty == true && _selected[position]!.first == 'Abstain'))
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.orange,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey,
                                  ),
                            onTap: () {
                              setState(() {
                                _selected[position] = ['Abstain'];
                              });
                            },
                          ),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    );
                    }),

                    const SizedBox(height: 72.0), // Spacer for FAB
                    ],
                  ),
                ),
              ),
      ),

      // The "Vote Now" button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : () async {
                // Check if voting is complete
                if (!_isVotingComplete) {
                  final incompletePositions = _incompletePositions;
                  String message;
                  
                  if (incompletePositions.length == 1) {
                    message = 'Please complete voting for ${incompletePositions[0]}';
                  } else if (incompletePositions.length == 2) {
                    message = 'Please complete voting for ${incompletePositions.join(' and ')}';
                  } else {
                    message = 'Please complete voting for all positions. Missing: ${incompletePositions.take(2).join(', ')}${incompletePositions.length > 2 ? ' and ${incompletePositions.length - 2} more' : ''}';
                  }
                  
                  if (context.mounted) {
                    final sm = ScaffoldMessenger.of(context);
                    sm.hideCurrentSnackBar();
                    sm.showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.orange,
                        duration: const Duration(milliseconds: 2000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }
                
                // Show vote confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return VoteConfirmationDialog(
                      selectedCandidates: Map.fromEntries(
                        _selected.entries
                            .where((e) => e.value.isNotEmpty)
                            .map((e) => MapEntry(e.key, e.value.first)),
                      ),
                    );
                  },
                );

                if (confirmed == true) {
                  setState(() {
                    _isLoading = true;
                  });

                  final result = await VotingService.submitVoteDynamic(
                    _selected,
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (result['success']) {
                    if (context.mounted) {
                      final sm = ScaffoldMessenger.of(context);
                      sm.hideCurrentSnackBar();
                      sm.showSnackBar(
                        const SnackBar(
                          content: Text('Vote submitted successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      final sm = ScaffoldMessenger.of(context);
                      sm.hideCurrentSnackBar();
                      sm.showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: Colors.red,
                          duration: const Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
        backgroundColor: _isLoading ? Colors.grey : const Color(0xFF0D47A1),
        icon: const Icon(Icons.how_to_vote, color: Colors.white),
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
                "Submit",
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
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        foregroundImage: NetworkImage(imageUrl),
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_outline, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  position,
                  style: const TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text('Year $year', style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? const Color(0xFF0D47A1) : Colors.grey,
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
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
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
                          overflow: TextOverflow.ellipsis,
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
        ),
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
