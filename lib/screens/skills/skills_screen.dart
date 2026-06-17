import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  bool isLoading = false;

  final List<Map<String, dynamic>> skills = [
    {
      'id': 'flutter',
      'title': 'Flutter Development',
      'subtitle': 'Build mobile apps with Flutter',
      'icon': Icons.phone_android,
      'color': const Color(0xFF4F46E5),
    },
    {
      'id': 'graphic_design',
      'title': 'Graphic Design',
      'subtitle': 'Learn UI/UX and visual design',
      'icon': Icons.brush_outlined,
      'color': const Color(0xFF9333EA),
    },
    {
      'id': 'english_communication',
      'title': 'English Communication',
      'subtitle': 'Improve speaking and writing',
      'icon': Icons.language,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 'public_speaking',
      'title': 'Public Speaking',
      'subtitle': 'Build confidence and presentation skills',
      'icon': Icons.mic_none,
      'color': const Color(0xFFEA580C),
    },
    {
      'id': 'data_analysis',
      'title': 'Data Analysis',
      'subtitle': 'Learn data handling and visualization',
      'icon': Icons.bar_chart,
      'color': const Color(0xFF059669),
    },
  ];

  Future<void> addSkill(Map<String, dynamic> skill) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selected_skills')
          .doc(skill['id']);

      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill already added')),
        );
        return;
      }

      await docRef.set({
        'skillId': skill['id'],
        'title': skill['title'],
        'subtitle': skill['subtitle'],
        'createdAt': FieldValue.serverTimestamp(),
        'progress': 0,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${skill['title']} added to your skills')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add skill: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        title: const Text(
          'Skills',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (skill['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    skill['icon'] as IconData,
                    color: skill['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill['title'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skill['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : () => addSkill(skill),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
