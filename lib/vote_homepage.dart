import "package:flutter/material.dart";
import 'voting_screen.dart';
import 'sdg_advocacy_screen.dart';
import 'account_screen.dart';
import 'results_screen.dart';
import 'services/voting_service.dart';
import 'widgets/app_background.dart';

class VoteHomePage extends StatefulWidget {
  const VoteHomePage({super.key});

  @override
  State<VoteHomePage> createState() => _VoteHomePageState();
}

class _VoteHomePageState extends State<VoteHomePage> {
  int _currentIndex = 0; // for bottom navigation
  Future<bool>? _hasVotedFuture;
  List<bool> _segSelections = [true, false, false];

  @override
  void initState() {
    super.initState();
    _refreshHasVoted();
  }

  void _refreshHasVoted() {
    _hasVotedFuture = VotingService.hasUserVoted();
  }

  String _dueCountdownText() {
    final now = DateTime.now();
    final candidateThisYear = DateTime(now.year, 11, 6);
    final due = candidateThisYear.isAfter(now)
        ? candidateThisYear
        : DateTime(now.year + 1, 11, 6);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = due.difference(today).inDays;
    if (diffDays > 0) return 'Due in $diffDays days';
    if (diffDays == 0) return 'Due today';
    return 'Ended ${-diffDays} days ago';
  }

  Widget _buildHome(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HERO HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vote BYTe', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Body of Young Technologist', style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AccountScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: VotingService.isVotingEnabled() ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    VotingService.isVotingEnabled() ? 'Voting Open' : 'Voting Disabled',
                    style: textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dueCountdownText(),
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QUICK ACTIONS
          FutureBuilder<bool>(
            future: _hasVotedFuture,
            builder: (context, snapshot) {
              final hasVoted = snapshot.data ?? false;
              final votingEnabled = VotingService.isVotingEnabled();
              return Wrap(
                runSpacing: 16,
                spacing: 16,
                children: [
                  _quickAction(
                    icon: Icons.how_to_vote,
                    label: 'Vote Now',
                    onTap: (!votingEnabled || hasVoted)
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VotingScreen()),
                            );
                            _refreshHasVoted();
                            if (mounted) setState(() {});
                          },
                  ),
                  _quickAction(
                    icon: Icons.bar_chart,
                    label: 'Results',
                    onTap: hasVoted
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ResultsScreen()),
                            );
                          }
                        : null,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          // SEGMENTED SHORTCUTS
          Text('Explore', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSegment(0, Icons.public, 'SDGs')),
              const SizedBox(width: 12),
              Expanded(child: _buildSegment(1, Icons.campaign, 'Advocacy')),
              const SizedBox(width: 12),
              Expanded(child: _buildSegment(2, Icons.wc, 'GAD')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction({required IconData icon, required String label, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2, // two columns with 16px spacing
      child: Material(
        color: onTap == null ? scheme.surfaceVariant : scheme.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: scheme.onPrimary, size: 28),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: _buildHome(context),
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    List<Color> colors = const [Color(0xFF42A5F5), Color(0xFF1976D2)],
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A8C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(int index, IconData icon, String label) {
    final selected = _segSelections[index];
    const base = Color(0xFF2E3A8C);
    return Container(
      decoration: BoxDecoration(
        color: selected ? base : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              for (var i = 0; i < _segSelections.length; i++) {
                _segSelections[i] = i == index;
              }
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SdgAdvocacyScreen(initialIndex: index),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? Colors.white : base, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : base,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
