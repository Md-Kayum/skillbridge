import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LessonDetailScreen extends StatefulWidget {
  final String skillTitle;
  final String lessonTitle;

  const LessonDetailScreen({
    super.key,
    required this.skillTitle,
    required this.lessonTitle,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool isSaving = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    checkIfCompleted();
  }

  String _getLessonId() {
    return '${widget.skillTitle}_${widget.lessonTitle}'
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
  }

  Future<void> checkIfCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completed_lessons')
        .doc(_getLessonId())
        .get();

    if (!mounted) return;

    setState(() {
      isCompleted = doc.exists;
    });
  }

  Future<void> markLessonAsRead() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson already completed')),
      );
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed_lessons')
          .doc(_getLessonId())
          .set({
        'lessonId': _getLessonId(),
        'skillTitle': widget.skillTitle,
        'lessonTitle': widget.lessonTitle,
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as read')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save completion: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String _getLessonContent(String skillTitle, String lessonTitle) {
    if (skillTitle == 'Flutter Development') {
      switch (lessonTitle) {
        case 'Introduction to Flutter':
          return 'Flutter is a UI toolkit by Google used to build beautiful, fast, and cross-platform applications from a single codebase. It is widely used for Android, iOS, web, and desktop apps.';
        case 'Installing Flutter and VS Code Setup':
          return 'To begin Flutter development, install Flutter SDK, Android Studio or VS Code, and configure the emulator or physical device. Then run flutter doctor to verify the setup.';
        case 'Understanding Widgets':
          return 'Widgets are the building blocks of Flutter apps. Everything in Flutter is a widget, including text, buttons, layout structures, and entire screens.';
        case 'Stateless vs Stateful Widgets':
          return 'A StatelessWidget does not change after it is built. A StatefulWidget can update its UI when the data changes using setState.';
        case 'Layouts: Row, Column, Container':
          return 'Row arranges widgets horizontally, Column arranges them vertically, and Container is used for spacing, decoration, size, and alignment.';
        case 'Navigation Between Screens':
          return 'Navigation in Flutter is commonly done using Navigator.push and Navigator.pop. This lets users move from one screen to another.';
        case 'Forms and User Input':
          return 'Forms help collect user input using widgets like TextField and TextFormField. Validation is used to ensure the user enters correct values.';
        case 'Working with Firebase in Flutter':
          return 'Firebase can be connected to Flutter for authentication, database, and cloud features. It is often used for login, data storage, and app backend support.';
      }
    }

    if (skillTitle == 'Graphic Design') {
      switch (lessonTitle) {
        case 'Introduction to Graphic Design':
          return 'Graphic design is the art of visual communication. It combines text, colors, images, and layout to communicate messages clearly and attractively.';
        case 'Design Principles and Balance':
          return 'Design principles include balance, contrast, alignment, repetition, and proximity. These principles help make a design clean and effective.';
        case 'Color Theory Basics':
          return 'Color theory explains how colors work together. Understanding primary, secondary, warm, and cool colors helps create better visual harmony.';
        case 'Typography Fundamentals':
          return 'Typography is the style and arrangement of text. Good typography improves readability, emphasis, and overall visual appearance.';
        case 'Layout and Composition':
          return 'Layout is the arrangement of design elements on a page or screen. Strong composition helps guide the viewer and improve clarity.';
        case 'Branding and Visual Identity':
          return 'Branding includes logo, colors, fonts, and visual style. A strong visual identity makes a brand recognizable and memorable.';
        case 'UI Design Basics':
          return 'UI design focuses on designing app or website screens that are attractive, clear, and easy to use.';
        case 'Creating a Simple Poster Design':
          return 'Poster design combines typography, color, and composition to deliver a message in a visually strong format.';
      }
    }

    if (skillTitle == 'English Communication') {
      switch (lessonTitle) {
        case 'Introduction to Communication Skills':
          return 'English communication includes speaking, listening, reading, and writing clearly. Strong communication skills help in academic and professional life.';
        case 'Common English Sentence Structures':
          return 'Sentence structure includes subject, verb, and object. Learning common patterns helps build clear and correct sentences.';
        case 'Listening and Understanding':
          return 'Listening is important for communication. It involves hearing correctly, understanding the message, and responding appropriately.';
        case 'Speaking with Confidence':
          return 'Confidence in speaking comes from practice, vocabulary improvement, and reducing fear of making mistakes.';
        case 'Vocabulary Building':
          return 'Vocabulary building helps learners express ideas better. Reading, writing, and regular practice improve vocabulary over time.';
        case 'Writing Clear Sentences':
          return 'Clear writing uses simple words, proper grammar, and logical sentence flow. This makes communication easier to understand.';
        case 'Conversation Practice':
          return 'Conversation practice improves speaking fluency, listening ability, and confidence in real-life situations.';
        case 'Presentation in English':
          return 'Presenting in English requires structure, clarity, confidence, and proper pronunciation.';
      }
    }

    if (skillTitle == 'Public Speaking') {
      switch (lessonTitle) {
        case 'Introduction to Public Speaking':
          return 'Public speaking is the process of communicating ideas to an audience. It is an important skill for leadership, education, and professional growth.';
        case 'Overcoming Stage Fear':
          return 'Stage fear can be reduced by preparation, repeated practice, breathing control, and positive mindset.';
        case 'Voice and Tone Control':
          return 'Voice and tone affect how the audience understands and feels your message. A strong speaker controls speed, volume, and tone.';
        case 'Body Language Basics':
          return 'Body language includes eye contact, posture, hand movement, and facial expression. It supports spoken words and increases audience connection.';
        case 'Speech Structure and Organization':
          return 'A strong speech usually has an introduction, body, and conclusion. A clear structure keeps the audience engaged.';
        case 'Audience Engagement Techniques':
          return 'Good speakers engage the audience using questions, stories, examples, humor, and confident delivery.';
        case 'Using Visual Aids':
          return 'Visual aids like slides, charts, and images make a speech more understandable and memorable.';
        case 'Delivering a Short Speech':
          return 'Delivering a short speech helps learners practice timing, confidence, and message clarity in a focused format.';
      }
    }

    if (skillTitle == 'Data Analysis') {
      switch (lessonTitle) {
        case 'Introduction to Data Analysis':
          return 'Data analysis is the process of examining information to find patterns, insights, and useful conclusions.';
        case 'Types of Data':
          return 'Data can be qualitative or quantitative, structured or unstructured. Knowing the type helps choose the correct analysis method.';
        case 'Collecting and Cleaning Data':
          return 'Before analysis, data must be collected and cleaned by removing duplicates, fixing errors, and handling missing values.';
        case 'Using Spreadsheets for Analysis':
          return 'Spreadsheets like Excel or Google Sheets are useful for organizing, calculating, filtering, and analyzing data.';
        case 'Basic Charts and Graphs':
          return 'Charts and graphs such as bar charts, pie charts, and line graphs help present data visually and clearly.';
        case 'Finding Patterns in Data':
          return 'Pattern finding involves identifying trends, repeated behaviors, and relationships in datasets.';
        case 'Introduction to Data Visualization':
          return 'Data visualization turns raw data into visual insight using graphs, dashboards, and reports.';
        case 'Mini Analysis Project':
          return 'A mini analysis project helps learners apply what they studied to a small real-world data task.';
      }
    }

    return 'Lesson content is not available yet.';
  }

  @override
  Widget build(BuildContext context) {
    final content = _getLessonContent(widget.skillTitle, widget.lessonTitle);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: const Text(
          'Lesson Detail',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.skillTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.lessonTitle,
              style: const TextStyle(
                fontSize: 30,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
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
                child: ElevatedButton.icon(
                  onPressed: (isSaving || isCompleted) ? null : markLessonAsRead,
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.menu_book_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : isCompleted
                            ? 'Completed'
                            : 'Mark as Read',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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