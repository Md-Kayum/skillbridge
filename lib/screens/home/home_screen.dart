import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillbridge/screens/auth/login_screen.dart';
import 'package:skillbridge/screens/lessons/lesson_screen.dart';
import 'package:skillbridge/screens/skills/skills_screen.dart';
import 'package:skillbridge/screens/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = _getUserName(user?.email);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context, userName),
                    const SizedBox(height: 24),
                    _buildProgressCard(user),
                    const SizedBox(height: 18),
                    _buildStatsRow(user),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context),
                    const SizedBox(height: 14),
                    _buildSelectedSkillsList(context, user),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  String _getUserName(String? email) {
    if (email == null || email.isEmpty) return 'User';
    return email.split('@').first;
  }

  Widget _buildTopBar(BuildContext context, String userName) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GOOD EVENING,',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            await FirebaseAuth.instance.signOut();

            if (!context.mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(
              Icons.logout,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(User? user) {
    if (user == null) {
      return _buildProgressCardContent(0);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_skills')
          .snapshots(),
      builder: (context, skillsSnapshot) {
        int totalLessons = 0;

        for (final doc in skillsSnapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          totalLessons += _getLessonCountForSkill(data['title'] ?? '');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('completed_lessons')
              .snapshots(),
          builder: (context, completedSnapshot) {
            final int completedCount = completedSnapshot.data?.docs.length ?? 0;

            final int overallProgress = totalLessons == 0
                ? 0
                : ((completedCount / totalLessons) * 100).round();

            return _buildProgressCardContent(overallProgress);
          },
        );
      },
    );
  }

  Widget _buildProgressCardContent(int progressPercent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF8B8DF8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Build Your\nSkill Journey',
                  style: TextStyle(
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Choose skills, open lessons,\nand track your progress over time.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 8,
              ),
            ),
            child: Center(
              child: Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(User? user) {
    if (user == null) {
      return const Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.school_outlined,
              iconColor: Color(0xFF4F46E5),
              title: 'MY SKILLS',
              value: '0',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.menu_book_rounded,
              iconColor: Color(0xFF2563EB),
              title: 'LESSONS',
              value: '0',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              iconColor: Color(0xFF9333EA),
              title: 'DONE',
              value: '0',
            ),
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_skills')
          .snapshots(),
      builder: (context, skillsSnapshot) {
        final int skillCount = skillsSnapshot.data?.docs.length ?? 0;
        int totalLessons = 0;

        for (final doc in skillsSnapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          totalLessons += _getLessonCountForSkill(data['title'] ?? '');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('completed_lessons')
              .snapshots(),
          builder: (context, completedSnapshot) {
            final int completedCount = completedSnapshot.data?.docs.length ?? 0;

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.school_outlined,
                    iconColor: const Color(0xFF4F46E5),
                    title: 'MY SKILLS',
                    value: '$skillCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: 'LESSONS',
                    value: '$totalLessons',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF9333EA),
                    title: 'DONE',
                    value: '$completedCount',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My skills',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SkillsScreen(),
              ),
            );
          },
          child: const Text(
            'Add More',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F46E5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSkillsList(BuildContext context, User? user) {
    if (user == null) {
      return _buildEmptySkillsCard();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_skills')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, skillsSnapshot) {
        if (skillsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (skillsSnapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Could not load your skills.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF111827),
              ),
            ),
          );
        }

        final skillDocs = skillsSnapshot.data?.docs ?? [];

        if (skillDocs.isEmpty) {
          return _buildEmptySkillsCard();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('completed_lessons')
              .snapshots(),
          builder: (context, completedSnapshot) {
            final completedDocs = completedSnapshot.data?.docs ?? [];

            return Column(
              children: skillDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String skillTitle = data['title'] ?? 'Skill';
                final String skillId = data['skillId'] ?? '';

                final int totalLessons = _getLessonCountForSkill(skillTitle);

                int completedForSkill = 0;
                for (final completedDoc in completedDocs) {
                  final completedData =
                      completedDoc.data() as Map<String, dynamic>;
                  if (completedData['skillTitle'] == skillTitle) {
                    completedForSkill++;
                  }
                }

                final int progressPercent = totalLessons == 0
                    ? 0
                    : ((completedForSkill / totalLessons) * 100).round();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          skillTitle: skillTitle,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _getSkillColor(skillId).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getSkillIcon(skillId),
                            color: _getSkillColor(skillId),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skillTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completedForSkill of $totalLessons lessons completed',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progressPercent / 100,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getSkillColor(skillId),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$progressPercent%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PROGRESS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptySkillsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E9FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Color(0xFF4F46E5),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No skills selected yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose from the fixed skill list to start learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            active: true,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SkillsScreen(),
                ),
              );
            },
            child: const _NavItem(
              icon: Icons.school_outlined,
              label: 'Skills',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SkillsScreen(),
                ),
              );
            },
            child: const _AddButton(),
          ),
          const _NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
          ),
          GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  },
  child: const _NavItem(
    icon: Icons.person_outline,
    label: 'Profile',
  ),
),
        ],
      ),
    );
  }

  int _getLessonCountForSkill(String skillTitle) {
    switch (skillTitle) {
      case 'Flutter Development':
      case 'Graphic Design':
      case 'English Communication':
      case 'Public Speaking':
      case 'Data Analysis':
        return 8;
      default:
        return 0;
    }
  }

  IconData _getSkillIcon(String? skillId) {
    switch (skillId) {
      case 'flutter':
        return Icons.phone_android;
      case 'graphic_design':
        return Icons.brush_outlined;
      case 'english_communication':
        return Icons.language;
      case 'public_speaking':
        return Icons.mic_none;
      case 'data_analysis':
        return Icons.bar_chart;
      default:
        return Icons.school_outlined;
    }
  }

  Color _getSkillColor(String? skillId) {
    switch (skillId) {
      case 'flutter':
        return const Color(0xFF4F46E5);
      case 'graphic_design':
        return const Color(0xFF9333EA);
      case 'english_communication':
        return const Color(0xFF2563EB);
      case 'public_speaking':
        return const Color(0xFFEA580C);
      case 'data_analysis':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF4F46E5);
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        active ? const Color(0xFF4F46E5) : const Color(0xFF9CA3AF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF8B8DF8)],
        ),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
