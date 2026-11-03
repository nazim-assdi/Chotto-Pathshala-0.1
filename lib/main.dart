import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

class VoiceCoach {
  static final FlutterTts _tts = FlutterTts();
  static Future<void> speak(String text, {bool english = false}) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(0.42);
      await _tts.setVolume(1.0);
      await _tts.setLanguage(english ? 'en-US' : 'bn-BD');
      await _tts.speak(text);
    } catch (_) { /* Voice is optional; gameplay continues silently. */ }
  }
}

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
  String get progressId => '$level-$day';

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
  Set<String> completed = {};
  String selectedSubject = 'সব বিষয়';
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    lessonsFuture = repository.loadLessons();
    quizzesFuture = repository.loadQuizzes();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList('completed_lesson_ids') ?? []).toSet();
    final oldDays = (prefs.getStringList('completed_days') ?? []).map((e) => int.tryParse(e)).whereType<int>().toSet();
    if (saved.isEmpty && oldDays.isNotEmpty) {
      final lessons = await lessonsFuture;
      saved.addAll(lessons.where((l) => oldDays.contains(l.day)).map((l) => l.progressId));
      await prefs.setStringList('completed_lesson_ids', saved.toList());
    }
    if (mounted) setState(() => completed = saved);
  }

  Future<void> _markComplete(Lesson lesson) async {
    final next = {...completed, lesson.progressId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_lesson_ids', next.toList());
    final legacy = (prefs.getStringList('completed_days') ?? []).toSet()..add('${lesson.day}');
    await prefs.setStringList('completed_days', legacy.toList());
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
        final levelLessons = all.where((l) => l.level == selectedLevel).toList();
        final subjects = levelLessons.map((l) => l.subject).where((s) => s.trim().isNotEmpty).toSet().toList()..sort();
        final filtered = levelLessons.where((l) => (selectedSubject == 'সব বিষয়' || l.subject == selectedSubject) && (search.isEmpty || l.title.toLowerCase().contains(search.toLowerCase()) || l.subject.toLowerCase().contains(search.toLowerCase()))).toList();
        final totalForLevel = levelLessons.length;
        final doneForLevel = levelLessons.where((l) => completed.contains(l.progressId)).length;
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
          const SizedBox(height: 16),
          SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('পাঠ')), ButtonSegment(value: 1, label: Text('শব্দ ও ছবি')), ButtonSegment(value: 2, label: Text('গেম'))], selected: {selectedTab}, onSelectionChanged: (v) => setState(() => selectedTab = v.first)),
          if (selectedTab == 0) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(labelText: 'বিষয় বেছে নাও', border: OutlineInputBorder()), items: ['সব বিষয়', ...subjects].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => selectedSubject = v ?? 'সব বিষয়')),
          const SizedBox(height: 12),
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
              subtitle: Text('${lesson.subject}  •  ${completed.contains(lesson.progressId) ? "সম্পন্ন" : "শিখি"}'),
              trailing: Icon(completed.contains(lesson.progressId) ? Icons.check_circle : Icons.chevron_right, color: completed.contains(lesson.progressId) ? Colors.green : null),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson, onComplete: () => _markComplete(lesson)))),
            ),
          )),
          ] else if (selectedTab == 1) const WordGallery() else FutureBuilder<List<QuizQuestion>>(future: quizzesFuture, builder: (context, qs) {
            if (!qs.hasData) return const Center(child: CircularProgressIndicator());
            final bank = qs.data!.where((q) => q.level == selectedLevel).toList();
            final gameSubjects = <String>{...subjects};
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 12), const Text('প্রতিটি বিষয়ের আলাদা গেম', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Expanded(child: ListView(children: gameSubjects.map((name) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.sports_esports)), title: Text(name), subtitle: Text(_gameTitle(name)), trailing: const Icon(Icons.play_arrow), onTap: () { final qsForSubject = bank.where((q) => q.subject == name).toList(); Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectGameScreen(subject: name, questions: qsForSubject))); }))).toList()))]);
          }),
        ]);
      },
    ),
  );
}

String _gameTitle(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('বাংলা')) return 'অক্ষর চেনা ও শব্দ মেলানো';
  if (s.contains('english')) return 'Alphabet, Phonics & Spelling';
  if (s.contains('গণিত') || s.contains('math')) return 'সংখ্যা, গণনা ও হিসাব';
  if (s.contains('বিজ্ঞান') || s.contains('পরিবেশ')) return 'প্রকৃতি ও বিজ্ঞান আবিষ্কার';
  if (s.contains('নিরাপত্তা') || s.contains('জীবন')) return 'ভালো অভ্যাস ও নিরাপত্তা';
  return 'বিষয়ভিত্তিক জ্ঞান খেলা';
}

class WordGallery extends StatefulWidget {
  const WordGallery({super.key});
  @override State<WordGallery> createState() => _WordGalleryState();
}
class _WordGalleryState extends State<WordGallery> {
  bool english = false;
  static const words = <List<String>>[
    ['অ','অজগর','এক ধরনের বড় সাপ','🐍'], ['আ','আম','মিষ্টি ফল','🥭'], ['ই','ইঁদুর','ছোট প্রাণী','🐭'], ['ঈ','ঈগল','বড় শিকারি পাখি','🦅'], ['উ','উট','মরুভূমির প্রাণী','🐪'], ['ক','কলা','হলুদ ফল','🍌'], ['খ','খরগোশ','লম্বা কানওয়ালা প্রাণী','🐰'], ['গ','গরু','গৃহপালিত প্রাণী','🐄'], ['চ','চাঁদ','রাতের আকাশে দেখা যায়','🌙'],
    ['A','Apple','আপেল','🍎'], ['B','Ball','বল','⚽'], ['C','Cat','বিড়াল','🐱'], ['D','Dog','কুকুর','🐶'], ['E','Elephant','হাতি','🐘'], ['F','Fish','মাছ','🐟'], ['G','Grapes','আঙুর','🍇'], ['H','House','বাড়ি','🏠'], ['I','Ice cream','আইসক্রিম','🍦'],
  ];
  @override Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('বাংলা বর্ণ')), ButtonSegment(value: true, label: Text('English ABC'))], selected: {english}, onSelectionChanged: (v) => setState(() => english = v.first))),
    Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.05, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: words.where((w) => RegExp(r'[A-Za-z]').hasMatch(w[0]) == english).length, itemBuilder: (context, i) {
      final w = words.where((x) => RegExp(r'[A-Za-z]').hasMatch(x[0]) == english).toList()[i];
      return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => VoiceCoach.speak('${w[0]}. ${w[1]}', english: english), child: Padding(padding: const EdgeInsets.all(10), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(w[3], style: const TextStyle(fontSize: 42)), Text(w[0], style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), Text(w[1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(w[2], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)), const Icon(Icons.volume_up)]))));
    }))
  ]);
}

class SubjectGameScreen extends StatefulWidget {
  const SubjectGameScreen({super.key, required this.subject, required this.questions});
  final String subject; final List<QuizQuestion> questions;
  @override State<SubjectGameScreen> createState() => _SubjectGameScreenState();
}
class _SubjectGameScreenState extends State<SubjectGameScreen> {
  int index = 0, score = 0; String? selected; bool answered = false;
  @override Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return Scaffold(appBar: AppBar(title: Text(widget.subject)), body: const Center(child: Text('এই বিষয়ের গেমের প্রশ্ন এখনো যোগ করা হয়নি।')));
    final q = widget.questions[index];
    return Scaffold(appBar: AppBar(title: Text('${widget.subject} গেম')), body: ListView(padding: const EdgeInsets.all(18), children: [
      Card(color: Theme.of(context).colorScheme.primaryContainer, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text(_gameTitle(widget.subject), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), Text('স্কোর: $score')] ))),
      const SizedBox(height: 14), LinearProgressIndicator(value: (index + 1) / widget.questions.length), const SizedBox(height: 20),
      Text(q.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
      ...q.options.entries.map((e) { final correct = e.key == q.answer; final chosen = e.key == selected; return Card(color: answered && correct ? Colors.green.shade100 : answered && chosen ? Colors.red.shade100 : null, child: ListTile(title: Text(e.value, style: const TextStyle(fontSize: 19)), trailing: answered && correct ? const Icon(Icons.check_circle, color: Colors.green) : null, onTap: answered ? null : () { setState(() { selected = e.key; answered = true; if (correct) score++; }); VoiceCoach.speak(e.value, english: RegExp(r'[A-Za-z]').hasMatch(e.value)); })); }),
      if (answered) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('${selected == q.answer ? 'দারুণ! সঠিক উত্তর।' : 'চেষ্টা ভালো হয়েছে!'} ${q.explanation}'))),
      const SizedBox(height: 12), FilledButton(onPressed: answered ? () { if (index + 1 >= widget.questions.length) { showDialog(context: context, builder: (_) => AlertDialog(title: const Text('গেম শেষ!'), content: Text('তোমার স্কোর: $score / ${widget.questions.length}'), actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('শেষ'))])); } else { setState(() { index++; selected = null; answered = false; }); } } : null, child: Text(index + 1 >= widget.questions.length ? 'ফলাফল দেখো' : 'পরের ধাপ'))
    ]));
  }
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
