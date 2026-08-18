import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/badge_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  bool? _selectedAnswer;
  bool _showExplanation = false;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'questionEn': 'Mental health issues are uncommon.',
      'questionBn': 'মানসিক স্বাস্থ্য সমস্যাগুলো খুব একটা দেখা যায় না।',
      'answer': false,
      'explanationEn': '1 in 4 people experience a mental health issue each year.',
      'explanationBn': 'প্রতি বছর ৪ জনের মধ্যে ১ জন মানসিক স্বাস্থ্য সমস্যার সম্মুখীন হন।',
    },
    {
      'questionEn': 'Exercise can help improve your mood.',
      'questionBn': 'ব্যায়াম আপনার মন ভালো করতে সাহায্য করতে পারে।',
      'answer': true,
      'explanationEn': 'Physical activity releases endorphins, which act as natural mood lifters.',
      'explanationBn': 'শারীরিক পরিশ্রম এন্ডোরফিন নিঃসরণ করে, যা প্রাকৃতিক মুড লিফটার হিসেবে কাজ করে।',
    },
    {
      'questionEn': 'You can tell if someone has a mental illness by looking at them.',
      'questionBn': 'কাউকে দেখে আপনি বুঝতে পারবেন যে তার মানসিক রোগ আছে কি না।',
      'answer': false,
      'explanationEn': 'Mental health issues are often invisible and can affect anyone.',
      'explanationBn': 'মানসিক স্বাস্থ্য সমস্যাগুলো প্রায়ই দৃশ্যমান হয় না এবং যে কাউকেই আক্রান্ত করতে পারে।',
    },
  ];

  void _checkAnswer(bool userSelection) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = userSelection;
      _showExplanation = true;
      if (userSelection == _questions[_currentQuestionIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    // Unlock badge
    Provider.of<BadgeProvider>(context, listen: false).unlockBadge('quiz_expert');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
        return AlertDialog(
          title: Text(langProvider.translate('Quiz Completed!', 'কুইজ সম্পন্ন!')),
          content: Text(langProvider.translate(
            'You scored $_score out of ${_questions.length}. Keep learning!',
            'আপনি ${_questions.length} এর মধ্যে $_score পেয়েছেন। শিখতে থাকুন!',
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('Mental Health Quiz', 'মানসিক স্বাস্থ্য কুইজ')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              langProvider.translate(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                'প্রশ্ন ${_currentQuestionIndex + 1}/${_questions.length}',
              ),
              style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              langProvider.translate(question['questionEn'], question['questionBn']),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 60),
            Row(
              children: [
                Expanded(
                  child: _buildAnswerButton(true, langProvider.translate('True', 'সত্য'), Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnswerButton(false, langProvider.translate('False', 'মিথ্যা'), Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (_showExplanation) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Text(
                  langProvider.translate(question['explanationEn'], question['explanationBn']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.teal),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(langProvider.translate('Next', 'পরবর্তী')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(bool value, String label, Color color) {
    bool isSelected = _selectedAnswer == value;
    bool isCorrect = _questions[_currentQuestionIndex]['answer'] == value;

    return ElevatedButton(
      onPressed: () => _checkAnswer(value),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        backgroundColor: _selectedAnswer != null
            ? (isCorrect ? Colors.green.withValues(alpha: 0.7) : (isSelected ? Colors.red.withValues(alpha: 0.7) : Colors.grey.shade300))
            : Colors.white,
        foregroundColor: _selectedAnswer != null ? Colors.white : Colors.black87,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        elevation: isSelected ? 8 : 2,
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
