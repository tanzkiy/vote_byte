import 'package:flutter/material.dart';
import 'widgets/app_background.dart';
import 'services/voting_service.dart';
import 'voting_screen.dart';

class SdgAdvocacyScreen extends StatefulWidget {
  final int initialIndex;
  const SdgAdvocacyScreen({super.key, this.initialIndex = 0});

  @override
  State<SdgAdvocacyScreen> createState() => _SdgAdvocacyScreenState();
}

class _SdgAdvocacyScreenState extends State<SdgAdvocacyScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E7FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'SDGs, Advocacy & GAD',
            style: TextStyle(
              color: Color(0xFF2E3A8C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: AppBackground(
          child: const TabBarView(
            children: [
              _SdgTab(),
              _AdvocacyTab(),
              _GadTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- SHARED WIDGETS ---------- */
class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Color> gradient;
  final String section;
  const _HeaderCard({required this.icon, required this.title, this.subtitle, required this.gradient, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradient.last.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Text(
              section,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnMessageCard extends StatelessWidget {
  final String title;
  final String body;
  final List<String> chips;
  const _OnMessageCard({required this.title, required this.body, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3A8C))),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF7EA1F2)),
                    ),
                    child: Text(c, style: const TextStyle(color: Color(0xFF2E3A8C), fontWeight: FontWeight.w600)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _VoteNowButton extends StatelessWidget {
  const _VoteNowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VotingScreen())),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(child: Text('Proceed to Vote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          ),
        ),
      ),
    );
  }
}

class _TopButtons extends StatelessWidget {
  final int activeIndex;
  const _TopButtons({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniButton(
            icon: Icons.public,
            label: 'SDGs',
            colors: const [Color(0xFF00E676), Color(0xFFCCFF90)],
            active: activeIndex == 0,
            onPressed: () => DefaultTabController.of(context)!.animateTo(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniButton(
            icon: Icons.campaign,
            label: 'Advocacy',
            colors: const [Color(0xFFFF4081), Color(0xFFFFAB40)],
            active: activeIndex == 1,
            onPressed: () => DefaultTabController.of(context)!.animateTo(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniButton(
            icon: Icons.wc,
            label: 'GAD',
            colors: const [Color(0xFF7C4DFF), Color(0xFFE1BEE7)],
            active: activeIndex == 2,
            onPressed: () => DefaultTabController.of(context)!.animateTo(2),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    bool active = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: colors.last.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
        border: active ? Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------- SDG TAB ---------- */
class _SdgTab extends StatelessWidget {
  const _SdgTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(
            icon: Icons.how_to_vote,
            title: 'Voting Now Open',
            subtitle: 'School Year 2026-2027',
            gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
            section: 'SDGs',
          ),
          const SizedBox(height: 16),
          _TopButtons(activeIndex: 0),
          const SizedBox(height: 16),
          _OnMessageCard(
            title: 'SDG 4 – Quality Education',
            body:
                'The app builds digital literacy by giving students real-world experience with secure, user-friendly online platforms—preparing them for responsible digital citizenship.',
            chips: const ['Digital-skills training', 'User-centric design', 'Secure authentication'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'SDG 5 – Gender Equality',
            body:
                'Anonymous voting and equal ballot access remove gender barriers; built-in privacy controls protect against harassment or bias.',
            chips: const ['Anonymous ballots', 'Privacy by design', 'Equal participation'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'SDG 10 – Reduced Inequalities',
            body:
                'Web-based access works on any phone or computer; no extra software or travel needed—leveling the field for commuter, working or remote students.',
            chips: const ['Device agnostic', 'Zero travel cost', '24-hour window'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'SDG 12 – Responsible Consumption',
            body:
                'Replacing paper ballots and plastic ID cards with encrypted digital records cuts waste and carbon footprint of each election cycle.',
            chips: const ['Paperless ballots', 'Zero plastic IDs', 'Lower CO₂'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'SDG 16 – Peace, Justice & Strong Institutions',
            body:
                'End-to-end audit trails, tamper-proof timestamps and real-time results foster trust, accountability and peaceful acceptance of outcomes.',
            chips: const ['Audit trail', 'Tamper-proof logs', 'Instant results'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'SDG 17 – Partnerships for the Goals',
            body:
                'Collaboration among student government, IT services, advocacy groups and administration ensures shared ownership and continuous improvement.',
            chips: const ['Multi-stakeholder', 'Open feedback loop', 'Shared governance'],
          ),
          const SizedBox(height: 16),
          _VoteNowButton(),
        ],
      ),
    );
  }
}

/* ---------- ADVOCACY TAB ---------- */
class _AdvocacyTab extends StatelessWidget {
  const _AdvocacyTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(
            icon: Icons.how_to_vote,
            title: 'Voting Now Open',
            subtitle: 'School Year 2026-2027',
            gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
            section: 'Advocacy',
          ),
          const SizedBox(height: 16),
          _TopButtons(activeIndex: 1),
          const SizedBox(height: 16),
          _OnMessageCard(
            title: 'Transparent Elections',
            body:
                'Real-time progress bars and public result dashboards eliminate back-room counting and boost confidence in student governance.',
            chips: const ['Live progress', 'Public dashboard', 'Open data'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Inclusive Participation',
            body:
                'Responsive layout, screen-reader labels and bilingual prompts ensure students with disabilities or language needs can vote independently.',
            chips: const ['WCAG compliant', 'Bilingual UI', 'Screen-reader ready'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Digital Rights & Privacy',
            body:
                'Voter anonymity, encrypted storage and GDPR-style data-minimisation protect users from surveillance or misuse of personal data.',
            chips: const ['End-to-end encryption', 'Minimal data', 'Right to deletion'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Environmental Responsibility',
            body:
                'By replacing paper forms and physical booths we cut waste, energy and transport emissions—aligning tech choices with climate advocacy.',
            chips: const ['Zero paper', 'Reduced travel', 'Energy-efficient cloud'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Youth Empowerment',
            body:
                'Fast, fair and familiar digital processes increase turnout and give students a stronger voice in shaping campus policies that affect their lives.',
            chips: const ['Higher turnout', 'Policy feedback', 'Youth-led design'],
          ),
          const SizedBox(height: 16),
          _VoteNowButton(),
        ],
      ),
    );
  }
}

/* ---------- GAD TAB ---------- */
class _GadTab extends StatelessWidget {
  const _GadTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(
            icon: Icons.how_to_vote,
            title: 'Voting Now Open',
            subtitle: 'School Year 2026-2027',
            gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
            section: 'GAD',
          ),
          const SizedBox(height: 16),
          _TopButtons(activeIndex: 2),
          const SizedBox(height: 16),
          _OnMessageCard(
            title: 'Equal Access to Ballots',
            body:
                'No gendered restrictions: same login, same devices, same deadlines for all students—closing historical gaps in candidacy and voting.',
            chips: const ['Gender-neutral login', 'Same deadlines', 'Equal candidacy rules'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Safe & Private Voting',
            body:
                'Anonymous ballots and encrypted logs reduce risks of harassment or retaliation that disproportionately affect women and LGBTQ+ students.',
            chips: const ['Anonymous ballots', 'Encrypted logs', 'No retaliation'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Inclusive Language & Imagery',
            body:
                'Interface avoids gendered terms (chairman, he/she) and uses neutral icons/colours so every student feels represented.',
            chips: const ['Neutral wording', 'Inclusive icons', 'Colour-blind safe'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Data for Gender-Responsive Policy',
            body:
                'Optional, aggregated gender-disaggregated turnout statistics help student government tailor outreach and measure inclusion goals.',
            chips: const ['Opt-in analytics', 'Aggregated data', 'Outreach insights'],
          ),
          const SizedBox(height: 12),
          _OnMessageCard(
            title: 'Continuous GAD Mainstreaming',
            body:
                'Student-led feedback loops and policy reviews ensure the platform evolves with emerging gender and development standards.',
            chips: const ['Feedback loops', 'Policy reviews', 'Standards alignment'],
          ),
          const SizedBox(height: 16),
          _VoteNowButton(),
        ],
      ),
    );
  }
}