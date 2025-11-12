import "package:flutter/material.dart";
import 'voting_screen.dart';
import 'account_screen.dart';
import 'services/voting_service.dart';
import 'services/auth_service.dart';

class VoteHomePage extends StatelessWidget {
  const VoteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD6E0F2), // Light blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and settings icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vote BYTe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A8C), // Dark blue
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Color(0xFF2E3A8C)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Subheading
              Text(
                'Body of Young Technologist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A8C),
                ),
              ),
              SizedBox(height: 20),

              // Voting open banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF97B3E6), // Lighter blue banner
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'VOTING OPEN NOW!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Voting details
              Text(
                'For School Year 2026-2027',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E3A8C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Due: Nov. 6',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),

              // Vote Now button
              FutureBuilder<bool>(
                future: VotingService.hasUserVoted(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final hasVoted = snapshot.data ?? false;
                  final votingEnabled = VotingService.isVotingEnabled();

                  return GestureDetector(
                    onTap: !votingEnabled
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voting is currently disabled'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        : hasVoted
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You have already voted in this election',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VotingScreen(),
                              ),
                            );
                          },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: !votingEnabled
                                ? Colors.grey
                                : hasVoted
                                ? Colors.green
                                : Color(0xFF2E3A8C),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            !votingEnabled
                                ? 'Voting Disabled'
                                : hasVoted
                                ? 'Already Voted'
                                : 'Vote Now ...',
                            style: TextStyle(
                              fontSize: 16,
                              color: !votingEnabled
                                  ? Colors.grey
                                  : hasVoted
                                  ? Colors.green
                                  : Color(0xFF2E3A8C),
                            ),
                          ),
                          Icon(
                            !votingEnabled
                                ? Icons.block
                                : hasVoted
                                ? Icons.check_circle
                                : Icons.arrow_forward_ios,
                            size: 16,
                            color: !votingEnabled
                                ? Colors.grey
                                : hasVoted
                                ? Colors.green
                                : Color(0xFF2E3A8C),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
