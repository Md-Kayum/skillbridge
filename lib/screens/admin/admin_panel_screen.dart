import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillbridge/screens/auth/login_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();

  String selectedSkill = 'Flutter Development';
  String correctAnswer = 'A';
  bool isLoading = false;

  final List<String> skills = [
    'Flutter Development',
    'Graphic Design',
    'English Communication',
    'Public Speaking',
    'Data Analysis',
  ];

  String getSkillId(String skillTitle) {
    return skillTitle.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_');
  }

  String getCorrectAnswerText() {
    if (correctAnswer == 'A') return optionAController.text.trim();
    if (correctAnswer == 'B') return optionBController.text.trim();
    if (correctAnswer == 'C') return optionCController.text.trim();
    return optionDController.text.trim();
  }

  Future<void> logoutAdmin() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> saveQuestion() async {
    final question = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();
    final correctAnswerText = getCorrectAnswerText();

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final skillId = getSkillId(selectedSkill);

      await FirebaseFirestore.instance
          .collection('quiz_questions')
          .doc(skillId)
          .collection('questions')
          .add({
        'skillId': skillId,
        'skillTitle': selectedSkill,
        'question': question,
        'options': [optionA, optionB, optionC, optionD],
        'correctAnswer': correctAnswerText,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      questionController.clear();
      optionAController.clear();
      optionBController.clear();
      optionCController.clear();
      optionDController.clear();
      correctAnswer = 'A';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save question: $e')),
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
  void dispose() {
    questionController.dispose();
    optionAController.dispose();
    optionBController.dispose();
    optionCController.dispose();
    optionDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF4F46E5);
    const Color background = Color(0xFFF7F8FC);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logoutAdmin,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E9FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Upload quiz questions for the fixed learning skills. These questions will be stored in Firestore.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedSkill,
              decoration: InputDecoration(
                labelText: 'Skill',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: skills.map((skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSkill = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: questionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Question',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: optionAController,
              decoration: InputDecoration(
                labelText: 'Option A',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: optionBController,
              decoration: InputDecoration(
                labelText: 'Option B',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: optionCController,
              decoration: InputDecoration(
                labelText: 'Option C',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: optionDController,
              decoration: InputDecoration(
                labelText: 'Option D',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: correctAnswer,
              decoration: InputDecoration(
                labelText: 'Correct Answer',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('Option A')),
                DropdownMenuItem(value: 'B', child: Text('Option B')),
                DropdownMenuItem(value: 'C', child: Text('Option C')),
                DropdownMenuItem(value: 'D', child: Text('Option D')),
              ],
              onChanged: (value) {
                setState(() {
                  correctAnswer = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, Color(0xFF8B8DF8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLoading ? 'Saving...' : 'Save Question',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}