import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillbridge/screens/lessons/lesson_detail_screen.dart';
import 'package:skillbridge/screens/quizzes/quiz_screen.dart';

class LessonScreen extends StatelessWidget {
  final String skillTitle;

  const LessonScreen({super.key, required this.skillTitle});

  List<String> _getLessonsForSkill(String skillTitle) {
    switch (skillTitle) {
      case 'Flutter Development':
        return [
          'Introduction to Flutter',
          'Installing Flutter and VS Code Setup',
          'Understanding Widgets',
          'Stateless vs Stateful Widgets',
          'Layouts: Row, Column, Container',
          'Navigation Between Screens',
          'Forms and User Input',
          'Working with Firebase in Flutter',
        ];
      case 'Graphic Design':
        return [
          'Introduction to Graphic Design',
          'Design Principles and Balance',
          'Color Theory Basics',
          'Typography Fundamentals',
          'Layout and Composition',
          'Branding and Visual Identity',
          'UI Design Basics',
          'Creating a Simple Poster Design',
        ];
      case 'English Communication':
        return [
          'Introduction to Communication Skills',
          'Common English Sentence Structures',
          'Listening and Understanding',
          'Speaking with Confidence',
          'Vocabulary Building',
          'Writing Clear Sentences',
          'Conversation Practice',
          'Presentation in English',
        ];
      case 'Public Speaking':
        return [
          'Introduction to Public Speaking',
          'Overcoming Stage Fear',
          'Voice and Tone Control',
          'Body Language Basics',
          'Speech Structure and Organization',
          'Audience Engagement Techniques',
          'Using Visual Aids',
          'Delivering a Short Speech',
        ];
      case 'Data Analysis':
        return [
          'Introduction to Data Analysis',
          'Types of Data',
          'Collecting and Cleaning Data',
          'Using Spreadsheets for Analysis',
          'Basic Charts and Graphs',
          'Finding Patterns in Data',
          'Introduction to Data Visualization',
          'Mini Analysis Project',
        ];
      default:
        return ['Introduction', 'Basics', 'Practice'];
    }
  }

  String _getLessonId(String lessonTitle) {
    return '${skillTitle}_$lessonTitle'
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _getLessonsForSkill(skillTitle);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        title: Text(
          skillTitle,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('completed_lessons')
                  .snapshots(),
              builder: (context, snapshot) {
                final completedDocs = snapshot.data?.docs ?? [];

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          final lessonId = _getLessonId(lesson);

                          final isCompleted = completedDocs.any(
                            (doc) => doc.id == lessonId,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LessonDetailScreen(
                                    skillTitle: skillTitle,
                                    lessonTitle: lesson,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.green.withOpacity(0.1)
                                          : const Color(0xFF4F46E5)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isCompleted
                                          ? Icons.check
                                          : Icons.menu_book_rounded,
                                      color: isCompleted
                                          ? Colors.green
                                          : const Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      lesson,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    size: 18,
                                    color: isCompleted
                                        ? Colors.green
                                        : const Color(0xFF9CA3AF),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Take Quiz Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF8B8DF8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(
                                    skillTitle: skillTitle,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.quiz_outlined,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Take Quiz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}