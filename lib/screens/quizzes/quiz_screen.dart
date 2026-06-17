import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String skillTitle;

  const QuizScreen({
    super.key,
    required this.skillTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool quizFinished = false;
  bool isSaving = false;
  bool isSaved = false;
  String? selectedAnswer;

  String getSkillId() {
    return widget.skillTitle
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
  }

  List<Map<String, dynamic>> getQuestions() {
    switch (widget.skillTitle) {
      case 'Flutter Development':
        return [
          {
            'question': 'What is Flutter mainly used for?',
            'options': [
              'Building mobile apps',
              'Editing videos',
              'Managing databases',
              'Designing logos',
            ],
            'answer': 'Building mobile apps',
          },
          {
            'question': 'Which language is used with Flutter?',
            'options': ['Java', 'Dart', 'Python', 'PHP'],
            'answer': 'Dart',
          },
          {
            'question': 'What is a widget in Flutter?',
            'options': [
              'A database table',
              'A UI building block',
              'A server file',
              'A password tool',
            ],
            'answer': 'A UI building block',
          },
        ];

      case 'Graphic Design':
        return [
          {
            'question': 'What is typography related to?',
            'options': ['Text style', 'Video editing', 'Coding', 'Database'],
            'answer': 'Text style',
          },
          {
            'question': 'Which is a basic design principle?',
            'options': ['Balance', 'Compilation', 'Authentication', 'Routing'],
            'answer': 'Balance',
          },
          {
            'question': 'Color theory helps designers choose what?',
            'options': [
              'Good color combinations',
              'Programming languages',
              'File names',
              'Passwords',
            ],
            'answer': 'Good color combinations',
          },
        ];

      case 'English Communication':
        return [
          {
            'question': 'Which is part of communication?',
            'options': ['Speaking', 'Cooking', 'Driving', 'Painting'],
            'answer': 'Speaking',
          },
          {
            'question': 'Clear writing should be what?',
            'options': [
              'Simple and understandable',
              'Confusing',
              'Random',
              'Too long',
            ],
            'answer': 'Simple and understandable',
          },
          {
            'question': 'Listening helps you do what?',
            'options': [
              'Understand others',
              'Ignore others',
              'Avoid conversation',
              'Forget information',
            ],
            'answer': 'Understand others',
          },
        ];

      case 'Public Speaking':
        return [
          {
            'question': 'What helps reduce stage fear?',
            'options': [
              'Practice',
              'Avoiding speech',
              'Speaking too fast',
              'Looking away',
            ],
            'answer': 'Practice',
          },
          {
            'question': 'Body language includes what?',
            'options': ['Posture', 'Password', 'Database', 'Code editor'],
            'answer': 'Posture',
          },
          {
            'question': 'A good speech usually has what?',
            'options': [
              'Introduction, body, conclusion',
              'Only conclusion',
              'Only jokes',
              'No structure',
            ],
            'answer': 'Introduction, body, conclusion',
          },
        ];

      case 'Data Analysis':
        return [
          {
            'question': 'Data analysis is used to find what?',
            'options': [
              'Patterns and insights',
              'Passwords',
              'Music beats',
              'Screen size',
            ],
            'answer': 'Patterns and insights',
          },
          {
            'question': 'Which tool is commonly used for basic data analysis?',
            'options': ['Spreadsheet', 'Paint', 'Camera', 'Music player'],
            'answer': 'Spreadsheet',
          },
          {
            'question': 'Charts help show data how?',
            'options': ['Visually', 'Secretly', 'Randomly', 'Silently'],
            'answer': 'Visually',
          },
        ];

      default:
        return [];
    }
  }

  void submitAnswer() {
    final questions = getQuestions();

    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }

    if (selectedAnswer == questions[currentQuestionIndex]['answer']) {
      score++;
    }

    if (currentQuestionIndex == questions.length - 1) {
      setState(() {
        quizFinished = true;
      });

      saveQuizResult();
    } else {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    }
  }

  Future<void> saveQuizResult() async {
    final user = FirebaseAuth.instance.currentUser;
    final questions = getQuestions();

    if (user == null || questions.isEmpty) return;

    final int totalQuestions = questions.length;
    final int percentage = ((score / totalQuestions) * 100).round();

    try {
      setState(() {
        isSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('quiz_results')
          .doc(getSkillId())
          .set({
        'skillId': getSkillId(),
        'skillTitle': widget.skillTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaved = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save quiz result: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      quizFinished = false;
      isSaving = false;
      isSaved = false;
      selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = getQuestions();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          '${widget.skillTitle} Quiz',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: questions.isEmpty
          ? const Center(child: Text('No quiz available'))
          : quizFinished
              ? _buildResultView(questions.length)
              : _buildQuestionView(questions),
    );
  }

  Widget _buildQuestionView(List<Map<String, dynamic>> questions) {
    final question = questions[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentQuestionIndex + 1} of ${questions.length}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 26,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            (question['options'] as List<String>).length,
            (index) {
              final option = question['options'][index];
              final isSelected = selectedAnswer == option;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswer = option;
                  });
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE7E9FF) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF8B8DF8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1
                      ? 'Finish Quiz'
                      : 'Next Question',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(int totalQuestions) {
    final percentage = ((score / totalQuestions) * 100).round();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE7E9FF),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Color(0xFF4F46E5),
              size: 54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quiz Completed',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You scored $score out of $totalQuestions',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isSaving
                ? 'Saving result...'
                : isSaved
                    ? 'Result saved'
                    : 'Result not saved yet',
            style: TextStyle(
              fontSize: 14,
              color: isSaved ? Colors.green : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: restartQuiz,
              child: const Text('Retake Quiz'),
            ),
          ),
        ],
      ),
    );
  }
}