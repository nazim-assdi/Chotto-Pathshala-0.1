import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const ChottoPathshalaApp());

const lessonFiles = [
  'arabic-foundations.json',
  'class-one-251-300.json', 'class-one-306-365.json',
  'class-two-366-389.json', 'kg-151-200.json', 'kg-205-250.json',
  'kg-246-250.json', 'nursery-061-110.json', 'nursery-111-150.json',
  'nursery-alphabets-151-254.json',
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
  static bool enabled = true;

  static Future<void> speak(String text, {bool english = false, bool arabic = false}) async {
    await _say(text, language: arabic ? 'ar-SA' : (english ? 'en-US' : 'bn-BD'), rate: 0.42, pitch: 1.0);
  }

  static Future<void> cheer() async {
    await _say('দারুণ! একদম সঠিক উত্তর! খুব ভালো করেছো!', rate: 0.48, pitch: 1.18);
  }

  static Future<void> encourage() async {
    await _say('কোনো সমস্যা নেই। আবার চেষ্টা করো, তুমি পারবে!', rate: 0.44, pitch: 1.08);
  }

  static Future<void> victory() async {
    await _say('অভিনন্দন! তুমি গেমটি শেষ করেছো! দারুণ খেলেছো!', rate: 0.48, pitch: 1.2);
  }

  static Future<void> _say(String text, {String language = 'bn-BD', required double rate, required double pitch}) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(pitch);
      await _tts.setVolume(1.0);
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } catch (_) {
      // Voice is optional; gameplay continues silently if no matching device voice exists.
    }
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
    level: _normalizeLevel(json['level']?.toString() ?? 'nursery'),
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
    level: _normalizeLevel(json['level']?.toString() ?? 'nursery'),
    subject: json['subject']?.toString() ?? 'অন্যান্য',
    question: json['question']?.toString() ?? '',
    options: (json['options'] as Map? ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
    answer: json['answer']?.toString() ?? '',
    explanation: json['explanation']?.toString() ?? '',
  );
}

String _normalizeLevel(String value) => value.trim().toLowerCase().replaceAll('_', '-');

class LearningRepository {
  Future<List<Lesson>> loadLessons() async {
    final result = <Lesson>[];
    for (final file in lessonFiles) {
      final raw = await rootBundle.loadString('app/src/main/assets/content/lessons/$file');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      result.addAll((data['lessons'] as List).map((e) => Lesson.fromJson(e as Map<String, dynamic>)));
    }
    result.sort((a, b) {
      const levelOrder = ['playgroup', 'nursery', 'kg', 'class-one', 'class-two'];
      final byLevel = levelOrder.indexOf(a.level).compareTo(levelOrder.indexOf(b.level));
      if (byLevel != 0) return byLevel;
      final byDay = a.day.compareTo(b.day);
      if (byDay != 0) return byDay;
      return a.subject.compareTo(b.subject);
    });
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

class AppThemeController {
  static final ValueNotifier<String> selected = ValueNotifier<String>('green');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    selected.value = prefs.getString('setting_theme') ?? 'green';
  }

  static Future<void> setTheme(String value) async {
    selected.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_theme', value);
  }

  static ThemeData build(String name) {
    final dark = name == 'dark';
    final colors = <String, Color>{
      'green': const Color(0xFF16834A),
      'blue': const Color(0xFF2878C8),
      'purple': const Color(0xFF7652B5),
      'pink': const Color(0xFFC34F83),
      'dark': const Color(0xFF80CBC4),
    };
    final seed = colors[name] ?? colors['green']!;
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: dark ? Brightness.dark : Brightness.light);
    final page = dark ? const Color(0xFF111820) : (name == 'blue' ? const Color(0xFFEAF4FF) : name == 'purple' ? const Color(0xFFF4EEFF) : name == 'pink' ? const Color(0xFFFFF0F5) : const Color(0xFFEAF8F0));
    final surface = dark ? const Color(0xFF202B36) : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      canvasColor: page,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF202B36) : seed,
        foregroundColor: dark ? Colors.white : Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: dark ? 1 : 3,
        shadowColor: dark ? Colors.black26 : seed.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: BorderSide(color: scheme.outlineVariant)),
        margin: const EdgeInsets.only(bottom: 10),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.outlineVariant)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      chipTheme: ChipThemeData(backgroundColor: surface, selectedColor: scheme.secondaryContainer),
    );
  }
}

class ChottoPathshalaApp extends StatefulWidget {
  const ChottoPathshalaApp({super.key});
  @override State<ChottoPathshalaApp> createState() => _ChottoPathshalaAppState();
}
class _ChottoPathshalaAppState extends State<ChottoPathshalaApp> {
  @override void initState() { super.initState(); AppThemeController.load(); }
  @override Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: AppThemeController.selected,
    builder: (context, themeName, _) => MaterialApp(
      title: 'ছোট্ট পাঠশালা',
      debugShowCheckedModeBanner: false,
      theme: AppThemeController.build(themeName),
      home: const HomeScreen(),
    ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(22))),
      title: const Text('📚 ছোট্ট পাঠশালা'),
      actions: [
        IconButton(tooltip: '🏆 আমার অগ্রগতি', onPressed: () async { final navigator = Navigator.of(context); final lessons = await lessonsFuture; if (!mounted) return; navigator.push(MaterialPageRoute(builder: (_) => ProgressScreen(lessons: lessons.where((l) => l.level == selectedLevel).toList(), completed: completed))); }, icon: const Icon(Icons.emoji_events_outlined)),
        IconButton(tooltip: '👨‍👩‍👧 অভিভাবক কর্নার', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentCornerScreen())), icon: const Icon(Icons.family_restroom)),
        IconButton(tooltip: '⚙️ সেটিংস', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), icon: const Icon(Icons.settings_outlined)),
        IconButton(tooltip: '🧠 কুইজ', onPressed: () async { final navigator = Navigator.of(context); final questions = await quizzesFuture; if (!mounted) return; navigator.push(MaterialPageRoute(builder: (_) => QuizScreen(questions: questions.where((q) => q.level == selectedLevel).toList()))); }, icon: const Icon(Icons.quiz_outlined)),
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
              gradient: const LinearGradient(colors: [Color(0xFF00A83B), Color(0xFF65D94D)]),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x33205B35), blurRadius: 12, offset: Offset(0, 5))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🌟 আজকের শেখা, আগামী দিনের শক্তি!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('📖 গল্প, 🖼️ ছবি, ✍️ অনুশীলন ও 🧠 কুইজে আনন্দ করে শেখো।', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 18),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: totalForLevel == 0 ? 0 : doneForLevel / totalForLevel, minHeight: 9, backgroundColor: Colors.white30, color: Colors.amber)),
              const SizedBox(height: 7),
              Text('📈 এই শ্রেণিতে $doneForLevel / $totalForLevel পাঠ সম্পন্ন', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('🏫 তোমার শ্রেণি বেছে নাও', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.35, crossAxisSpacing: 10, mainAxisSpacing: 10,
            children: levels.entries.map((entry) {
              const colors = [Color(0xFFF1D6FF), Color(0xFFFFF0A8), Color(0xFFD9F7D2), Color(0xFFFFD8AE), Color(0xFFD8ECFF)];
              const icons = [Icons.child_care, Icons.face_3, Icons.school, Icons.menu_book, Icons.auto_stories];
              final idx = levels.keys.toList().indexOf(entry.key);
              final chosen = selectedLevel == entry.key;
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => setState(() { selectedLevel = entry.key; selectedSubject = 'সব বিষয়'; search = ''; }),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[idx], borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: chosen ? const Color(0xFF08A83C) : Colors.white, width: chosen ? 3 : 2),
                    boxShadow: const [BoxShadow(color: Color(0x22205B35), blurRadius: 5, offset: Offset(0, 3))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(levelEmoji(entry.key), style: const TextStyle(fontSize: 22)), const SizedBox(width: 5), Icon(icons[idx], size: 22, color: const Color(0xFF145A32))]),
                    const SizedBox(height: 4),
                    Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    if (chosen) const Text('নির্বাচিত', style: TextStyle(fontSize: 10, color: Color(0xFF08752D), fontWeight: FontWeight.bold)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('📖 পাঠ')), ButtonSegment(value: 1, label: Text('🖼️ শব্দ ও ছবি')), ButtonSegment(value: 2, label: Text('🎮 গেম'))], selected: {selectedTab}, onSelectionChanged: (v) => setState(() => selectedTab = v.first)),
          if (selectedTab == 0) ...[
          const SizedBox(height: 12),
          const Text('📚 বিষয় নির্বাচন করো — বিষয় চাপ দিলে সেই বিষয়ের পাঠ দেখাবে', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['সব বিষয়', ...subjects].map((subject) => ChoiceChip(
              label: Text(subject),
              selected: selectedSubject == subject,
              avatar: const Icon(Icons.menu_book_outlined, size: 17),
              onSelected: (_) => setState(() { selectedSubject = subject; search = ''; }),
              selectedColor: const Color(0xFFCFF2D8),
              backgroundColor: Colors.white,
              side: BorderSide(color: selectedSubject == subject ? const Color(0xFF08A83C) : const Color(0xFFDCE9F2)),
              labelStyle: TextStyle(fontWeight: selectedSubject == subject ? FontWeight.w900 : FontWeight.w600),
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: '🔎 পাঠ বা বিষয় খুঁজুন', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            onChanged: (value) => setState(() => search = value),
          ),
          const SizedBox(height: 16),
          Row(children: [const Expanded(child: Text('📅 আজকের পাঠগুলো', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Text('${filtered.length}টি পাঠ')]),
          const SizedBox(height: 8),
          if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('📭 এই শ্রেণিতে এখনো পাঠ পাওয়া যায়নি।')),
          for (final subject in (selectedSubject == 'সব বিষয়' ? (filtered.map((l) => l.subject).toSet().toList()..sort()) : [selectedSubject])) ...[
            Padding(padding: const EdgeInsets.only(top: 10, bottom: 8), child: Row(children: [
              Expanded(child: Text(subject, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF246B5A)))),
              Text('${filtered.where((l) => l.subject == subject).length}টি পাঠ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ])),
            ...filtered.where((l) => l.subject == subject).map((lesson) => Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson, onComplete: () => _markComplete(lesson)))),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0F7FF)]),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    leading: Container(
                      width: 48, height: 48, alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFFE2F5E8), borderRadius: BorderRadius.circular(16)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('📖', style: TextStyle(fontSize: 16)), Text('${lesson.day}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF08752D)))]),
                    ),
                    title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(completed.contains(lesson.progressId) ? '✅ পাঠ সম্পন্ন' : '👉 পাঠটি শিখতে এখানে চাপ দাও'),
                    trailing: Icon(completed.contains(lesson.progressId) ? Icons.check_circle : Icons.arrow_forward_ios, color: const Color(0xFF08A83C), size: 19),
                  ),
                ),
              ),
            )),
          ],
          ] else if (selectedTab == 1) const WordGallery() else FutureBuilder<List<QuizQuestion>>(future: quizzesFuture, builder: (context, qs) {
            if (!qs.hasData) return const Center(child: CircularProgressIndicator());
            final bank = qs.data!.where((q) => q.level == selectedLevel).toList();
            final gameSubjects = <String>{...subjects};
            if (selectedLevel == 'playgroup' || selectedLevel == 'nursery') { gameSubjects.addAll(['বাংলা', 'English', 'আরবি']); }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 12), const Text('🎮 প্রতিটি বিষয়ের আলাদা গেম', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: gameSubjects.map((name) => Card(child: ListTile(leading: const CircleAvatar(child: Text('🎮')), title: Text(name), subtitle: Text(_gameTitle(name)), trailing: const Icon(Icons.play_arrow), onTap: () { if ((selectedLevel == 'playgroup' || selectedLevel == 'nursery') && _isLetterSubject(name)) { Navigator.push(context, MaterialPageRoute(builder: (_) => LetterGameScreen(subject: name))); return; } var qsForSubject = bank.where((q) => q.subject == name).toList(); if (qsForSubject.isEmpty) { qsForSubject = levelLessons.where((l) => l.subject == name && l.practice.isNotEmpty && l.answers.isNotEmpty).take(10).map((l) => QuizQuestion(id: l.progressId, level: l.level, subject: l.subject, question: l.practice, options: {'A': l.answers, 'B': 'আবার ভালো করে পড়ি', 'C': 'এখনো শিখিনি'}, answer: 'A', explanation: l.answers)).toList(); } Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectGameScreen(subject: name, questions: qsForSubject))); }))).toList())]);
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

bool _isLetterSubject(String subject) { final s = subject.toLowerCase(); return s.contains('বাংলা') || s.contains('english') || s.contains('ইংরেজি') || s.contains('আরবি') || s.contains('arabic'); }


String levelEmoji(String level) {
  switch (_normalizeLevel(level)) {
    case 'playgroup': return '🧸';
    case 'nursery': return '🧩';
    case 'kg': return '🎒';
    case 'class-one': return '✏️';
    case 'class-two': return '📚';
    default: return '🏫';
  }
}

String sectionEmoji(String title) {
  if (title.contains('লক্ষ্য')) return '🎯';
  if (title.contains('গল্প')) return '📖';
  if (title.contains('উদাহরণ')) return '💡';
  if (title.contains('কাজ')) return '🎨';
  if (title.contains('চেষ্টা') || title.contains('অনুশীলন')) return '✍️';
  if (title.contains('উত্তর')) return '✅';
  if (title.contains('অভিভাবক')) return '👨‍👩‍👧';
  return '🌟';
}

String numberEmoji(int number) {
  const symbols = ['🍎', '⭐', '🐟', '🚗', '🌼', '🦋', '🐥', '⚽', '🍓', '🎈'];
  return symbols[(number - 1).clamp(0, symbols.length - 1).toInt()];
}

String themeEmoji(String name) {
  switch (name) {
    case 'green': return '🍃';
    case 'blue': return '💧';
    case 'purple': return '✨';
    case 'pink': return '💗';
    case 'dark': return '🌙';
    default: return '🎨';
  }
}

class WordGallery extends StatefulWidget {
  const WordGallery({super.key});
  @override
  State<WordGallery> createState() => _WordGalleryState();
}

class _WordGalleryState extends State<WordGallery> {
  String category = 'বাংলা';

  // প্রতিটি সারি: বর্ণ/সংখ্যা, শব্দ, বাংলা অর্থ, চিত্র, ঐচ্ছিক SVG asset।
  static const bangla = <List<String>>[
    ['অ','অজগর','বড় সাপ','🐍'],['আ','আম','মিষ্টি ফল','🥭','assets/images/words/mango.svg'],
    ['ই','ইলিশ','একটি মাছ','🐟'],['ঈ','ঈগল','শিকারি পাখি','🦅'],['উ','উট','মরুর প্রাণী','🐪'],
    ['ঊ','ঊষা','ভোরের আলো','🌅'],['ঋ','ঋতু','বছরের সময়','🌦️'],['এ','একতারা','বাদ্যযন্ত্র','🎸'],
    ['ঐ','ঐরাবত','পুরাণের হাতি','🐘'],['ও','ওল','সবজি','🍠'],['ঔ','ঔষধ','ওষুধ','💊'],
    ['ক','কলা','হলুদ ফল','🍌','assets/images/words/banana.svg'],['খ','খরগোশ','লম্বা কানওয়ালা প্রাণী','🐇'],
    ['গ','গরু','গৃহপালিত প্রাণী','🐄','assets/images/words/cow.svg'],['ঘ','ঘড়ি','সময় দেখায়','⏰'],
    ['ঙ','ব্যাঙ','জল ও ডাঙায় থাকে','🐸'],['চ','চাঁদ','রাতের আকাশে','🌙'],['ছ','ছাতা','বৃষ্টি থেকে বাঁচায়','☂️'],
    ['জ','জাহাজ','পানিতে চলে','🚢'],['ঝ','ঝিনুক','সমুদ্রে পাওয়া যায়','🐚'],['ঞ','মিঞা','ঞ-যুক্ত শব্দ','👨'],
    ['ট','টমেটো','লাল সবজি','🍅'],['ঠ','ঠেলাগাড়ি','জিনিস বহন করে','🛒'],['ড','ডাব','কচি নারকেল','🥥'],
    ['ঢ','ঢোল','বাদ্যযন্ত্র','🥁'],['ণ','গণনা','সংখ্যা গোনা','🔢'],['ত','তরমুজ','রসালো ফল','🍉'],
    ['থ','থালা','খাবারের পাত্র','🍽️'],['দ','দোয়েল','জাতীয় পাখি','🐦'],['ধ','ধান','শস্য','🌾'],
    ['ন','নৌকা','নদীতে চলে','🛶'],['প','পাখি','আকাশে উড়ে','🐦'],['ফ','ফুল','সুন্দর ও সুগন্ধি','🌺','assets/images/words/flower.svg'],
    ['ব','বই','পড়ার জিনিস','📚'],['ভ','ভালুক','বনের প্রাণী','🐻'],['ম','মাছ','পানিতে থাকে','🐟'],
    ['য','যব','এক ধরনের শস্য','🌾'],['র','রংধনু','আকাশে দেখা যায়','🌤️'],['ল','লেবু','টক ফল','🍋'],
    ['শ','শাপলা','জলজ ফুল','🪷'],['ষ','ষাঁড়','গরুর পুরুষ','🐂'],['স','সূর্য','দিনের আলো দেয়','☀️','assets/images/words/sun.svg'],
    ['হ','হাতি','বড় স্থলচর প্রাণী','🐘'],['ড়','গাড়ি','চাকার যান','🚗'],['ঢ়','আষাঢ়','বাংলা মাস','🌧️'],
    ['য়','সময়','ঘড়িতে দেখা যায়','⌚'],['ৎ','হঠাৎ','অপ্রত্যাশিতভাবে','💡'],['ং','বাংলা','আমাদের ভাষা','🔤'],
    ['ঃ','দুঃখ','মনের অনুভূতি','😢'],['ঁ','চাঁদ','আকাশে ওঠে','🌙'],
  ];

  static const english = <List<String>>[
    ['A','Apple','আপেল','🍎','assets/images/words/apple.svg'],['B','Ball','বল','⚽'],
    ['C','Cat','বিড়াল','🐱','assets/images/words/cat.svg'],['D','Dog','কুকুর','🐶','assets/images/words/dog.svg'],
    ['E','Elephant','হাতি','🐘'],['F','Fish','মাছ','🐟'],['G','Grapes','আঙুর','🍇'],
    ['H','House','বাড়ি','🏠'],['I','Ice cream','আইসক্রিম','🍦'],['J','Jug','জগ','🫗'],
    ['K','Kite','ঘুড়ি','🪁'],['L','Lion','সিংহ','🦁'],['M','Mango','আম','🥭','assets/images/words/mango.svg'],
    ['N','Nest','পাখির বাসা','🪺'],['O','Orange','কমলা','🍊'],['P','Parrot','টিয়া পাখি','🦜'],
    ['Q','Queen','রানি','👑'],['R','Rabbit','খরগোশ','🐇'],['S','Sun','সূর্য','☀️','assets/images/words/sun.svg'],
    ['T','Tree','গাছ','🌳','assets/images/words/tree.svg'],['U','Umbrella','ছাতা','☂️'],
    ['V','Van','ভ্যানগাড়ি','🚐'],['W','Watch','ঘড়ি','⌚'],['X','Xylophone','জাইলোফোন','🎼'],
    ['Y','Yo-yo','খেলনা','🪀'],['Z','Zebra','জেব্রা','🦓'],
  ];

  static const arabic = <List<String>>[
    ['ا','أَسَد','সিংহ','🦁'],['ب','بَطَّة','হাঁস','🦆'],['ت','تُفَّاح','আপেল','🍎','assets/images/words/apple.svg'],
    ['ث','ثَعْلَب','শিয়াল','🦊'],['ج','جَمَل','উট','🐪'],['ح','حِصَان','ঘোড়া','🐎'],
    ['خ','خَرُوف','ভেড়া','🐑'],['د','دُبّ','ভালুক','🐻'],['ذ','ذُرَّة','ভুট্টা','🌽'],
    ['ر','رُمَّان','ডালিম','🍎'],['ز','زَهْرَة','ফুল','🌺','assets/images/words/flower.svg'],
    ['س','سَمَك','মাছ','🐟'],['ش','شَمْس','সূর্য','☀️','assets/images/words/sun.svg'],
    ['ص','صَقْر','বাজপাখি','🦅'],['ض','ضِفْدَع','ব্যাঙ','🐸'],['ط','طَائِرَة','বিমান','✈️'],
    ['ظ','ظَبْي','হরিণ','🦌'],['ع','عَيْن','চোখ','👁️'],['غ','غَزَال','হরিণ','🦌'],
    ['ف','فِيل','হাতি','🐘'],['ق','قَمَر','চাঁদ','🌙'],['ك','كِتَاب','বই','📚'],
    ['ل','لَيْمُون','লেবু','🍋'],['م','مَوْز','কলা','🍌','assets/images/words/banana.svg'],
    ['ن','نَمِر','বাঘ','🐅'],['ه','هِلال','অর্ধচন্দ্র','🌙'],['و','وَرْدَة','গোলাপ','🌹'],['ي','يَد','হাত','✋'],
  ];

  static const numberNames = [
    ['এক','One'],['দুই','Two'],['তিন','Three'],['চার','Four'],['পাঁচ','Five'],
    ['ছয়','Six'],['সাত','Seven'],['আট','Eight'],['নয়','Nine'],['দশ','Ten'],
  ];

  @override
  Widget build(BuildContext context) {
    final isMath = category == 'গণিত';
    final data = category == 'বাংলা' ? bangla : category == 'English' ? english : arabic;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Text('🔤 বর্ণ, 💬 শব্দ, 🖼️ ছবি ও 🔊 উচ্চারণ শিখি', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF145A32))),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'বাংলা', label: Row(mainAxisSize: MainAxisSize.min, children: [Text('🇧🇩'), SizedBox(width: 4), Text('বাংলা')])),
              ButtonSegment(value: 'English', label: Row(mainAxisSize: MainAxisSize.min, children: [Text('🔠'), SizedBox(width: 4), Text('English')])),
              ButtonSegment(value: 'আরবি', label: Row(mainAxisSize: MainAxisSize.min, children: [Text('🕌'), SizedBox(width: 4), Text('العربية')])),
              ButtonSegment(value: 'গণিত', label: Row(mainAxisSize: MainAxisSize.min, children: [Text('🔢'), SizedBox(width: 4), Text('গণিত ১–১০')])),
            ],
            selected: {category}, onSelectionChanged: (v) => setState(() => category = v.first),
          ),
        ),
      ),
      if (isMath)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 226,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final n = index + 1;
            final names = numberNames[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => VoiceCoach.speak('${names[0]}. ${names[1]}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NumberDots(count: n),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${numberEmoji(n)} × $n',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$n  ${names[0]}',
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF087E38)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(names[1], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '🧮 $nটি বস্তু গুনে দেখো',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, height: 1.15),
                      ),
                      const SizedBox(height: 2),
                      const Icon(Icons.volume_up, size: 18, color: Color(0xFF087E38)),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      else
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 18),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.76, crossAxisSpacing: 9, mainAxisSpacing: 10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final w = data[index];
            final image = w.length > 4 ? w[4] : null;
            return Card(clipBehavior: Clip.antiAlias, child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => VoiceCoach.speak(
                category == 'আরবি' ? '${w[0]}، ${w[1]}' : category == 'English' ? '${w[0]}. ${w[1]}' : '${w[0]}. ${w[1]}. ${w[2]}',
                english: category == 'English', arabic: category == 'আরবি'),
              child: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFEAF5FF)])),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(child: Center(child: image == null
                    ? Text(w[3], style: const TextStyle(fontSize: 42))
                    : SvgPicture.asset(image, width: 68, height: 68, fit: BoxFit.contain,
                        placeholderBuilder: (_) => Text(w[3], style: const TextStyle(fontSize: 42))))),
                  Text(w[0], textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF087E38))),
                  Text(w[1], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(w[2], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10)),
                  const Icon(Icons.volume_up, size: 17, color: Color(0xFF087E38)),
                ]),
              ),
            ));
          },
        ),
    ]);
  }
}

class _NumberDots extends StatelessWidget {
  const _NumberDots({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112, height: 74,
    child: Wrap(
      alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5, runSpacing: 5,
      children: List.generate(count, (i) => Container(
        width: count > 8 ? 16 : 20, height: count > 8 ? 16 : 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: [const Color(0xFFFFC928), const Color(0xFF21B85A), const Color(0xFF3998E8), const Color(0xFFFF6B6B)][i % 4],
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
      )),
    ),
  );
}

class LetterGameScreen extends StatefulWidget {
  const LetterGameScreen({super.key, required this.subject});
  final String subject;
  @override State<LetterGameScreen> createState() => _LetterGameScreenState();
}
class _LetterGameScreenState extends State<LetterGameScreen> {
  int index = 0, score = 0;
  String? selected;
  bool answered = false;
  late final List<String> letters = widget.subject.contains('বাংলা')
      ? 'অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য়'.split(' ')
      : (widget.subject.contains('আরবি') || widget.subject.toLowerCase().contains('arabic')
          ? 'ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ط ظ ع غ ف ق ك ل م ن ه و ي'.split(' ')
          : 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(' '));
  late final List<List<String>> _questionOptions = List.generate(letters.length, (i) {
    final pool = letters.where((x) => x != letters[i]).toList();
    final start = (i * 3) % pool.length;
    final choices = [letters[i], pool[start], pool[(start + 1) % pool.length], pool[(start + 2) % pool.length]];
    // Stable ordering: choices must not change when Flutter rebuilds the screen.
    return List.generate(choices.length, (j) => choices[(j + i) % choices.length]);
  });
  @override Widget build(BuildContext context) {
    final choices = _questionOptions[index];
    return Scaffold(appBar: AppBar(title: Text('🎮 ${widget.subject} বর্ণের গেম')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('🔎 বর্ণটি চিনে সঠিকটি বেছে নাও', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        LinearProgressIndicator(value: (index + 1) / letters.length),
        const SizedBox(height: 28),
        Card(child: Padding(padding: const EdgeInsets.all(28), child: Text('✨ ${letters[index]} ✨', textAlign: TextAlign.center, style: const TextStyle(fontSize: 76, fontWeight: FontWeight.w900)))),
        if (widget.subject.contains('আরবি')) const Padding(padding: EdgeInsets.only(top: 8), child: Text('🕌 হরকত অনুশীলন: بَ  بِ  بُ  (যবর, যের, পেশ)', textAlign: TextAlign.center, style: TextStyle(fontSize: 22))),
        const SizedBox(height: 18),
        ...choices.map((choice) => Card(child: ListTile(leading: const Text('🔤'), title: Text(choice, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          onTap: answered ? null : () { setState(() { selected = choice; answered = true; if (choice == letters[index]) score++; }); VoiceCoach.speak(choice, english: widget.subject.toLowerCase().contains('english'), arabic: widget.subject.contains('আরবি')); if (choice == letters[index]) { VoiceCoach.cheer(); } else { VoiceCoach.encourage(); } }))),
        if (answered) Padding(padding: const EdgeInsets.all(12), child: Text(selected == letters[index] ? '🌟 দারুণ! সঠিক বর্ণ।' : '💛 আবার চেষ্টা করো। সঠিক বর্ণ: ${letters[index]}', textAlign: TextAlign.center)),
        FilledButton(onPressed: answered ? () { if (index == letters.length - 1) { showDialog(context: context, barrierDismissible: false, builder: (_) => CelebrationDialog(score: score, total: letters.length)); } else { setState(() { index++; selected = null; answered = false; }); } } : null, child: const Text('➡️ পরের বর্ণ')),
      ]));
  }
}

class SubjectGameScreen extends StatefulWidget {
  const SubjectGameScreen({super.key, required this.subject, required this.questions});
  final String subject; final List<QuizQuestion> questions;
  @override State<SubjectGameScreen> createState() => _SubjectGameScreenState();
}
class _SubjectGameScreenState extends State<SubjectGameScreen> {
  int index = 0, score = 0; String? selected; bool answered = false;
  @override Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return Scaffold(appBar: AppBar(title: Text('🎮 ${widget.subject}')), body: const Center(child: Text('📭 এই বিষয়ের গেমের প্রশ্ন এখনো যোগ করা হয়নি।')));
    final q = widget.questions[index];
    return Scaffold(appBar: AppBar(title: Text('🎮 ${widget.subject} গেম')), body: ListView(padding: const EdgeInsets.all(18), children: [
      Card(color: Theme.of(context).colorScheme.primaryContainer, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text('🎮 ${_gameTitle(widget.subject)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), Text('⭐ স্কোর: $score')] ))),
      const SizedBox(height: 14), LinearProgressIndicator(value: (index + 1) / widget.questions.length), const SizedBox(height: 20),
      Text('❓ ${q.question}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
      ...q.options.entries.map((e) { final correct = e.key == q.answer; final chosen = e.key == selected; return Card(color: answered && correct ? Colors.green.shade100 : answered && chosen ? Colors.red.shade100 : null, child: ListTile(leading: const Text('🔘'), title: Text(e.value, style: const TextStyle(fontSize: 19)), trailing: answered && correct ? const Icon(Icons.check_circle, color: Colors.green) : null, onTap: answered ? null : () { setState(() { selected = e.key; answered = true; if (correct) score++; }); if (correct) { VoiceCoach.cheer(); } else { VoiceCoach.encourage(); } })); }),
      if (answered) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text('${selected == q.answer ? '🌟 দারুণ! সঠিক উত্তর।' : '💛 চেষ্টা ভালো হয়েছে!'} ${q.explanation}'))),
      const SizedBox(height: 12), FilledButton(onPressed: answered ? () { if (index + 1 >= widget.questions.length) { showDialog(context: context, barrierDismissible: false, builder: (_) => CelebrationDialog(score: score, total: widget.questions.length)); } else { setState(() { index++; selected = null; answered = false; }); } } : null, child: Text(index + 1 >= widget.questions.length ? '🏆 ফলাফল দেখো' : '➡️ পরের ধাপ'))
    ]));
  }
}

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({super.key, required this.score, required this.total});
  final int score, total;
  @override State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2200),
  )..forward();

  @override void initState() {
    super.initState();
    SystemSound.play(SystemSoundType.alert);
    VoiceCoach.victory();
  }

  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context) {
    final perfect = widget.score == widget.total;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 155, width: double.infinity,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _CelebrationPainter(_controller.value, Theme.of(context).colorScheme.primary),
                child: Center(
                  child: Transform.scale(
                    scale: 0.65 + (0.45 * Curves.elasticOut.transform(_controller.value)),
                    child: const Text('🏆', style: TextStyle(fontSize: 76)),
                  ),
                ),
              ),
            ),
          ),
          Text(perfect ? 'অসাধারণ! তুমি বিজয়ী! 🎉' : 'দারুণ চেষ্টা! 🎊',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 10),
          Text('তোমার স্কোর', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('${widget.score} / ${widget.total}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(perfect ? 'সবগুলো উত্তর সঠিক! বাহ, বাহ!' : 'আরও অনুশীলন করলে আরও ভালো করবে।',
            textAlign: TextAlign.center),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.celebration),
            label: const Text('চালিয়ে যাও'),
          )),
        ]),
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  _CelebrationPainter(this.progress, this.seedColor);
  final double progress;
  final Color seedColor;

  @override void paint(Canvas canvas, Size size) {
    final colors = [seedColor, Colors.amber, Colors.pink, Colors.lightBlue, Colors.green, Colors.deepOrange];
    for (var i = 0; i < 34; i++) {
      final angle = (i * 2.399) + (progress * 1.8);
      final distance = (18 + (i % 7) * 10) * progress;
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = 72 + math.sin(angle) * distance - (progress * (i % 5) * 8);
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 1 - progress * 0.35);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * (i.isEven ? 4 : -4));
      if (i.isEven) {
        canvas.drawCircle(Offset.zero, 3 + (i % 3).toDouble(), paint);
      } else {
        canvas.drawRect(const Rect.fromLTWH(-3, -5, 6, 10), paint);
      }
      canvas.restore();
    }
  }

  @override bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seedColor != seedColor;
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson, required this.onComplete});
  final Lesson lesson;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('📖 পাঠ ${lesson.day}')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Chip(avatar: Text(levelEmoji(lesson.level)), label: Text('${levels[lesson.level] ?? lesson.level} • ${lesson.subject}')),
      _LessonSection(title: 'আজকের লক্ষ্য', body: lesson.objective, icon: Icons.flag_outlined),
      _LessonSection(title: 'গল্পে শিখি', body: lesson.story, icon: Icons.auto_stories_outlined),
      _LessonSection(title: 'উদাহরণ', body: lesson.examples.join('\n'), icon: Icons.lightbulb_outline),
      _LessonSection(title: 'চলো কাজ করি', body: lesson.activity, icon: Icons.brush_outlined),
      _LessonSection(title: 'নিজে চেষ্টা করো', body: lesson.practice, icon: Icons.edit_note),
      _LessonSection(title: 'উত্তর', body: lesson.answers, icon: Icons.check_circle_outline),
      _LessonSection(title: 'অভিভাবকের জন্য', body: lesson.parentTip, icon: Icons.family_restroom),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () { onComplete(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ পাঠটি সম্পন্ন হিসেবে সংরক্ষণ হয়েছে।'))); }, icon: const Icon(Icons.done), label: const Text('✅ পাঠ সম্পন্ন')),
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
      Row(children: [Text(sectionEmoji(title), style: const TextStyle(fontSize: 21)), const SizedBox(width: 7), Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
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
    if (widget.questions.isEmpty) return Scaffold(appBar: AppBar(title: const Text('🧠 কুইজ')), body: const Center(child: Text('📭 এই শ্রেণির জন্য কুইজ পাওয়া যায়নি।')));
    final q = widget.questions[index % widget.questions.length];
    return Scaffold(
      appBar: AppBar(title: Text('🧠 কুইজ • ${index + 1}/${widget.questions.length}')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        LinearProgressIndicator(value: (index + 1) / widget.questions.length),
        const SizedBox(height: 24),
        Text(q.subject, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('❓ ${q.question}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...q.options.entries.map((entry) {
          final isCorrect = entry.key == q.answer;
          final isSelected = entry.key == selected;
          final color = answered && isCorrect ? Colors.green.shade100 : answered && isSelected ? Colors.red.shade100 : Colors.white;
          return Card(color: color, child: ListTile(
            leading: const Text('🔘', style: TextStyle(fontSize: 21)),
            title: Text('${entry.key}. ${entry.value}'),
            trailing: answered && isCorrect ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: answered ? null : () => setState(() { selected = entry.key; answered = true; if (selected == q.answer) score++; }),
          ));
        }),
        if (answered) Card(color: const Color(0xFFEAF4ED), child: Padding(padding: const EdgeInsets.all(14), child: Text('💡 ${q.explanation}'))),
        const SizedBox(height: 16),
        FilledButton(onPressed: answered ? () {
          if (index + 1 >= widget.questions.length) {
            showDialog(context: context, barrierDismissible: false, builder: (_) => CelebrationDialog(score: score, total: widget.questions.length));
          } else { setState(() { index++; selected = null; answered = false; }); }
        } : null, child: Text(index + 1 >= widget.questions.length ? '🏆 ফলাফল দেখো' : '➡️ পরের প্রশ্ন')),
      ]),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.lessons, required this.completed});
  final List<Lesson> lessons; final Set<String> completed;
  @override Widget build(BuildContext context) {
    final done = lessons.where((l) => completed.contains(l.progressId)).length;
    final pct = lessons.isEmpty ? 0.0 : done / lessons.length;
    return Scaffold(appBar: AppBar(title: const Text('🏆 আমার অগ্রগতি')), body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF08A83C), Color(0xFF79D94F)]), borderRadius: BorderRadius.circular(26)), child: Column(children: [const Icon(Icons.emoji_events, size: 64, color: Colors.amber), const Text('🌟 তুমি দারুণ এগিয়ে যাচ্ছো!', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), Text('$done / ${lessons.length} পাঠ সম্পন্ন', style: const TextStyle(color: Colors.white, fontSize: 17)), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: pct, minHeight: 13, backgroundColor: Colors.white54, color: Colors.amber)), Text('${(pct * 100).round()}% শেষ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.5, children: [_StatTile(icon: Icons.check_circle, emoji: '✅', value: '$done', label: 'সম্পন্ন পাঠ', color: const Color(0xFFDDF8E4)), _StatTile(icon: Icons.menu_book, emoji: '📖', value: '${lessons.length-done}', label: 'বাকি পাঠ', color: const Color(0xFFFFF1C7)), _StatTile(icon: Icons.star, emoji: '⭐', value: '${done*5}', label: 'অর্জিত স্টার', color: const Color(0xFFFFE2E8)), _StatTile(icon: Icons.local_fire_department, emoji: '🔥', value: done > 0 ? 'চালু' : 'শুরু করো', label: 'শেখার যাত্রা', color: const Color(0xFFDCEEFF))]),
      const Text('📚 সম্পন্ন পাঠের তালিকা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ...lessons.where((l) => completed.contains(l.progressId)).map((l) => Card(child: ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(l.title), subtitle: Text('📖 পাঠ ${l.day} • ${l.subject}')))),
      if (done == 0) const Padding(padding: EdgeInsets.all(18), child: Text('🌱 এখনো কোনো পাঠ সম্পন্ন হয়নি। একটি পাঠ শেষ করলেই এখানে অগ্রগতি দেখা যাবে।')),
    ]));
  }
}
class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.emoji, required this.value, required this.label, required this.color});
  final IconData icon; final String emoji, value, label; final Color color;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: const TextStyle(fontSize: 24)), Icon(icon, size: 20), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]));
}
class ParentCornerScreen extends StatelessWidget {
  const ParentCornerScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('👨‍👩‍👧 অভিভাবক কর্নার')), body: ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF087E38), Color(0xFF48C96A)]), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.family_restroom, color: Colors.white, size: 42), SizedBox(height: 8), Text('💚 শিশুর শেখার সঙ্গী হোন', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), Text('প্রতিদিন অল্প সময় একসঙ্গে পড়ুন, প্রশংসা করুন এবং আনন্দের সঙ্গে অনুশীলন করান।', style: TextStyle(color: Colors.white, height: 1.5))])),
    const _ParentTip(icon: Icons.flag, title: '🎯 পড়ার লক্ষ্য নির্ধারণ', detail: 'প্রতিদিন ১৫–২০ মিনিটের ছোট লক্ষ্য ঠিক করুন.'),
    const _ParentTip(icon: Icons.auto_stories, title: '📖 একসঙ্গে গল্প পড়ুন', detail: 'শিশুকে নিজের ভাষায় গল্পটি বলতে উৎসাহ দিন.'),
    const _ParentTip(icon: Icons.volume_up, title: '🔊 শুনে অনুশীলন', detail: 'শব্দের উচ্চারণ শুনে শিশুকে ধীরে ধীরে বলতে দিন.'),
    const _ParentTip(icon: Icons.celebration, title: '🌟 চেষ্টা করলেই প্রশংসা', detail: 'ভুল হলে বকবেন না; আবার চেষ্টা করতে সাহায্য করুন.'),
    const _ParentTip(icon: Icons.health_and_safety, title: '🛡️ নিরাপদ ব্যবহার', detail: 'ছোটদের স্ক্রিন ব্যবহারে অভিভাবকের পাশে থাকা ভালো.'),
  ]));
}
class _ParentTip extends StatelessWidget {
  const _ParentTip({required this.icon, required this.title, required this.detail}); final IconData icon; final String title, detail;
  @override Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFE1F7E7), child: Text(sectionEmoji(title), style: const TextStyle(fontSize: 19))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(detail)));
}
class SettingsScreen extends StatefulWidget { const SettingsScreen({super.key}); @override State<SettingsScreen> createState() => _SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true, offline = true, largeText = false; String language = 'বাংলা', themeName = 'green';
  static const themeOptions = <(String, String, Color, IconData)>[
    ('green', 'প্রকৃতি সবুজ', Color(0xFF16834A), Icons.eco),
    ('blue', 'আকাশ নীল', Color(0xFF2878C8), Icons.water_drop),
    ('purple', 'রাজকীয় বেগুনি', Color(0xFF7652B5), Icons.auto_awesome),
    ('pink', 'গোলাপি', Color(0xFFC34F83), Icons.favorite),
    ('dark', 'ডার্ক মোড', Color(0xFF263746), Icons.dark_mode),
  ];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); if (!mounted) return; setState(() { sound=p.getBool('setting_sound')??true; VoiceCoach.enabled = sound; offline=p.getBool('setting_offline')??true; largeText=p.getBool('setting_large_text')??false; language=p.getString('setting_language')??'বাংলা'; themeName=p.getString('setting_theme')??AppThemeController.selected.value; }); }
  Future<void> _save(String k, Object v) async { final p=await SharedPreferences.getInstance(); if(v is bool) await p.setBool(k,v); if(v is String) await p.setString(k,v); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('⚙️ সেটিংস')), body: ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.palette_outlined), SizedBox(width: 10), Text('🎨 অ্যাপের থিম পরিবর্তন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 6),
      const Text('একটি থিম বেছে নিলে পুরো অ্যাপের রং, ব্যাকগ্রাউন্ড, কার্ড, মেনু ও বাটনের ডিজাইন বদলে যাবে।'),
      const SizedBox(height: 12),
      RadioGroup<String>(
        groupValue: themeName,
        onChanged: (value) {
          if (value == null) return;
          setState(() => themeName = value);
          AppThemeController.setTheme(value);
        },
        child: Column(
          children: themeOptions.map((option) => RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: option.$1,
            title: Text('${themeEmoji(option.$1)} ${option.$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
            secondary: CircleAvatar(backgroundColor: option.$3, child: Icon(option.$4, color: Colors.white)),
          )).toList(),
        ),
      ),
    ]))),
    Card(child: ListTile(leading: const Icon(Icons.language), title: const Text('🌐 ভাষা নির্বাচন'), trailing: DropdownButton<String>(value: language, items: const ['বাংলা','English','العربية'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v){if(v!=null){setState(()=>language=v);_save('setting_language',v);}}))),
    Card(child: SwitchListTile(secondary: const Icon(Icons.volume_up), title: const Text('🔊 সাউন্ড ও ভয়েস'), value:sound, onChanged:(v){setState(()=>sound=v);VoiceCoach.enabled=v;_save('setting_sound',v);})),
    Card(child: SwitchListTile(secondary: const Icon(Icons.wifi_off), title: const Text('📴 অফলাইন মোড'), value:offline, onChanged:(v){setState(()=>offline=v);_save('setting_offline',v);})),
    Card(child: SwitchListTile(secondary: const Icon(Icons.text_fields), title: const Text('🔠 বড় লেখা'), value:largeText, onChanged:(v){setState(()=>largeText=v);_save('setting_large_text',v);})),
    const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('ℹ️ অ্যাপ সম্পর্কে'), subtitle: Text('📚 ছোট্ট পাঠশালা • শিশুদের আনন্দময় শেখার সঙ্গী'))),
    const Card(child: ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('🔐 গোপনীয়তা'), subtitle: Text('🔒 শিশুর ব্যক্তিগত তথ্য সংগ্রহ না করাই আমাদের নীতি।'))),
  ]));
}
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('😟 $message', textAlign: TextAlign.center)));
}
