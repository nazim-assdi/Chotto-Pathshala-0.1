import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ChottoPathshalaApp());

const lessonFiles = [
  'class-one-251-300.json', 'class-one-306-365.json',
  'class-two-366-389.json', 'kg-151-200.json', 'kg-205-250.json',
  'kg-246-250.json', 'nursery-061-110.json', 'nursery-111-150.json',
  'playgroup-001-010.json', 'playgroup-011-060.json',
];
const quizFiles = [
  'class-one-001-050.json', 'class-one-051-100.json',
  'class-one-101-150.json', 'class-two-001-024.json',
  'kg-001-050.json', 'kg-051-100.json', 'kg-102-151.json',
  'nursery-001-050.json', 'nursery-051-100.json',
  'nursery-101-150.json', 'nursery-151-200.json',
  'nursery-201-250.json', 'playgroup-001-020.json',
  'playgroup-021-070.json', 'playgroup-071-110.json',
  'playgroup-111-130.json', 'supplemental-319.json',
];

const levels = <String, String>{
  'playgroup': 'প্লে-গ্রুপ',
  'nursery': 'নার্সারি',
  'kg': 'কেজি',
  'class-one': 'প্রথম শ্রেণি',
  'class-two': 'দ্বিতীয় শ্রেণি',
};

class Lesson {
  const Lesson({
    required this.day, required this.level, required this.subject,
    required this.title, required this.objective, required this.story,
    required this.examples, required this.activity, required this.practice,
    required this.answers, required this.parentTip,
  });

  final int day;
  final String level, subject, title, objective, story, activity, practice, answers, parentTip;
  final List<String> examples;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    day: (json['day'] as num?)?.toInt() ?? 0,
    level: json['level']?.toString() ?? 'nursery',
    subject: json['subject']?.toString() ?? 'অন্যান্য',
    title: json['title']?.toString() ?? 'নতুন পাঠ',
    objective: json['objective']?.toString() ?? '',
    story: json['story']?.toString() ?? '',
    examples: (json['examples'] as List? ?? const []).map((e) => e.toString()).toList(),
    activity: json['activity']?.toString() ?? '',
    practice: json['practice']?.toString() ?? '',
    answers: json['answers']?.toString() ?? '',
    parentTip: json['parent_tip']?.toString() ?? '',
  );
}

class QuizQuestion {
  const QuizQuestion({required this.id, required this.level, required this.subject,
    required this.question, required this.options, required this.answer, required this.explanation});
  final String id, level, subject, question, answer, explanation;
  final Map<String, String> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id']?.toString() ?? '',
    level: json['level']?.toString() ?? 'nursery',
    subject: json['subject']?.toString() ?? 'অন্যান্য',
    question: json['question']?.toString() ?? '',
    options: (json['options'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
    answer: json['answer']?.toString() ?? '',
    explanation: json['explanation']?.toString() ?? '',
  );
}

class LearningRepository {
  Future<List<Lesson>> loadLessons() async {
    final result = <Lesson>[];
    for (final file in lessonFiles) {
      final raw = await rootBundle.loadString('app/src/main/assets/content/lessons/$file');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      result.addAll((data['lessons'] as List).map((e) => Lesson.fromJson(e as Map<String, dynamic>)));
    }
    result.sort((a, b) => a.day.compareTo(b.day));
    return result;
  }

  Future<List<QuizQuestion>> loadQuizzes() async {
    final result = <QuizQuestion>[];
    for (final file in quizFiles) {
      final raw = await rootBundle.loadString('app/src/main/assets/content/quizzes/$file');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      result.addAll((data['questions'] as List).map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>)));
    }
    return result;
  }
}

class ChottoPathshalaApp extends StatelessWidget {
  const ChottoPathshalaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ছোট্ট পাঠশালা',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF347C69)),
      scaffoldBackgroundColor: const Color(0xFFF7FAF7),
      cardTheme: CardThemeData(color: Colors.white, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repository = LearningRepository();
  late Future<List<Lesson>> lessonsFuture;
  late Future<List<QuizQuestion>> quizzesFuture;
  String selectedLevel = 'nursery';
  String search = '';
  Set<int> completed = {};

  @override
  void initState() {
    super.initState();
    lessonsFuture = repository.loadLessons();
    quizzesFuture = repository.loadQuizzes();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => completed = (prefs.getStringList('completed_days') ?? []).map(int.parse).toSet());
  }

  Future<void> _markComplete(int day) async {
    final next = {...completed, day};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_days', next.map((e) => e.toString()).toList());
    if (mounted) setState(() => completed = next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ছোট্ট পাঠশালা', style: TextStyle(fontWeight: FontWeight.w800)),
        Text('শেখা হোক আনন্দের গল্প', style: TextStyle(fontSize: 11)),
      ]),
      actions: [
        IconButton(tooltip: 'কুইজ', onPressed: () async {
          final navigator = Navigator.of(context);
          final questions = await quizzesFuture;
          if (!mounted) return;
          navigator.push(MaterialPageRoute(builder: (_) => QuizScreen(questions: questions.where((q) => q.level == selectedLevel).toList())));
        }, icon: const Icon(Icons.quiz_outlined)),
      ],
    ),
    body: FutureBuilder<List<Lesson>>(
      future: lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _ErrorView(message: 'পাঠ লোড করা যায়নি: ${snapshot.error}');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final all = snapshot.data!;
        final filtered = all.where((l) => l.level == selectedLevel && (search.isEmpty || l.title.toLowerCase().contains(search.toLowerCase()) || l.subject.toLowerCase().contains(search.toLowerCase()))).toList();
        final totalForLevel = all.where((l) => l.level == selectedLevel).length;
        final doneForLevel = all.where((l) => l.level == selectedLevel && completed.contains(l.day)).length;
        return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 28), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF246B5A), Color(0xFF68A88A)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('আজকের শেখা, আগামী দিনের শক্তি!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('গল্প, ছবি, অনুশীলন ও কুইজে আনন্দ করে শেখো।', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 18),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: totalForLevel == 0 ? 0 : doneForLevel / totalForLevel, minHeight: 9, backgroundColor: Colors.white30, color: Colors.amber)),
              const SizedBox(height: 7),
              Text('এই শ্রেণিতে $doneForLevel / $totalForLevel পাঠ সম্পন্ন', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('তোমার শ্রেণি বেছে নাও', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: levels.entries.map((entry) => ChoiceChip(
            label: Text(entry.value), selected: selectedLevel == entry.key,
            onSelected: (_) => setState(() => selectedLevel = entry.key),
          )).toList()),
          const SizedBox(height: 18),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'পাঠ বা বিষয় খুঁজুন', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            onChanged: (value) => setState(() => search = value),
          ),
          const SizedBox(height: 16),
          Row(children: [const Expanded(child: Text('আজকের পাঠগুলো', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Text('${filtered.length}টি পাঠ')]),
          const SizedBox(height: 8),
          if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('এই শ্রেণিতে এখনো পাঠ পাওয়া যায়নি।')),
          ...filtered.map((lesson) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              leading: CircleAvatar(backgroundColor: const Color(0xFFE4F2E9), child: Text('${lesson.day}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${lesson.subject}  •  ${completed.contains(lesson.day) ? "সম্পন্ন" : "শিখি"}'),
              trailing: Icon(completed.contains(lesson.day) ? Icons.check_circle : Icons.chevron_right, color: completed.contains(lesson.day) ? Colors.green : null),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson, onComplete: () => _markComplete(lesson.day)))),
            ),
          )),
        ]);
      },
    ),
  );
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson, required this.onComplete});
  final Lesson lesson;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('পাঠ ${lesson.day}')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Chip(label: Text('${levels[lesson.level] ?? lesson.level} • ${lesson.subject}')),
      _LessonSection(title: 'আজকের লক্ষ্য', body: lesson.objective, icon: Icons.flag_outlined),
      _LessonSection(title: 'গল্পে শিখি', body: lesson.story, icon: Icons.auto_stories_outlined),
      _LessonSection(title: 'উদাহরণ', body: lesson.examples.join('\n'), icon: Icons.lightbulb_outline),
      _LessonSection(title: 'চলো কাজ করি', body: lesson.activity, icon: Icons.brush_outlined),
      _LessonSection(title: 'নিজে চেষ্টা করো', body: lesson.practice, icon: Icons.edit_note),
      _LessonSection(title: 'উত্তর', body: lesson.answers, icon: Icons.check_circle_outline),
      _LessonSection(title: 'অভিভাবকের জন্য', body: lesson.parentTip, icon: Icons.family_restroom),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () { onComplete(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাঠটি সম্পন্ন হিসেবে সংরক্ষণ হয়েছে।'))); }, icon: const Icon(Icons.done), label: const Text('পাঠ সম্পন্ন')),
    ]),
  );
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.title, required this.body, required this.icon});
  final String title, body;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
      if (body.isNotEmpty) ...[const SizedBox(height: 10), SelectableText(body, style: const TextStyle(height: 1.55, fontSize: 15))],
    ])),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.questions});
  final List<QuizQuestion> questions;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0, score = 0;
  String? selected;
  bool answered = false;
  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return Scaffold(appBar: AppBar(title: const Text('কুইজ')), body: const Center(child: Text('এই শ্রেণির জন্য কুইজ পাওয়া যায়নি।')));
    final q = widget.questions[index % widget.questions.length];
    return Scaffold(
      appBar: AppBar(title: Text('কুইজ • ${index + 1}/${widget.questions.length}')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        LinearProgressIndicator(value: (index + 1) / widget.questions.length),
        const SizedBox(height: 24),
        Text(q.subject, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(q.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...q.options.entries.map((entry) {
          final isCorrect = entry.key == q.answer;
          final isSelected = entry.key == selected;
          final color = answered && isCorrect ? Colors.green.shade100 : answered && isSelected ? Colors.red.shade100 : Colors.white;
          return Card(color: color, child: ListTile(
            title: Text('${entry.key}. ${entry.value}'),
            trailing: answered && isCorrect ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: answered ? null : () => setState(() { selected = entry.key; answered = true; if (selected == q.answer) score++; }),
          ));
        }),
        if (answered) Card(color: const Color(0xFFEAF4ED), child: Padding(padding: const EdgeInsets.all(14), child: Text(q.explanation))),
        const SizedBox(height: 16),
        FilledButton(onPressed: answered ? () {
          if (index + 1 >= widget.questions.length) {
            showDialog(context: context, builder: (_) => AlertDialog(title: const Text('কুইজ শেষ!'), content: Text('তোমার স্কোর: $score / ${widget.questions.length}'), actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('শেষ'))]));
          } else { setState(() { index++; selected = null; answered = false; }); }
        } : null, child: Text(index + 1 >= widget.questions.length ? 'ফলাফল দেখো' : 'পরের প্রশ্ন')),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message, textAlign: TextAlign.center)));
}
