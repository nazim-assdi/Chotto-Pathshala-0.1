// ignore_for_file: deprecated_member_use

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_language.dart';
import 'privacy_policy_screen.dart';
import 'word_gallery_localization.dart';
import 'video_library.dart';

void main() => runApp(const ChottoPathshalaApp());

const String appDisplayName = 'Chotto Pathshala';

const lessonFiles = [
  'arabic-foundations.json',
  'class-one-251-300.json',
  'class-one-306-365.json',
  'class-two-366-389.json',
  'kg-151-200.json',
  'kg-205-250.json',
  'kg-246-250.json',
  'nursery-061-110.json',
  'nursery-111-150.json',
  'nursery-alphabets-151-254.json',
  'playgroup-001-010.json',
  'playgroup-011-060.json',
];
const quizFiles = [
  'class-one-001-050.json',
  'class-one-051-100.json',
  'class-one-101-150.json',
  'class-two-001-024.json',
  'kg-001-050.json',
  'kg-051-100.json',
  'kg-102-151.json',
  'nursery-001-050.json',
  'nursery-051-100.json',
  'nursery-101-150.json',
  'nursery-151-200.json',
  'nursery-201-250.json',
  'playgroup-001-020.json',
  'playgroup-021-070.json',
  'playgroup-071-110.json',
  'playgroup-111-130.json',
  'supplemental-319.json',
];

String levelLabel(String level) {
  switch (level) {
    case 'playgroup':
      return appText('প্লে-গ্রুপ', 'Playgroup', 'مرحلة ما قبل المدرسة');
    case 'nursery':
      return appText('নার্সারি', 'Nursery', 'الحضانة');
    case 'kg':
      return appText('কেজি', 'Kindergarten', 'الروضة');
    case 'class-one':
      return appText('প্রথম শ্রেণি', 'Class 1', 'الصف الأول');
    case 'class-two':
      return appText('দ্বিতীয় শ্রেণি', 'Class 2', 'الصف الثاني');
    default:
      return level;
  }
}

String subjectLabel(String subject) {
  const labels = <String, List<String>>{
    'গণিত': ['Mathematics', 'الرياضيات'],
    'জীবনদক্ষতা': ['Life Skills', 'المهارات الحياتية'],
    'ডিজিটাল দক্ষতা': ['Digital Skills', 'المهارات الرقمية'],
    'নৈতিকতা': ['Values & Ethics', 'القيم والأخلاق'],
    'বাংলাদেশ পরিচিতি': ['About Bangladesh', 'التعرّف إلى بنغلاديش'],
    'বিজ্ঞান': ['Science', 'العلوم'],
    'সামাজিক পরিচয়': ['Social Identity', 'الهوية الاجتماعية'],
    'সৃজনশীলতা': ['Creativity', 'الإبداع'],
    'আচরণ': ['Good Manners', 'الآداب الحسنة'],
    'খেলা': ['Play', 'اللعب'],
    'সাধারণ জ্ঞান': ['General Knowledge', 'المعرفة العامة'],
    'রং': ['Colors', 'الألوان'],
    'আকার': ['Shapes', 'الأشكال'],
    'শরীর পরিচিতি': ['My Body', 'جسمي'],
    'শরীর': ['The Body', 'الجسم'],
    'গণনা': ['Counting', 'العدّ'],
    'পরিবার': ['Family', 'الأسرة'],
    'পরিবার ও সামাজিকতা': ['Family and Community', 'الأسرة والمجتمع'],
    'বাংলা': ['Bangla', 'اللغة البنغالية'],
    'English': ['English', 'اللغة الإنجليزية'],
    'পরিবেশ': ['Environment', 'البيئة'],
    'নিরাপত্তা': ['Safety', 'السلامة'],
    'স্বাস্থ্য': ['Health', 'الصحة'],
    'স্বাস্থ্যবিধি': ['Healthy Habits', 'العادات الصحية'],
    'প্রকৃতি': ['Nature', 'الطبيعة'],
    'প্রাণী': ['Animals', 'الحيوانات'],
    'খাবার': ['Food', 'الطعام'],
    'আবেগ': ['Feelings', 'المشاعر'],
    'দিক': ['Everyday Things', 'الأشياء اليومية'],
    'বস্তু': ['Objects', 'الأشياء'],
    'শব্দ': ['Sounds', 'الأصوات'],
    'সময়': ['Time', 'الوقت'],
    'আরবি': ['Arabic', 'اللغة العربية'],
    'ইসলাম শিক্ষা': ['Islamic Studies', 'الدراسات الإسلامية'],
  };
  final translated = labels[subject];
  if (translated == null) return subject;
  return appText(subject, translated[0], translated[1]);
}

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

  static Future<void> speak(
    String text, {
    bool english = false,
    bool arabic = false,
  }) async {
    await _say(
      text,
      language: arabic ? 'ar-SA' : (english ? 'en-US' : 'bn-BD'),
      rate: 0.42,
      pitch: 1.0,
    );
  }

  static Future<void> speakReading(
    String text, {
    required String language,
    required double rate,
    required VoidCallback onComplete,
  }) async {
    if (!enabled || text.trim().isEmpty) {
      onComplete();
      return;
    }
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate.clamp(0.25, 0.70).toDouble());
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.setLanguage(language);
      _tts.setCompletionHandler(onComplete);
      _tts.setErrorHandler((_) => onComplete());
      await _tts.speak(text);
    } catch (_) {
      onComplete();
    }
  }

  static Future<void> stopReading() async {
    try {
      await _tts.stop();
    } catch (_) {
      // A missing device voice must never block reading on screen.
    }
  }

  static String get _feedbackLanguage {
    switch (AppLanguageController.selected.value) {
      case 'English':
        return 'en-US';
      case 'العربية':
        return 'ar-SA';
      default:
        return 'bn-BD';
    }
  }

  static Future<void> cheer() async {
    await _say(
      appText(
        'দারুণ! একদম সঠিক উত্তর! খুব ভালো করেছো!',
        'Great job! That is correct! Well done!',
        'أحسنت! إجابتك صحيحة! عمل رائع!',
      ),
      language: _feedbackLanguage,
      rate: 0.48,
      pitch: 1.18,
    );
  }

  static Future<void> encourage() async {
    await _say(
      appText(
        'কোনো সমস্যা নেই। আবার চেষ্টা করো, তুমি পারবে!',
        'That is okay. Try again—you can do it!',
        'لا بأس. حاول مرة أخرى، يمكنك النجاح!',
      ),
      language: _feedbackLanguage,
      rate: 0.44,
      pitch: 1.08,
    );
  }

  static Future<void> victory() async {
    await _say(
      appText(
        'অভিনন্দন! তুমি গেমটি শেষ করেছো! দারুণ খেলেছো!',
        'Congratulations! You finished the game! Great work!',
        'تهانينا! لقد أنهيت اللعبة! أحسنت!',
      ),
      language: _feedbackLanguage,
      rate: 0.48,
      pitch: 1.2,
    );
  }

  static Future<void> _say(
    String text, {
    String language = 'bn-BD',
    required double rate,
    required double pitch,
  }) async {
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
    required this.day,
    required this.level,
    required this.subject,
    required this.title,
    required this.objective,
    required this.story,
    required this.examples,
    required this.activity,
    required this.practice,
    required this.answers,
    required this.parentTip,
    this.translations = const {},
  });

  final int day;
  final String level,
      subject,
      title,
      objective,
      story,
      activity,
      practice,
      answers,
      parentTip;
  final List<String> examples;
  final Map<String, dynamic> translations;

  String get progressId => '$level-$day';
  String get displaySubject => _localizedText(translations, 'subject', subject);
  String get displayTitle => _localizedText(translations, 'title', title);
  String get displayObjective =>
      _localizedText(translations, 'objective', objective);
  String get displayStory => _localizedText(translations, 'story', story);
  List<String> get displayExamples =>
      _localizedList(translations, 'examples', examples);
  String get displayActivity =>
      _localizedText(translations, 'activity', activity);
  String get displayPractice =>
      _localizedText(translations, 'practice', practice);
  String get displayAnswers => _localizedText(translations, 'answers', answers);
  String get displayParentTip =>
      _localizedText(translations, 'parent_tip', parentTip);

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    day: (json['day'] as num?)?.toInt() ?? 0,
    level: _normalizeLevel(json['level']?.toString() ?? 'nursery'),
    subject: json['subject']?.toString() ?? 'অন্যান্য',
    title: json['title']?.toString() ?? 'নতুন পাঠ',
    objective: json['objective']?.toString() ?? '',
    story: json['story']?.toString() ?? '',
    examples: (json['examples'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    activity: json['activity']?.toString() ?? '',
    practice: json['practice']?.toString() ?? '',
    answers: json['answers']?.toString() ?? '',
    parentTip: json['parent_tip']?.toString() ?? '',
    translations: _asTranslations(json['translations']),
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.level,
    required this.subject,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    this.translations = const {},
  });

  final String id, level, subject, question, answer, explanation;
  final Map<String, String> options;
  final Map<String, dynamic> translations;

  String get displaySubject => _localizedText(translations, 'subject', subject);
  String get displayQuestion =>
      _localizedText(translations, 'question', question);
  String get displayExplanation =>
      _localizedText(translations, 'explanation', explanation);
  Map<String, String> get displayOptions {
    final localized = _localizedMap(translations, 'options');
    return localized.isEmpty ? options : localized;
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id']?.toString() ?? '',
    level: _normalizeLevel(json['level']?.toString() ?? 'nursery'),
    subject: json['subject']?.toString() ?? 'অন্যান্য',
    question: json['question']?.toString() ?? '',
    options: (json['options'] as Map? ?? const {}).map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    ),
    answer: json['answer']?.toString() ?? '',
    explanation: json['explanation']?.toString() ?? '',
    translations: _asTranslations(json['translations']),
  );
}

Map<String, dynamic> _asTranslations(dynamic raw) {
  if (raw is! Map) return const {};
  return raw.map((key, value) => MapEntry(key.toString(), value));
}

Map<String, dynamic> _selectedTranslation(Map<String, dynamic> translations) {
  final code = AppLanguageController.selected.value == 'English'
      ? 'en'
      : AppLanguageController.selected.value == 'العربية'
      ? 'ar'
      : 'bn';
  final value = translations[code];
  return value is Map
      ? value.map((key, item) => MapEntry(key.toString(), item))
      : const {};
}

String _localizedText(
  Map<String, dynamic> translations,
  String field,
  String fallback,
) {
  final value = _selectedTranslation(translations)[field];
  return value is String && value.isNotEmpty ? value : fallback;
}

List<String> _localizedList(
  Map<String, dynamic> translations,
  String field,
  List<String> fallback,
) {
  final value = _selectedTranslation(translations)[field];
  return value is List
      ? value.map((item) => item.toString()).toList()
      : fallback;
}

Map<String, String> _localizedMap(
  Map<String, dynamic> translations,
  String field,
) {
  final value = _selectedTranslation(translations)[field];
  return value is Map
      ? value.map((key, item) => MapEntry(key.toString(), item.toString()))
      : const {};
}

String _normalizeLevel(String value) =>
    value.trim().toLowerCase().replaceAll('_', '-');

QuizQuestion practiceQuizFromLesson(Lesson lesson) {
  final enRaw = lesson.translations['en'];
  final arRaw = lesson.translations['ar'];
  final en = enRaw is Map ? enRaw : const <String, dynamic>{};
  final ar = arRaw is Map ? arRaw : const <String, dynamic>{};

  String translated(Map fields, String key, String fallback) {
    final value = fields[key];
    return value is String && value.trim().isNotEmpty ? value : fallback;
  }

  return QuizQuestion(
    id: lesson.progressId,
    level: lesson.level,
    subject: lesson.subject,
    question: lesson.practice,
    options: {
      'A': lesson.answers,
      'B': 'আবার ভালো করে পড়ি',
      'C': 'এখনো শিখিনি',
    },
    answer: 'A',
    explanation: lesson.answers,
    translations: {
      'en': {
        'subject': translated(en, 'subject', lesson.subject),
        'question': translated(en, 'practice', lesson.practice),
        'options': {
          'A': translated(en, 'answers', lesson.answers),
          'B': 'Let’s read it again',
          'C': 'I am still learning',
        },
        'explanation': translated(en, 'answers', lesson.answers),
      },
      'ar': {
        'subject': translated(ar, 'subject', lesson.subject),
        'question': translated(ar, 'practice', lesson.practice),
        'options': {
          'A': translated(ar, 'answers', lesson.answers),
          'B': 'لنقرأها مرة أخرى',
          'C': 'ما زلت أتعلم',
        },
        'explanation': translated(ar, 'answers', lesson.answers),
      },
    },
  );
}

class LearningRepository {
  Future<List<Lesson>> loadLessons() async {
    final result = <Lesson>[];
    for (final file in lessonFiles) {
      final raw = await rootBundle.loadString(
        'app/src/main/assets/content/lessons/$file',
      );
      final data = jsonDecode(raw) as Map<String, dynamic>;
      result.addAll(
        (data['lessons'] as List).map(
          (e) => Lesson.fromJson(e as Map<String, dynamic>),
        ),
      );
    }
    result.sort((a, b) {
      const levelOrder = [
        'playgroup',
        'nursery',
        'kg',
        'class-one',
        'class-two',
      ];
      final byLevel = levelOrder
          .indexOf(a.level)
          .compareTo(levelOrder.indexOf(b.level));
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
      final raw = await rootBundle.loadString(
        'app/src/main/assets/content/quizzes/$file',
      );
      final data = jsonDecode(raw) as Map<String, dynamic>;
      result.addAll(
        (data['questions'] as List).map(
          (e) => QuizQuestion.fromJson(e as Map<String, dynamic>),
        ),
      );
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
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    final page = dark
        ? const Color(0xFF111820)
        : (name == 'blue'
              ? const Color(0xFFEAF4FF)
              : name == 'purple'
              ? const Color(0xFFF4EEFF)
              : name == 'pink'
              ? const Color(0xFFFFF0F5)
              : const Color(0xFFEAF8F0));
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
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: dark ? 1 : 3,
        shadowColor: dark ? Colors.black26 : seed.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: const EdgeInsets.only(bottom: 10),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: scheme.secondaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.secondaryContainer,
        elevation: 3,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}

class ChottoPathshalaApp extends StatefulWidget {
  const ChottoPathshalaApp({super.key});
  @override
  State<ChottoPathshalaApp> createState() => _ChottoPathshalaAppState();
}

class _ChottoPathshalaAppState extends State<ChottoPathshalaApp> {
  @override
  void initState() {
    super.initState();
    AppThemeController.load();
    AppLanguageController.load();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: AppLanguageController.selected,
    builder: (context, language, _) => ValueListenableBuilder<String>(
      valueListenable: AppThemeController.selected,
      builder: (context, themeName, _) => MaterialApp(
        title: appDisplayName,
        debugShowCheckedModeBanner: false,
        theme: AppThemeController.build(themeName),
        builder: (context, child) => Directionality(
          textDirection: language == 'العربية'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: MaterialUiCompatibilityBridge(child: child!),
        ),
        home: const LearningHomeShell(),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialLevel = 'nursery',
    this.initialTab = 0,
  });
  final String initialLevel;
  final int initialTab;
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
    selectedLevel = widget.initialLevel;
    selectedTab = widget.initialTab < 0
        ? 0
        : (widget.initialTab > 2 ? 2 : widget.initialTab);
    lessonsFuture = repository.loadLessons();
    quizzesFuture = repository.loadQuizzes();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList('completed_lesson_ids') ?? []).toSet();
    final oldDays = (prefs.getStringList('completed_days') ?? [])
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();
    if (saved.isEmpty && oldDays.isNotEmpty) {
      final lessons = await lessonsFuture;
      saved.addAll(
        lessons.where((l) => oldDays.contains(l.day)).map((l) => l.progressId),
      );
      await prefs.setStringList('completed_lesson_ids', saved.toList());
    }
    if (mounted) setState(() => completed = saved);
  }

  Future<void> _markComplete(Lesson lesson) async {
    final next = {...completed, lesson.progressId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_lesson_ids', next.toList());
    final legacy = (prefs.getStringList('completed_days') ?? []).toSet()
      ..add('${lesson.day}');
    await prefs.setStringList('completed_days', legacy.toList());
    if (mounted) setState(() => completed = next);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      title: Text(appText('📚 শেখার পাঠ', '📚 Lessons', '📚 الدروس')),
      actions: const [],
    ),
    body: FutureBuilder<List<Lesson>>(
      future: lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorView(
            message: appText(
              'পাঠ লোড করা যায়নি। আবার চেষ্টা করো।',
              'Lessons could not be loaded. Please try again.',
              'تعذّر تحميل الدروس. حاول مرة أخرى.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  appText(
                    'পাঠ লোড হচ্ছে…',
                    'Loading lessons…',
                    'جارٍ تحميل الدروس…',
                  ),
                ),
              ],
            ),
          );
        }
        final all = snapshot.data!;
        final levelLessons = all
            .where((l) => l.level == selectedLevel)
            .toList();
        final subjects =
            levelLessons
                .map((l) => l.subject)
                .where((s) => s.trim().isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final filtered = levelLessons
            .where(
              (l) =>
                  (selectedSubject == 'সব বিষয়' ||
                      l.subject == selectedSubject) &&
                  (search.isEmpty ||
                      l.displayTitle.toLowerCase().contains(
                        search.toLowerCase(),
                      ) ||
                      l.displaySubject.toLowerCase().contains(
                        search.toLowerCase(),
                      ) ||
                      l.subject.toLowerCase().contains(search.toLowerCase())),
            )
            .toList();
        final totalForLevel = levelLessons.length;
        final doneForLevel = levelLessons
            .where((l) => completed.contains(l.progressId))
            .length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A83B), Color(0xFF65D94D)],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33205B35),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appText(
                      '🌟 আজকের শেখা, আগামী দিনের শক্তি!',
                      '🌟 Learn today, grow tomorrow!',
                      '🌟 نتعلم اليوم لننمو غدًا!',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appText(
                      '📖 গল্প, 🖼️ ছবি, ✍️ অনুশীলন ও 🧠 কুইজে আনন্দ করে শেখো।',
                      '📖 Learn with stories, pictures, practice and quizzes.',
                      '📖 تعلّم بالقصص والصور والتدريب والاختبارات.',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: totalForLevel == 0
                          ? 0
                          : doneForLevel / totalForLevel,
                      minHeight: 9,
                      backgroundColor: Colors.white30,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    appText(
                      '📈 এই শ্রেণিতে $doneForLevel / $totalForLevel পাঠ সম্পন্ন',
                      '📈 $doneForLevel / $totalForLevel lessons completed',
                      '📈 أُكمل $doneForLevel / $totalForLevel درسًا',
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appText(
                '🏫 তোমার শ্রেণি বেছে নাও',
                '🏫 Choose your class',
                '🏫 اختر صفك',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.35,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: levels.entries.map((entry) {
                const colors = [
                  Color(0xFFF1D6FF),
                  Color(0xFFFFF0A8),
                  Color(0xFFD9F7D2),
                  Color(0xFFFFD8AE),
                  Color(0xFFD8ECFF),
                ];
                const icons = [
                  Icons.child_care,
                  Icons.face_3,
                  Icons.school,
                  Icons.menu_book,
                  Icons.auto_stories,
                ];
                final idx = levels.keys.toList().indexOf(entry.key);
                final chosen = selectedLevel == entry.key;
                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => setState(() {
                    selectedLevel = entry.key;
                    selectedSubject = 'সব বিষয়';
                    search = '';
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[idx],
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: chosen ? const Color(0xFF08A83C) : Colors.white,
                        width: chosen ? 3 : 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22205B35),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              levelEmoji(entry.key),
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              icons[idx],
                              size: 22,
                              color: const Color(0xFF145A32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          levelLabel(entry.key),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        if (chosen)
                          Text(
                            appText('নির্বাচিত', 'Selected', 'محدد'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF08752D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(appText('📖 পাঠ', '📖 Lessons', '📖 الدروس')),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(
                    appText(
                      '🖼️ শব্দ ও ছবি',
                      '🖼️ Words & Pictures',
                      '🖼️ الكلمات والصور',
                    ),
                  ),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text(appText('🎮 গেম', '🎮 Games', '🎮 الألعاب')),
                ),
              ],
              selected: {selectedTab},
              onSelectionChanged: (v) => setState(() => selectedTab = v.first),
            ),
            if (selectedTab == 0) ...[
              const SizedBox(height: 12),
              Text(
                appText(
                  '📚 বিষয় নির্বাচন করো — বিষয় চাপ দিলে সেই বিষয়ের পাঠ দেখাবে',
                  '📚 Choose a subject to see its lessons',
                  '📚 اختر موضوعًا لعرض دروسه',
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['সব বিষয়', ...subjects]
                    .map(
                      (subject) => ChoiceChip(
                        label: Text(
                          subject == 'সব বিষয়'
                              ? appText('সব বিষয়', 'All subjects', 'كل المواد')
                              : subjectLabel(subject),
                        ),
                        selected: selectedSubject == subject,
                        avatar: const Icon(Icons.menu_book_outlined, size: 17),
                        onSelected: (_) => setState(() {
                          selectedSubject = subject;
                          search = '';
                        }),
                        selectedColor: const Color(0xFFCFF2D8),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selectedSubject == subject
                              ? const Color(0xFF08A83C)
                              : const Color(0xFFDCE9F2),
                        ),
                        labelStyle: TextStyle(
                          fontWeight: selectedSubject == subject
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: appText(
                    '🔎 পাঠ বা বিষয় খুঁজুন',
                    '🔎 Search lessons or subjects',
                    '🔎 ابحث عن الدروس أو الموضوعات',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => search = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appText(
                        '📅 আজকের পাঠগুলো',
                        '📅 Today’s lessons',
                        '📅 دروس اليوم',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length} ${appText('টি পাঠ', 'lessons', 'درس')}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    appText(
                      '📭 এই শ্রেণিতে এখনো পাঠ পাওয়া যায়নি।',
                      '📭 No lessons are available for this class yet.',
                      '📭 لا توجد دروس متاحة لهذا الصف حتى الآن.',
                    ),
                  ),
                ),
              for (final subject
                  in (selectedSubject == 'সব বিষয়'
                      ? (filtered.map((l) => l.subject).toSet().toList()
                          ..sort())
                      : [selectedSubject])) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          subjectLabel(subject),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF246B5A),
                          ),
                        ),
                      ),
                      Text(
                        '${filtered.where((l) => l.subject == subject).length} ${appText('টি পাঠ', 'lessons', 'درس')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                ...filtered
                    .where((l) => l.subject == subject)
                    .map(
                      (lesson) => Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonScreen(
                                lesson: lesson,
                                onComplete: () => _markComplete(lesson),
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFF0F7FF)],
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F5E8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '📖',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${lesson.day}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF08752D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(
                                lesson.displayTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Text(
                                completed.contains(lesson.progressId)
                                    ? appText(
                                        '✅ পাঠ সম্পন্ন',
                                        '✅ Lesson completed',
                                        '✅ اكتمل الدرس',
                                      )
                                    : appText(
                                        '👉 পাঠটি শিখতে এখানে চাপ দাও',
                                        '👉 Tap here to learn this lesson',
                                        '👉 اضغط هنا لتعلّم هذا الدرس',
                                      ),
                              ),
                              trailing: Icon(
                                completed.contains(lesson.progressId)
                                    ? Icons.check_circle
                                    : Icons.arrow_forward_ios,
                                color: const Color(0xFF08A83C),
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ] else if (selectedTab == 1)
              const WordGallery()
            else
              FutureBuilder<List<QuizQuestion>>(
                future: quizzesFuture,
                builder: (context, qs) {
                  if (qs.hasError) {
                    return _ErrorView(
                      message: appText(
                        'কুইজ লোড করা যায়নি। আবার চেষ্টা করো।',
                        'Quizzes could not be loaded. Please try again.',
                        'تعذّر تحميل الاختبارات. حاول مرة أخرى.',
                      ),
                    );
                  }
                  if (!qs.hasData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            appText(
                              'কুইজ লোড হচ্ছে…',
                              'Loading quizzes…',
                              'جارٍ تحميل الاختبارات…',
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final bank = qs.data!
                      .where((q) => q.level == selectedLevel)
                      .toList();
                  final gameSubjects = <String>{...subjects};
                  if (selectedLevel == 'playgroup' ||
                      selectedLevel == 'nursery') {
                    gameSubjects.addAll(['বাংলা', 'English', 'আরবি']);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        appText(
                          '🎮 প্রতিটি বিষয়ের আলাদা গেম',
                          '🎮 A separate game for each subject',
                          '🎮 لعبة مستقلة لكل مادة',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: gameSubjects
                            .map(
                              (name) => Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Text('🎮'),
                                  ),
                                  title: Text(subjectLabel(name)),
                                  subtitle: Text(_gameTitle(name)),
                                  trailing: const Icon(Icons.play_arrow),
                                  onTap: () {
                                    if ((selectedLevel == 'playgroup' ||
                                            selectedLevel == 'nursery') &&
                                        _isLetterSubject(name)) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LetterGameScreen(subject: name),
                                        ),
                                      );
                                      return;
                                    }
                                    var qsForSubject = bank
                                        .where((q) => q.subject == name)
                                        .toList();
                                    if (qsForSubject.isEmpty) {
                                      qsForSubject = levelLessons
                                          .where(
                                            (l) =>
                                                l.subject == name &&
                                                l.practice.isNotEmpty &&
                                                l.answers.isNotEmpty,
                                          )
                                          .take(10)
                                          .map(practiceQuizFromLesson)
                                          .toList();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SubjectGameScreen(
                                          subject: name,
                                          questions: qsForSubject,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    ),
  );
}

String _gameTitle(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('বাংলা')) {
    return appText(
      'অক্ষর চেনা ও শব্দ মেলানো',
      'Recognize letters and match words',
      'تعرّف إلى الحروف وطابق الكلمات',
    );
  }
  if (s.contains('english') || s.contains('ইংরেজি')) {
    return appText(
      'ইংরেজি বর্ণ ও শব্দ',
      'Alphabet, Phonics & Spelling',
      'الحروف الإنجليزية والأصوات والتهجئة',
    );
  }
  if (s.contains('আরবি') || s.contains('arabic')) {
    return appText(
      'আরবি হরফ ও শব্দ',
      'Arabic Letters and Words',
      'الحروف والكلمات العربية',
    );
  }
  if (s.contains('গণিত') || s.contains('math')) {
    return appText(
      'সংখ্যা, গণনা ও হিসাব',
      'Numbers, Counting & Maths',
      'الأرقام والعدّ والحساب',
    );
  }
  if (s.contains('বিজ্ঞান') || s.contains('পরিবেশ')) {
    return appText(
      'প্রকৃতি ও বিজ্ঞান আবিষ্কার',
      'Discover Nature and Science',
      'اكتشف الطبيعة والعلوم',
    );
  }
  if (s.contains('নিরাপত্তা') || s.contains('জীবন')) {
    return appText(
      'ভালো অভ্যাস ও নিরাপত্তা',
      'Good Habits and Safety',
      'العادات الجيدة والسلامة',
    );
  }
  return appText(
    'বিষয়ভিত্তিক জ্ঞান খেলা',
    'Subject Learning Game',
    'لعبة تعلم حسب المادة',
  );
}

bool _isLetterSubject(String subject) {
  final s = subject.toLowerCase();
  return s.contains('বাংলা') ||
      s.contains('english') ||
      s.contains('ইংরেজি') ||
      s.contains('আরবি') ||
      s.contains('arabic');
}

String levelEmoji(String level) {
  switch (_normalizeLevel(level)) {
    case 'playgroup':
      return '🧸';
    case 'nursery':
      return '🧩';
    case 'kg':
      return '🎒';
    case 'class-one':
      return '✏️';
    case 'class-two':
      return '📚';
    default:
      return '🏫';
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
    case 'green':
      return '🍃';
    case 'blue':
      return '💧';
    case 'purple':
      return '✨';
    case 'pink':
      return '💗';
    case 'dark':
      return '🌙';
    default:
      return '🎨';
  }
}

class WordGallery extends StatefulWidget {
  const WordGallery({super.key});
  @override
  State<WordGallery> createState() => _WordGalleryState();
}

class _WordGalleryState extends State<WordGallery> {
  String category = 'বাংলা';
  double cardZoom = 1.0;
  double _pinchStartZoom = 1.0;
  double _pinchStartDistance = 0;
  final Map<int, Offset> _zoomPointers = {};

  void _setCardZoom(double value) {
    setState(() => cardZoom = value.clamp(0.75, 2.0).toDouble());
  }

  void _resetPinchBaseline() {
    if (_zoomPointers.length < 2) {
      _pinchStartDistance = 0;
      return;
    }
    final points = _zoomPointers.values.take(2).toList();
    _pinchStartDistance = (points[0] - points[1]).distance;
    _pinchStartZoom = cardZoom;
  }

  void _onZoomPointerDown(PointerDownEvent event) {
    _zoomPointers[event.pointer] = event.position;
    if (_zoomPointers.length >= 2) _resetPinchBaseline();
  }

  void _onZoomPointerMove(PointerMoveEvent event) {
    if (!_zoomPointers.containsKey(event.pointer)) return;
    _zoomPointers[event.pointer] = event.position;
    if (_zoomPointers.length < 2 || _pinchStartDistance <= 0) return;

    final points = _zoomPointers.values.take(2).toList();
    final distance = (points[0] - points[1]).distance;
    final next = (_pinchStartZoom * distance / _pinchStartDistance)
        .clamp(0.75, 2.0)
        .toDouble();
    if ((next - cardZoom).abs() > 0.015 && mounted) {
      setState(() => cardZoom = next);
    }
  }

  void _onZoomPointerEnd(PointerEvent event) {
    _zoomPointers.remove(event.pointer);
    _resetPinchBaseline();
  }

  // Listener observes finger movement without entering the gesture arena,
  // so each card's InkWell tap remains available for pronunciation.
  Widget _zoomGesture({required Widget child}) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _onZoomPointerDown,
    onPointerMove: _onZoomPointerMove,
    onPointerUp: _onZoomPointerEnd,
    onPointerCancel: _onZoomPointerEnd,
    child: child,
  );

  // প্রতিটি সারি: বর্ণ/সংখ্যা, শব্দ, বাংলা অর্থ, চিত্র, ঐচ্ছিক SVG asset।
  static const bangla = <List<String>>[
    ['অ', 'অজগর', 'বড় সাপ', '🐍'],
    ['আ', 'আম', 'মিষ্টি ফল', '🥭', 'assets/images/words/mango.svg'],
    ['ই', 'ইলিশ', 'একটি মাছ', '🐟'],
    ['ঈ', 'ঈগল', 'শিকারি পাখি', '🦅'],
    ['উ', 'উট', 'মরুর প্রাণী', '🐪'],
    ['ঊ', 'ঊষা', 'ভোরের আলো', '🌅'],
    ['ঋ', 'ঋতু', 'বছরের সময়', '🌦️'],
    ['এ', 'একতারা', 'বাদ্যযন্ত্র', '🎸'],
    ['ঐ', 'ঐরাবত', 'পুরাণের হাতি', '🐘'],
    ['ও', 'ওল', 'সবজি', '🍠'],
    ['ঔ', 'ঔষধ', 'ওষুধ', '💊'],
    ['ক', 'কলা', 'হলুদ ফল', '🍌', 'assets/images/words/banana.svg'],
    ['খ', 'খরগোশ', 'লম্বা কানওয়ালা প্রাণী', '🐇'],
    ['গ', 'গরু', 'গৃহপালিত প্রাণী', '🐄', 'assets/images/words/cow.svg'],
    ['ঘ', 'ঘড়ি', 'সময় দেখায়', '⏰'],
    ['ঙ', 'ব্যাঙ', 'জল ও ডাঙায় থাকে', '🐸'],
    ['চ', 'চাঁদ', 'রাতের আকাশে', '🌙'],
    ['ছ', 'ছাতা', 'বৃষ্টি থেকে বাঁচায়', '☂️'],
    ['জ', 'জাহাজ', 'পানিতে চলে', '🚢'],
    ['ঝ', 'ঝিনুক', 'সমুদ্রে পাওয়া যায়', '🐚'],
    ['ঞ', 'মিঞা', 'ঞ-যুক্ত শব্দ', '👨'],
    ['ট', 'টমেটো', 'লাল সবজি', '🍅'],
    ['ঠ', 'ঠেলাগাড়ি', 'জিনিস বহন করে', '🛒'],
    ['ড', 'ডাব', 'কচি নারকেল', '🥥'],
    ['ঢ', 'ঢোল', 'বাদ্যযন্ত্র', '🥁'],
    ['ণ', 'গণনা', 'সংখ্যা গোনা', '🔢'],
    ['ত', 'তরমুজ', 'রসালো ফল', '🍉'],
    ['থ', 'থালা', 'খাবারের পাত্র', '🍽️'],
    ['দ', 'দোয়েল', 'জাতীয় পাখি', '🐦'],
    ['ধ', 'ধান', 'শস্য', '🌾'],
    ['ন', 'নৌকা', 'নদীতে চলে', '🛶'],
    ['প', 'পাখি', 'আকাশে উড়ে', '🐦'],
    ['ফ', 'ফুল', 'সুন্দর ও সুগন্ধি', '🌺', 'assets/images/words/flower.svg'],
    ['ব', 'বই', 'পড়ার জিনিস', '📚'],
    ['ভ', 'ভালুক', 'বনের প্রাণী', '🐻'],
    ['ম', 'মাছ', 'পানিতে থাকে', '🐟'],
    ['য', 'যব', 'এক ধরনের শস্য', '🌾'],
    ['র', 'রংধনু', 'আকাশে দেখা যায়', '🌤️'],
    ['ল', 'লেবু', 'টক ফল', '🍋'],
    ['শ', 'শাপলা', 'জলজ ফুল', '🪷'],
    ['ষ', 'ষাঁড়', 'গরুর পুরুষ', '🐂'],
    ['স', 'সূর্য', 'দিনের আলো দেয়', '☀️', 'assets/images/words/sun.svg'],
    ['হ', 'হাতি', 'বড় স্থলচর প্রাণী', '🐘'],
    ['ড়', 'গাড়ি', 'চাকার যান', '🚗'],
    ['ঢ়', 'আষাঢ়', 'বাংলা মাস', '🌧️'],
    ['য়', 'সময়', 'ঘড়িতে দেখা যায়', '⌚'],
    ['ৎ', 'হঠাৎ', 'অপ্রত্যাশিতভাবে', '💡'],
    ['ং', 'বাংলা', 'আমাদের ভাষা', '🔤'],
    ['ঃ', 'দুঃখ', 'মনের অনুভূতি', '😢'],
    ['ঁ', 'চাঁদ', 'আকাশে ওঠে', '🌙'],
  ];

  static const english = <List<String>>[
    ['A', 'Apple', 'আপেল', '🍎', 'assets/images/words/apple.svg'],
    ['B', 'Ball', 'বল', '⚽'],
    ['C', 'Cat', 'বিড়াল', '🐱', 'assets/images/words/cat.svg'],
    ['D', 'Dog', 'কুকুর', '🐶', 'assets/images/words/dog.svg'],
    ['E', 'Elephant', 'হাতি', '🐘'],
    ['F', 'Fish', 'মাছ', '🐟'],
    ['G', 'Grapes', 'আঙুর', '🍇'],
    ['H', 'House', 'বাড়ি', '🏠'],
    ['I', 'Ice cream', 'আইসক্রিম', '🍦'],
    ['J', 'Jug', 'জগ', '🫗'],
    ['K', 'Kite', 'ঘুড়ি', '🪁'],
    ['L', 'Lion', 'সিংহ', '🦁'],
    ['M', 'Mango', 'আম', '🥭', 'assets/images/words/mango.svg'],
    ['N', 'Nest', 'পাখির বাসা', '🪺'],
    ['O', 'Orange', 'কমলা', '🍊'],
    ['P', 'Parrot', 'টিয়া পাখি', '🦜'],
    ['Q', 'Queen', 'রানি', '👑'],
    ['R', 'Rabbit', 'খরগোশ', '🐇'],
    ['S', 'Sun', 'সূর্য', '☀️', 'assets/images/words/sun.svg'],
    ['T', 'Tree', 'গাছ', '🌳', 'assets/images/words/tree.svg'],
    ['U', 'Umbrella', 'ছাতা', '☂️'],
    ['V', 'Van', 'ভ্যানগাড়ি', '🚐'],
    ['W', 'Watch', 'ঘড়ি', '⌚'],
    ['X', 'Xylophone', 'জাইলোফোন', '🎼'],
    ['Y', 'Yo-yo', 'খেলনা', '🪀'],
    ['Z', 'Zebra', 'জেব্রা', '🦓'],
  ];

  static const arabic = <List<String>>[
    ['ا', 'أَسَد', 'সিংহ', '🦁'],
    ['ب', 'بَطَّة', 'হাঁস', '🦆'],
    ['ت', 'تُفَّاح', 'আপেল', '🍎', 'assets/images/words/apple.svg'],
    ['ث', 'ثَعْلَب', 'শিয়াল', '🦊'],
    ['ج', 'جَمَل', 'উট', '🐪'],
    ['ح', 'حِصَان', 'ঘোড়া', '🐎'],
    ['خ', 'خَرُوف', 'ভেড়া', '🐑'],
    ['د', 'دُبّ', 'ভালুক', '🐻'],
    ['ذ', 'ذُرَّة', 'ভুট্টা', '🌽'],
    ['ر', 'رُمَّان', 'ডালিম', '🍎'],
    ['ز', 'زَهْرَة', 'ফুল', '🌺', 'assets/images/words/flower.svg'],
    ['س', 'سَمَك', 'মাছ', '🐟'],
    ['ش', 'شَمْس', 'সূর্য', '☀️', 'assets/images/words/sun.svg'],
    ['ص', 'صَقْر', 'বাজপাখি', '🦅'],
    ['ض', 'ضِفْدَع', 'ব্যাঙ', '🐸'],
    ['ط', 'طَائِرَة', 'বিমান', '✈️'],
    ['ظ', 'ظَبْي', 'হরিণ', '🦌'],
    ['ع', 'عَيْن', 'চোখ', '👁️'],
    ['غ', 'غَزَال', 'হরিণ', '🦌'],
    ['ف', 'فِيل', 'হাতি', '🐘'],
    ['ق', 'قَمَر', 'চাঁদ', '🌙'],
    ['ك', 'كِتَاب', 'বই', '📚'],
    ['ل', 'لَيْمُون', 'লেবু', '🍋'],
    ['م', 'مَوْز', 'কলা', '🍌', 'assets/images/words/banana.svg'],
    ['ن', 'نَمِر', 'বাঘ', '🐅'],
    ['ه', 'هِلال', 'অর্ধচন্দ্র', '🌙'],
    ['و', 'وَرْدَة', 'গোলাপ', '🌹'],
    ['ي', 'يَد', 'হাত', '✋'],
  ];

  @override
  Widget build(BuildContext context) {
    final isMath = category == 'গণিত';
    final data = category == 'বাংলা'
        ? bangla
        : category == 'English'
        ? english
        : arabic;
    final mathColumns = cardZoom >= 1.25 ? 1 : 2;
    final wordColumns = cardZoom >= 1.7
        ? 1
        : cardZoom >= 1.2
        ? 2
        : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Text(
            appText(
              '🔤 বর্ণ, 💬 শব্দ, 🖼️ ছবি ও 🔊 উচ্চারণ শিখি',
              '🔤 Learn letters, words, pictures and pronunciation',
              '🔤 تعلّم الحروف والكلمات بالصور والنطق',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF145A32),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                const ButtonSegment(
                  value: 'বাংলা',
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('🇧🇩'), SizedBox(width: 4), Text('বাংলা')],
                  ),
                ),
                const ButtonSegment(
                  value: 'English',
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('🔠'), SizedBox(width: 4), Text('English')],
                  ),
                ),
                const ButtonSegment(
                  value: 'আরবি',
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('🕌'), SizedBox(width: 4), Text('العربية')],
                  ),
                ),
                ButtonSegment(
                  value: 'গণিত',
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔢'),
                      const SizedBox(width: 4),
                      Text(
                        appText('গণিত ১–১০', 'Numbers 1–10', 'الأرقام ١–١٠'),
                      ),
                    ],
                  ),
                ),
              ],
              selected: {category},
              onSelectionChanged: (v) => setState(() => category = v.first),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  appText(
                    '🤏 দুই আঙুলে কার্ড বড় বা ছোট করো',
                    '🤏 Pinch with two fingers to resize the cards',
                    '🤏 كبّر البطاقات أو صغّرها بإصبعين',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: appText(
                  'কার্ড ছোট করো',
                  'Make cards smaller',
                  'تصغير البطاقات',
                ),
                visualDensity: VisualDensity.compact,
                onPressed: cardZoom <= 0.75
                    ? null
                    : () => _setCardZoom(cardZoom - 0.25),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${localizeGalleryDigits((cardZoom * 100).round())}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              IconButton(
                tooltip: appText(
                  'কার্ড বড় করো',
                  'Make cards larger',
                  'تكبير البطاقات',
                ),
                visualDensity: VisualDensity.compact,
                onPressed: cardZoom >= 2.0
                    ? null
                    : () => _setCardZoom(cardZoom + 0.25),
                icon: const Icon(Icons.add_circle_outline),
              ),
              IconButton(
                tooltip: appText(
                  'স্বাভাবিক আকার',
                  'Reset card size',
                  'إعادة الحجم الأصلي',
                ),
                visualDensity: VisualDensity.compact,
                onPressed: cardZoom == 1.0 ? null : () => _setCardZoom(1.0),
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
        ),
        if (isMath)
          _zoomGesture(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mathColumns,
                mainAxisExtent: 226 * cardZoom,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                final n = index + 1;
                final numberName = localizeGalleryNumberName(n);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => VoiceCoach.speak(
                      numberName,
                      english:
                          AppLanguageController.selected.value == 'English',
                      arabic: AppLanguageController.isArabic,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * cardZoom,
                        vertical: 10 * cardZoom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _NumberDots(count: n, scale: cardZoom),
                          SizedBox(height: 5 * cardZoom),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${numberEmoji(n)} × ${localizeGalleryDigits(n)}',
                                style: TextStyle(
                                  fontSize: 15 * cardZoom,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5 * cardZoom),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${localizeGalleryDigits(n)}  $numberName',
                                style: TextStyle(
                                  fontSize: 21 * cardZoom,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF087E38),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2 * cardZoom),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                numberName,
                                style: TextStyle(
                                  fontSize: 16 * cardZoom,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 3 * cardZoom),
                          Text(
                            appText(
                              '🧮 ${localizeGalleryDigits(n)}টি বস্তু গুনে দেখো',
                              '🧮 Count ${localizeGalleryDigits(n)} objects',
                              '🧮 عُدَّ ${localizeGalleryDigits(n)} أشياء',
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11 * cardZoom,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 2 * cardZoom),
                          Icon(
                            Icons.volume_up,
                            size: 18 * cardZoom,
                            color: const Color(0xFF087E38),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          _zoomGesture(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 18),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wordColumns,
                childAspectRatio: 0.76,
                crossAxisSpacing: 9,
                mainAxisSpacing: 10,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final w = data[index];
                final image = w.length > 4 ? w[4] : null;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => VoiceCoach.speak(
                      category == 'আরবি'
                          ? '${w[0]}، ${w[1]}، ${localizeWordGalleryMeaning(w[2])}'
                          : '${w[0]}. ${w[1]}. ${localizeWordGalleryMeaning(w[2])}',
                      english: category == 'English',
                      arabic: category == 'আরবি',
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFFFF), Color(0xFFEAF5FF)],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: image == null
                                  ? Text(
                                      w[3],
                                      style: TextStyle(fontSize: 42 * cardZoom),
                                    )
                                  : SvgPicture.asset(
                                      image,
                                      width: 68 * cardZoom,
                                      height: 68 * cardZoom,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (_) => Text(
                                        w[3],
                                        style: TextStyle(
                                          fontSize: 42 * cardZoom,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Text(
                            w[0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24 * cardZoom,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF087E38),
                            ),
                          ),
                          Text(
                            w[1],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * cardZoom,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            localizeWordGalleryMeaning(w[2]),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10 * cardZoom),
                          ),
                          Icon(
                            Icons.volume_up,
                            size: 17 * cardZoom,
                            color: const Color(0xFF087E38),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _NumberDots extends StatelessWidget {
  const _NumberDots({required this.count, this.scale = 1.0});
  final int count;
  final double scale;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112 * scale,
    height: 74 * scale,
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5 * scale,
      runSpacing: 5 * scale,
      children: List.generate(
        count,
        (i) => Container(
          width: (count > 8 ? 16 : 20) * scale,
          height: (count > 8 ? 16 : 20) * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: [
              const Color(0xFFFFC928),
              const Color(0xFF21B85A),
              const Color(0xFF3998E8),
              const Color(0xFFFF6B6B),
            ][i % 4],
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LetterGameScreen extends StatefulWidget {
  const LetterGameScreen({super.key, required this.subject});
  final String subject;
  @override
  State<LetterGameScreen> createState() => _LetterGameScreenState();
}

class _LetterGameScreenState extends State<LetterGameScreen> {
  int index = 0, score = 0;
  String? selected;
  bool answered = false;
  late final List<String> letters = widget.subject.contains('বাংলা')
      ? 'অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ ক খ গ ঘ ঙ চ ছ জ ঝ ঞ ট ঠ ড ঢ ণ ত থ দ ধ ন প ফ ব ভ ম য র ল শ ষ স হ ড় ঢ় য়'
            .split(' ')
      : (widget.subject.contains('আরবি') ||
                widget.subject.toLowerCase().contains('arabic')
            ? 'ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ط ظ ع غ ف ق ك ل م ن ه و ي'.split(
                ' ',
              )
            : 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'.split(' '));
  late final List<List<String>> _questionOptions = List.generate(
    letters.length,
    (i) {
      final pool = letters.where((x) => x != letters[i]).toList();
      final start = (i * 3) % pool.length;
      final choices = [
        letters[i],
        pool[start],
        pool[(start + 1) % pool.length],
        pool[(start + 2) % pool.length],
      ];
      // Stable ordering: choices must not change when Flutter rebuilds the screen.
      return List.generate(
        choices.length,
        (j) => choices[(j + i) % choices.length],
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    final choices = _questionOptions[index];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText(
            '🎮 ${widget.subject} বর্ণের গেম',
            '🎮 ${subjectLabel(widget.subject)} Letter Game',
            '🎮 لعبة حروف ${subjectLabel(widget.subject)}',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            appText(
              '🔎 বর্ণটি চিনে সঠিকটি বেছে নাও',
              '🔎 Recognize the letter and choose it',
              '🔎 تعرّف إلى الحرف واختره',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: (index + 1) / letters.length),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                '✨ ${letters[index]} ✨',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (widget.subject.contains('আরবি'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                appText(
                  '🕌 হরকত অনুশীলন: بَ  بِ  بُ  (যবর, যের, পেশ)',
                  '🕌 Harakat practice: بَ  بِ  بُ (Fatha, Kasra, Damma)',
                  '🕌 تدريب الحركات: بَ  بِ  بُ (الفتحة والكسرة والضمة)',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          const SizedBox(height: 18),
          ...choices.map(
            (choice) => Card(
              child: ListTile(
                leading: const Text('🔤'),
                title: Text(
                  choice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: answered
                    ? null
                    : () {
                        setState(() {
                          selected = choice;
                          answered = true;
                          if (choice == letters[index]) score++;
                        });
                        VoiceCoach.speak(
                          choice,
                          english: widget.subject.toLowerCase().contains(
                            'english',
                          ),
                          arabic: widget.subject.contains('আরবি'),
                        );
                        if (choice == letters[index]) {
                          VoiceCoach.cheer();
                        } else {
                          VoiceCoach.encourage();
                        }
                      },
              ),
            ),
          ),
          if (answered)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                selected == letters[index]
                    ? appText(
                        '🌟 দারুণ! সঠিক বর্ণ।',
                        '🌟 Great! That is the correct letter.',
                        '🌟 رائع! هذا هو الحرف الصحيح.',
                      )
                    : appText(
                        '💛 আবার চেষ্টা করো। সঠিক বর্ণ: ${letters[index]}',
                        '💛 Try again. The correct letter is: ${letters[index]}',
                        '💛 حاول مرة أخرى. الحرف الصحيح هو: ${letters[index]}',
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton(
            onPressed: answered
                ? () {
                    if (index == letters.length - 1) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => CelebrationDialog(
                          score: score,
                          total: letters.length,
                        ),
                      );
                    } else {
                      setState(() {
                        index++;
                        selected = null;
                        answered = false;
                      });
                    }
                  }
                : null,
            child: Text(
              appText('➡️ পরের বর্ণ', '➡️ Next letter', '➡️ الحرف التالي'),
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectGameScreen extends StatefulWidget {
  const SubjectGameScreen({
    super.key,
    required this.subject,
    required this.questions,
  });
  final String subject;
  final List<QuizQuestion> questions;
  @override
  State<SubjectGameScreen> createState() => _SubjectGameScreenState();
}

class _SubjectGameScreenState extends State<SubjectGameScreen> {
  int index = 0, score = 0;
  String? selected;
  bool answered = false;
  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            appText(
              '🎮 ${widget.subject}',
              '🎮 ${subjectLabel(widget.subject)}',
              '🎮 ${subjectLabel(widget.subject)}',
            ),
          ),
        ),
        body: Center(
          child: Text(
            appText(
              '📭 এই বিষয়ের গেমের প্রশ্ন এখনো যোগ করা হয়নি।',
              '📭 No game questions have been added for this subject yet.',
              '📭 لم تُضف أسئلة لهذه المادة بعد.',
            ),
          ),
        ),
      );
    }
    final q = widget.questions[index];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText(
            '🎮 ${widget.subject} গেম',
            '🎮 ${subjectLabel(widget.subject)} Game',
            '🎮 لعبة ${subjectLabel(widget.subject)}',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    appText(
                      '🎮 ${_gameTitle(widget.subject)}',
                      '🎮 ${_gameTitle(widget.subject)}',
                      '🎮 ${_gameTitle(widget.subject)}',
                    ),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appText(
                      '⭐ স্কোর: $score',
                      '⭐ Score: $score',
                      '⭐ النتيجة: $score',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: (index + 1) / widget.questions.length),
          const SizedBox(height: 20),
          Text(
            '❓ ${q.displayQuestion}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...q.displayOptions.entries.map((e) {
            final correct = e.key == q.answer;
            final chosen = e.key == selected;
            return Card(
              color: answered && correct
                  ? Colors.green.shade100
                  : answered && chosen
                  ? Colors.red.shade100
                  : null,
              child: ListTile(
                leading: const Text('🔘'),
                title: Text(e.value, style: const TextStyle(fontSize: 19)),
                trailing: answered && correct
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: answered
                    ? null
                    : () {
                        setState(() {
                          selected = e.key;
                          answered = true;
                          if (correct) score++;
                        });
                        if (correct) {
                          VoiceCoach.cheer();
                        } else {
                          VoiceCoach.encourage();
                        }
                      },
              ),
            );
          }),
          if (answered)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '${selected == q.answer ? appText('🌟 দারুণ! সঠিক উত্তর।', '🌟 Great! Correct answer.', '🌟 رائع! إجابة صحيحة.') : appText('💛 চেষ্টা ভালো হয়েছে!', '💛 Good try!', '💛 محاولة جيدة!')} ${q.displayExplanation}',
                ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: answered
                ? () {
                    if (index + 1 >= widget.questions.length) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => CelebrationDialog(
                          score: score,
                          total: widget.questions.length,
                        ),
                      );
                    } else {
                      setState(() {
                        index++;
                        selected = null;
                        answered = false;
                      });
                    }
                  }
                : null,
            child: Text(
              index + 1 >= widget.questions.length
                  ? appText(
                      '🏆 ফলাফল দেখো',
                      '🏆 View results',
                      '🏆 عرض النتائج',
                    )
                  : appText('➡️ পরের ধাপ', '➡️ Next step', '➡️ الخطوة التالية'),
            ),
          ),
        ],
      ),
    );
  }
}

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({
    super.key,
    required this.score,
    required this.total,
  });
  final int score, total;
  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  @override
  void initState() {
    super.initState();
    SystemSound.play(SystemSoundType.alert);
    VoiceCoach.victory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perfect = widget.score == widget.total;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 155,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _CelebrationPainter(
                    _controller.value,
                    Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale:
                          0.65 +
                          (0.45 *
                              Curves.elasticOut.transform(_controller.value)),
                      child: const Text('🏆', style: TextStyle(fontSize: 76)),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              perfect
                  ? appText(
                      'অসাধারণ! তুমি বিজয়ী! 🎉',
                      'Amazing! You did it! 🎉',
                      'مذهل! لقد نجحت! 🎉',
                    )
                  : appText(
                      'দারুণ চেষ্টা! 🎊',
                      'Great effort! 🎊',
                      'محاولة رائعة! 🎊',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appText('তোমার স্কোর', 'Your score', 'نتيجتك'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.score} / ${widget.total}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              perfect
                  ? appText(
                      'সবগুলো উত্তর সঠিক! বাহ, বাহ!',
                      'All answers are correct! Well done!',
                      'كل الإجابات صحيحة! أحسنت!',
                    )
                  : appText(
                      'আরও অনুশীলন করলে আরও ভালো করবে।',
                      'More practice will help you do even better.',
                      'سيساعدك المزيد من التدريب على التحسن.',
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.celebration),
                label: Text(appText('চালিয়ে যাও', 'Continue', 'متابعة')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  _CelebrationPainter(this.progress, this.seedColor);
  final double progress;
  final Color seedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      seedColor,
      Colors.amber,
      Colors.pink,
      Colors.lightBlue,
      Colors.green,
      Colors.deepOrange,
    ];
    for (var i = 0; i < 34; i++) {
      final angle = (i * 2.399) + (progress * 1.8);
      final distance = (18 + (i % 7) * 10) * progress;
      final x = size.width / 2 + math.cos(angle) * distance;
      final y = 72 + math.sin(angle) * distance - (progress * (i % 5) * 8);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: 1 - progress * 0.35,
        );
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

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seedColor != seedColor;
}

class LessonScreen extends StatelessWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.onComplete,
  });
  final Lesson lesson;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        appText(
          '📖 পাঠ ${lesson.day}',
          '📖 Lesson ${lesson.day}',
          '📖 الدرس ${lesson.day}',
        ),
      ),
      actions: [
        IconButton(
          tooltip: appText('পড়ার মোড', 'Reading mode', 'وضع القراءة'),
          icon: const Icon(Icons.chrome_reader_mode_rounded),
          onPressed: () {
            final language = AppLanguageController.selected.value;
            final voiceLanguage = language == 'English'
                ? 'en-US'
                : language == 'العربية'
                    ? 'ar-SA'
                    : 'bn-BD';
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LessonReaderScreen(
                  title: lesson.displayTitle,
                  subtitle: '${levelLabel(lesson.level)} • ${lesson.displaySubject}',
                  voiceLanguage: voiceLanguage,
                  sections: [
                    ReaderSection(
                      title: appText('আজকের লক্ষ্য', 'Today’s goal', 'هدف اليوم'),
                      text: lesson.displayObjective,
                    ),
                    ReaderSection(
                      title: appText('গল্পে শিখি', 'Learn through a story', 'نتعلم من القصة'),
                      text: lesson.displayStory,
                    ),
                    ReaderSection(
                      title: appText('উদাহরণ', 'Examples', 'أمثلة'),
                      text: lesson.displayExamples.join('\n'),
                    ),
                    ReaderSection(
                      title: appText('চলো কাজ করি', 'Let’s do an activity', 'هيا نمارس النشاط'),
                      text: lesson.displayActivity,
                    ),
                    ReaderSection(
                      title: appText('নিজে চেষ্টা করো', 'Try it yourself', 'جرّب بنفسك'),
                      text: lesson.displayPractice,
                    ),
                    ReaderSection(
                      title: appText('উত্তর', 'Answer', 'الإجابة'),
                      text: lesson.displayAnswers,
                    ),
                    ReaderSection(
                      title: appText('অভিভাবকের জন্য', 'For parents', 'للأهل'),
                      text: lesson.displayParentTip,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          lesson.displayTitle,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Chip(
          avatar: Text(levelEmoji(lesson.level)),
          label: Text('${levelLabel(lesson.level)} • ${lesson.displaySubject}'),
        ),
        _LessonSection(
          title: appText('আজকের লক্ষ্য', 'Today’s goal', 'هدف اليوم'),
          body: lesson.displayObjective,
          icon: Icons.flag_outlined,
        ),
        _LessonSection(
          title: appText(
            'গল্পে শিখি',
            'Learn through a story',
            'نتعلم من القصة',
          ),
          body: lesson.displayStory,
          icon: Icons.auto_stories_outlined,
        ),
        _LessonSection(
          title: appText('উদাহরণ', 'Examples', 'أمثلة'),
          body: lesson.displayExamples.join('\n'),
          icon: Icons.lightbulb_outline,
        ),
        _LessonSection(
          title: appText(
            'চলো কাজ করি',
            'Let’s do an activity',
            'هيا نمارس النشاط',
          ),
          body: lesson.displayActivity,
          icon: Icons.brush_outlined,
        ),
        _LessonSection(
          title: appText('নিজে চেষ্টা করো', 'Try it yourself', 'جرّب بنفسك'),
          body: lesson.displayPractice,
          icon: Icons.edit_note,
        ),
        _LessonSection(
          title: appText('উত্তর', 'Answer', 'الإجابة'),
          body: lesson.displayAnswers,
          icon: Icons.check_circle_outline,
        ),
        _LessonSection(
          title: appText('অভিভাবকের জন্য', 'For parents', 'للأهل'),
          body: lesson.displayParentTip,
          icon: Icons.family_restroom,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            onComplete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appText(
                    '✅ পাঠটি সম্পন্ন হিসেবে সংরক্ষণ হয়েছে।',
                    '✅ Lesson saved as completed.',
                    '✅ تم حفظ الدرس كمكتمل.',
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.done),
          label: Text(
            appText('✅ পাঠ সম্পন্ন', '✅ Complete lesson', '✅ إكمال الدرس'),
          ),
        ),
      ],
    ),
  );
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title, body;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sectionEmoji(title), style: const TextStyle(fontSize: 21)),
              const SizedBox(width: 7),
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 10),
            SelectableText(
              body,
              style: const TextStyle(height: 1.55, fontSize: 15),
            ),
          ],
        ],
      ),
    ),
  );
}

class ReaderSection {
  const ReaderSection({required this.title, required this.text});

  final String title;
  final String text;
}

/// A focused, distraction-light reader for every bundled lesson section.
/// Speech uses the device's installed Bangla, English or Arabic TTS voice.
class LessonReaderScreen extends StatefulWidget {
  const LessonReaderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.voiceLanguage,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final String voiceLanguage;
  final List<ReaderSection> sections;

  @override
  State<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends State<LessonReaderScreen> {
  double _fontSize = 19;
  double _speechRate = 0.42;
  bool _reading = false;
  int _activeSection = -1;
  int _playToken = 0;
  Completer<void>? _activeCompletion;

  List<ReaderSection> get _readableSections => widget.sections
      .where((section) => section.text.trim().isNotEmpty)
      .toList(growable: false);

  Future<void> _readAll() async {
    await _readSections(List<int>.generate(_readableSections.length, (i) => i));
  }

  Future<void> _readOne(int index) async {
    await _readSections([index]);
  }

  Future<void> _readSections(List<int> indexes) async {
    if (indexes.isEmpty) return;
    final token = ++_playToken;
    await VoiceCoach.stopReading();
    if (!mounted) return;
    setState(() {
      _reading = true;
      _activeSection = indexes.first;
    });

    final sections = _readableSections;
    for (final index in indexes) {
      if (!mounted || token != _playToken || index >= sections.length) break;
      final section = sections[index];
      setState(() => _activeSection = index);
      final completion = Completer<void>();
      _activeCompletion = completion;
      await VoiceCoach.speakReading(
        '${section.title}. ${section.text}',
        language: widget.voiceLanguage,
        rate: _speechRate,
        onComplete: () {
          if (!completion.isCompleted) completion.complete();
        },
      );
      if (!completion.isCompleted) {
        await completion.future.timeout(
          const Duration(minutes: 3),
          onTimeout: () {},
        );
      }
      if (token != _playToken) break;
    }

    if (mounted && token == _playToken) {
      setState(() {
        _reading = false;
        _activeSection = -1;
      });
    }
  }

  Future<void> _stopReading() async {
    ++_playToken;
    final completion = _activeCompletion;
    if (completion != null && !completion.isCompleted) completion.complete();
    await VoiceCoach.stopReading();
    if (!mounted) return;
    setState(() {
      _reading = false;
      _activeSection = -1;
    });
  }

  @override
  void dispose() {
    ++_playToken;
    if (_reading) {
      VoiceCoach.stopReading();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _readableSections;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(appText('পড়ার মোড', 'Reading mode', 'وضع القراءة')),
        actions: [
          IconButton(
            tooltip: appText('পড়া বন্ধ করো', 'Stop reading', 'إيقاف القراءة'),
            onPressed: _reading ? _stopReading : null,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _reading ? null : _readAll,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: Text(appText('সব পড়ে শোনাও', 'Read all aloud', 'اقرأ الكل')),
                        ),
                        OutlinedButton.icon(
                          onPressed: _reading ? _stopReading : null,
                          icon: const Icon(Icons.stop_rounded),
                          label: Text(appText('বন্ধ', 'Stop', 'إيقاف')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(appText('লেখার আকার', 'Text size', 'حجم النص')),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: appText('ছোট করো', 'Smaller text', 'تصغير النص'),
                          onPressed: _fontSize <= 16
                              ? null
                              : () => setState(() => _fontSize = (_fontSize - 1).clamp(16, 30).toDouble()),
                          icon: const Icon(Icons.text_decrease_rounded),
                        ),
                        Text('${_fontSize.round()}'),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: appText('বড় করো', 'Larger text', 'تكبير النص'),
                          onPressed: _fontSize >= 30
                              ? null
                              : () => setState(() => _fontSize = (_fontSize + 1).clamp(16, 30).toDouble()),
                          icon: const Icon(Icons.text_increase_rounded),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(appText('পড়ার গতি', 'Reading speed', 'سرعة القراءة')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _speechRate,
                            min: 0.25,
                            max: 0.68,
                            divisions: 9,
                            label: '${(_speechRate * 100).round()}%',
                            onChanged: (value) => setState(() => _speechRate = value),
                          ),
                        ),
                        Text('${(_speechRate * 100).round()}%'),
                      ],
                    ),
                    if (_reading)
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appText('এখন পড়ে শোনানো হচ্ছে', 'Reading aloud now', 'تتم القراءة بصوت عالٍ الآن'),
                              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: sections.isEmpty
                ? Center(
                    child: Text(appText('এই পাঠে পড়ার মতো লেখা নেই।', 'This lesson has no reading text.', 'لا يوجد نص للقراءة في هذا الدرس.')),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final active = _activeSection == index;
                      return Card(
                        color: active ? scheme.secondaryContainer : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    tooltip: appText('এই অংশ পড়ে শোনাও', 'Read this section aloud', 'اقرأ هذا الجزء بصوت عالٍ'),
                                    onPressed: () => _readOne(index),
                                    icon: const Icon(Icons.volume_up_rounded),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                section.text,
                                textAlign: AppLanguageController.isArabic ? TextAlign.right : TextAlign.start,
                                style: TextStyle(fontSize: _fontSize, height: 1.8),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
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
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(appText('🧠 কুইজ', '🧠 Quiz', '🧠 اختبار'))),
        body: Center(
          child: Text(
            appText(
              '📭 এই শ্রেণির জন্য কুইজ পাওয়া যায়নি।',
              '📭 No quiz is available for this class.',
              '📭 لا يتوفر اختبار لهذا الصف.',
            ),
          ),
        ),
      );
    }
    final q = widget.questions[index % widget.questions.length];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText(
            '🧠 কুইজ • ${index + 1}/${widget.questions.length}',
            '🧠 Quiz • ${index + 1}/${widget.questions.length}',
            '🧠 اختبار • ${index + 1}/${widget.questions.length}',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(value: (index + 1) / widget.questions.length),
          const SizedBox(height: 24),
          Text(
            q.displaySubject,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '❓ ${q.displayQuestion}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...q.displayOptions.entries.map((entry) {
            final isCorrect = entry.key == q.answer;
            final isSelected = entry.key == selected;
            final color = answered && isCorrect
                ? Colors.green.shade100
                : answered && isSelected
                ? Colors.red.shade100
                : Colors.white;
            return Card(
              color: color,
              child: ListTile(
                leading: const Text('🔘', style: TextStyle(fontSize: 21)),
                title: Text('${entry.key}. ${entry.value}'),
                trailing: answered && isCorrect
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: answered
                    ? null
                    : () => setState(() {
                        selected = entry.key;
                        answered = true;
                        if (selected == q.answer) score++;
                      }),
              ),
            );
          }),
          if (answered)
            Card(
              color: const Color(0xFFEAF4ED),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('💡 ${q.displayExplanation}'),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: answered
                ? () {
                    if (index + 1 >= widget.questions.length) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => CelebrationDialog(
                          score: score,
                          total: widget.questions.length,
                        ),
                      );
                    } else {
                      setState(() {
                        index++;
                        selected = null;
                        answered = false;
                      });
                    }
                  }
                : null,
            child: Text(
              index + 1 >= widget.questions.length
                  ? appText(
                      '🏆 ফলাফল দেখো',
                      '🏆 View results',
                      '🏆 عرض النتائج',
                    )
                  : appText(
                      '➡️ পরের প্রশ্ন',
                      '➡️ Next question',
                      '➡️ السؤال التالي',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.lessons,
    required this.completed,
  });
  final List<Lesson> lessons;
  final Set<String> completed;
  @override
  Widget build(BuildContext context) {
    final done = lessons.where((l) => completed.contains(l.progressId)).length;
    final pct = lessons.isEmpty ? 0.0 : done / lessons.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(appText('🏆 আমার অগ্রগতি', '🏆 My progress', '🏆 تقدمي')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF08A83C), Color(0xFF79D94F)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                Text(
                  appText(
                    '🌟 তুমি দারুণ এগিয়ে যাচ্ছো!',
                    '🌟 You are making great progress!',
                    '🌟 أنت تحرز تقدمًا رائعًا!',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  appText(
                    '$done / ${lessons.length} পাঠ সম্পন্ন',
                    '$done / ${lessons.length} lessons completed',
                    '$done / ${lessons.length} درسًا مكتملًا',
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 13,
                    backgroundColor: Colors.white54,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  appText(
                    '${(pct * 100).round()}% শেষ',
                    '${(pct * 100).round()}% complete',
                    '${(pct * 100).round()}% مكتمل',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            children: [
              _StatTile(
                icon: Icons.check_circle,
                emoji: '✅',
                value: '$done',
                label: appText('সম্পন্ন পাঠ', 'Completed', 'مكتمل'),
                color: const Color(0xFFDDF8E4),
              ),
              _StatTile(
                icon: Icons.menu_book,
                emoji: '📖',
                value: '${lessons.length - done}',
                label: appText(
                  'বাকি পাঠ',
                  'Remaining lessons',
                  'الدروس المتبقية',
                ),
                color: const Color(0xFFFFF1C7),
              ),
              _StatTile(
                icon: Icons.star,
                emoji: '⭐',
                value: '${done * 5}',
                label: appText(
                  'অর্জিত স্টার',
                  'Stars earned',
                  'النجوم المكتسبة',
                ),
                color: const Color(0xFFFFE2E8),
              ),
              _StatTile(
                icon: Icons.local_fire_department,
                emoji: '🔥',
                value: done > 0
                    ? appText('চালু', 'In progress', 'قيد التقدم')
                    : appText('শুরু করো', 'Not started', 'لم يبدأ'),
                label: appText(
                  'শেখার যাত্রা',
                  'Learning journey',
                  'رحلة التعلم',
                ),
                color: const Color(0xFFDCEEFF),
              ),
            ],
          ),
          Text(
            appText(
              '📚 সম্পন্ন পাঠের তালিকা',
              '📚 Completed lessons',
              '📚 الدروس المكتملة',
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          ...lessons
              .where((l) => completed.contains(l.progressId))
              .map(
                (l) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(l.displayTitle),
                    subtitle: Text(
                      appText(
                        '📖 পাঠ ${l.day} • ${l.displaySubject}',
                        '📖 Lesson ${l.day} • ${l.displaySubject}',
                        '📖 الدرس ${l.day} • ${l.displaySubject}',
                      ),
                    ),
                  ),
                ),
              ),
          if (done == 0)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                appText(
                  '🌱 এখনো কোনো পাঠ সম্পন্ন হয়নি। একটি পাঠ শেষ করলেই এখানে অগ্রগতি দেখা যাবে।',
                  '🌱 No lessons completed yet. Finish a lesson to see your progress here.',
                  '🌱 لم تُكمل أي درس بعد. أكمل درسًا لترى تقدمك هنا.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String emoji, value, label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        Icon(icon, size: 20),
        Text(
          value,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class ParentCornerScreen extends StatelessWidget {
  const ParentCornerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        appText(
          '👨‍👩‍👧 অভিভাবক কর্নার',
          '👨‍👩‍👧 Parent Corner',
          '👨‍👩‍👧 ركن الوالدين',
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF087E38), Color(0xFF48C96A)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.family_restroom, color: Colors.white, size: 42),
              const SizedBox(height: 8),
              Text(
                appText(
                  '💚 শিশুর শেখার সঙ্গী হোন',
                  '💚 Be your child’s learning partner',
                  '💚 كن شريكًا لطفلك في التعلّم',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                appText(
                  'প্রতিদিন অল্প সময় একসঙ্গে পড়ুন, প্রশংসা করুন এবং আনন্দের সঙ্গে অনুশীলন করান।',
                  'Read together for a little while each day, praise effort, and make practice joyful.',
                  'اقرؤوا معًا قليلًا كل يوم، وامدحوا المحاولة، واجعلوا التدريب ممتعًا.',
                ),
                style: const TextStyle(color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
        _ParentTip(
          icon: Icons.flag,
          title: appText(
            '🎯 পড়ার লক্ষ্য নির্ধারণ',
            '🎯 Set a learning goal',
            '🎯 حدّد هدفًا للتعلّم',
          ),
          detail: appText(
            'প্রতিদিন ১৫–২০ মিনিটের ছোট লক্ষ্য ঠিক করুন.',
            'Choose a small 15–20 minute goal each day.',
            'اختر هدفًا قصيرًا من ١٥ إلى ٢٠ دقيقة كل يوم.',
          ),
        ),
        _ParentTip(
          icon: Icons.auto_stories,
          title: appText(
            '📖 একসঙ্গে গল্প পড়ুন',
            '📖 Read a story together',
            '📖 اقرأوا قصة معًا',
          ),
          detail: appText(
            'শিশুকে নিজের ভাষায় গল্পটি বলতে উৎসাহ দিন.',
            'Encourage your child to retell the story in their own words.',
            'شجّع طفلك على إعادة سرد القصة بكلماته.',
          ),
        ),
        _ParentTip(
          icon: Icons.volume_up,
          title: appText(
            '🔊 শুনে অনুশীলন',
            '🔊 Listen and practise',
            '🔊 استمع وتدرّب',
          ),
          detail: appText(
            'শব্দের উচ্চারণ শুনে শিশুকে ধীরে ধীরে বলতে দিন.',
            'Play the pronunciation and let your child repeat it slowly.',
            'شغّل النطق ودع طفلك يكرّر الكلمة ببطء.',
          ),
        ),
        _ParentTip(
          icon: Icons.celebration,
          title: appText(
            '🌟 চেষ্টা করলেই প্রশংসা',
            '🌟 Praise every effort',
            '🌟 امدح كل محاولة',
          ),
          detail: appText(
            'ভুল হলে বকবেন না; আবার চেষ্টা করতে সাহায্য করুন.',
            'Do not scold mistakes; help your child try again.',
            'لا تَلُمْ طفلك عند الخطأ؛ ساعده على المحاولة مرة أخرى.',
          ),
        ),
        _ParentTip(
          icon: Icons.health_and_safety,
          title: appText(
            '🛡️ নিরাপদ ব্যবহার',
            '🛡️ Use the app safely',
            '🛡️ استخدم التطبيق بأمان',
          ),
          detail: appText(
            'ছোটদের স্ক্রিন ব্যবহারে অভিভাবকের পাশে থাকা ভালো.',
            'Stay with young children while they use a screen.',
            'ابقَ بجانب الأطفال الصغار أثناء استخدامهم للشاشة.',
          ),
        ),
      ],
    ),
  );
}

class _ParentTip extends StatelessWidget {
  const _ParentTip({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title, detail;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE1F7E7),
        child: Text(sectionEmoji(title), style: const TextStyle(fontSize: 19)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(detail),
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true, offline = true, largeText = false;
  String language = 'বাংলা', themeName = 'green';
  static List<(String, String, Color, IconData)> get themeOptions => [
    (
      'green',
      appText('প্রকৃতি সবুজ', 'Nature green', 'أخضر الطبيعة'),
      const Color(0xFF16834A),
      Icons.eco,
    ),
    (
      'blue',
      appText('আকাশ নীল', 'Sky blue', 'أزرق السماء'),
      const Color(0xFF2878C8),
      Icons.water_drop,
    ),
    (
      'purple',
      appText('রাজকীয় বেগুনি', 'Royal purple', 'أرجواني ملكي'),
      const Color(0xFF7652B5),
      Icons.auto_awesome,
    ),
    (
      'pink',
      appText('গোলাপি', 'Pink', 'وردي'),
      const Color(0xFFC34F83),
      Icons.favorite,
    ),
    (
      'dark',
      appText('ডার্ক মোড', 'Dark mode', 'الوضع الداكن'),
      const Color(0xFF263746),
      Icons.dark_mode,
    ),
  ];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      sound = p.getBool('setting_sound') ?? true;
      VoiceCoach.enabled = sound;
      offline = p.getBool('setting_offline') ?? true;
      largeText = p.getBool('setting_large_text') ?? false;
      language =
          p.getString('setting_language') ??
          AppLanguageController.selected.value;
      themeName =
          p.getString('setting_theme') ?? AppThemeController.selected.value;
    });
  }

  Future<void> _save(String k, Object v) async {
    final p = await SharedPreferences.getInstance();
    if (v is bool) await p.setBool(k, v);
    if (v is String) await p.setString(k, v);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(appText('⚙️ সেটিংস', '⚙️ Settings', '⚙️ الإعدادات')),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined),
                    const SizedBox(width: 10),
                    Text(
                      appText(
                        '🎨 অ্যাপের থিম পরিবর্তন',
                        '🎨 Change app theme',
                        '🎨 تغيير سمة التطبيق',
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  appText(
                    'একটি থিম বেছে নিলে পুরো অ্যাপের রং, ব্যাকগ্রাউন্ড, কার্ড, মেনু ও বাটনের ডিজাইন বদলে যাবে।',
                    'Choose a theme to change the app colors, background, cards, menus and buttons.',
                    'اختر سمة لتغيير ألوان التطبيق والخلفية والبطاقات والقوائم والأزرار.',
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: themeName,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => themeName = value);
                    AppThemeController.setTheme(value);
                  },
                  child: Column(
                    children: themeOptions
                        .map(
                          (option) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: option.$1,
                            title: Text(
                              '${themeEmoji(option.$1)} ${option.$2}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: option.$3,
                              child: Icon(option.$4, color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              appText(
                '🌐 ভাষা নির্বাচন',
                '🌐 Choose language',
                '🌐 اختر اللغة',
              ),
            ),
            trailing: DropdownButton<String>(
              value: language,
              items: const [
                'বাংলা',
                'English',
                'العربية',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) async {
                if (v != null) {
                  setState(() => language = v);
                  await AppLanguageController.setLanguage(v);
                }
              },
            ),
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: Text(
              appText(
                '🔊 সাউন্ড ও ভয়েস',
                '🔊 Sound & voice',
                '🔊 الصوت والتعليق',
              ),
            ),
            value: sound,
            onChanged: (v) {
              setState(() => sound = v);
              VoiceCoach.enabled = v;
              _save('setting_sound', v);
            },
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.wifi_off),
            title: Text(
              appText('📴 অফলাইন মোড', '📴 Offline mode', '📴 وضع عدم الاتصال'),
            ),
            value: offline,
            onChanged: (v) {
              setState(() => offline = v);
              _save('setting_offline', v);
            },
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.text_fields),
            title: Text(appText('🔠 বড় লেখা', '🔠 Larger text', '🔠 نص أكبر')),
            value: largeText,
            onChanged: (v) {
              setState(() => largeText = v);
              _save('setting_large_text', v);
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              appText('ℹ️ অ্যাপ সম্পর্কে', 'ℹ️ About app', 'ℹ️ حول التطبيق'),
            ),
            subtitle: Text(
              appText(
                '📚 Chotto Pathshala • শিশুদের আনন্দময় শেখার সঙ্গী',
                '📚 Chotto Pathshala • joyful learning for children',
                '📚 Chotto Pathshala • تعلّم ممتع للأطفال',
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(appText('🔐 গোপনীয়তা', '🔐 Privacy', '🔐 الخصوصية')),
            subtitle: Text(
              appText(
                'অ্যাপ কীভাবে তথ্য সংরক্ষণ করে তা পড়ুন।',
                'Read how the app stores information.',
                'اقرأ كيف يخزن التطبيق المعلومات.',
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PrivacyPolicyScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Column(
            children: [
              Text(
                'Developer: N Tech',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('😟 $message', textAlign: TextAlign.center),
    ),
  );
}

/// Primary information architecture: Home → Lessons → Videos → Games → More.
class LearningHomeShell extends StatefulWidget {
  const LearningHomeShell({super.key});

  @override
  State<LearningHomeShell> createState() => _LearningHomeShellState();
}

class _LearningHomeShellState extends State<LearningHomeShell> {
  int _selectedIndex = 0;
  String _selectedLevel = 'nursery';

  void _openTab(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  void _selectLevel(String level) {
    setState(() {
      _selectedLevel = level;
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _LearningDashboard(onOpenTab: _openTab, onSelectLevel: _selectLevel),
      HomeScreen(
        key: ValueKey('lessons-' + _selectedLevel),
        initialLevel: _selectedLevel,
        initialTab: 0,
      ),
      const VideoLibraryScreen(),
      HomeScreen(
        key: ValueKey('games-' + _selectedLevel),
        initialLevel: _selectedLevel,
        initialTab: 2,
      ),
      _MoreHubScreen(level: _selectedLevel),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _openTab,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: appText('হোম', 'Home', 'الرئيسية'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: appText('পাঠ', 'Lessons', 'الدروس'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.ondemand_video_outlined),
            selectedIcon: const Icon(Icons.ondemand_video_rounded),
            label: appText('ভিডিও', 'Videos', 'الفيديو'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.extension_outlined),
            selectedIcon: const Icon(Icons.extension_rounded),
            label: appText('খেলো', 'Games', 'الألعاب'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: appText('আরও', 'More', 'المزيد'),
          ),
        ],
      ),
    );
  }
}

class _DashboardSummary {
  const _DashboardSummary({
    required this.totalLessons,
    required this.completedLessons,
    required this.videoCandidates,
    required this.pendingVideos,
    required this.approvedVideos,
  });

  final int totalLessons;
  final int completedLessons;
  final int videoCandidates;
  final int pendingVideos;
  final int approvedVideos;
}

class _LearningDashboard extends StatefulWidget {
  const _LearningDashboard({
    required this.onOpenTab,
    required this.onSelectLevel,
  });

  final ValueChanged<int> onOpenTab;
  final ValueChanged<String> onSelectLevel;

  @override
  State<_LearningDashboard> createState() => _LearningDashboardState();
}

class _LearningDashboardState extends State<_LearningDashboard> {
  late final Future<_DashboardSummary> _summary = _loadSummary();

  Future<_DashboardSummary> _loadSummary() async {
    final lessons = await LearningRepository().loadLessons();
    final videos = await VideoLibraryRepository().load();
    final prefs = await SharedPreferences.getInstance();
    final completedIds =
        (prefs.getStringList('completed_lesson_ids') ?? <String>[]).toSet();
    final completedCount = lessons
        .where((lesson) => completedIds.contains(lesson.progressId))
        .length;
    return _DashboardSummary(
      totalLessons: lessons.length,
      completedLessons: completedCount,
      videoCandidates: videos.length,
      pendingVideos: videos.where((video) => video.isPendingReview).length,
      approvedVideos: videos.where((video) => video.isApproved).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(appDisplayName),
        actions: [
          IconButton(
            tooltip: appText('সেটিংস', 'Settings', 'الإعدادات'),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardSummary>(
        future: _summary,
        builder: (context, snapshot) {
          final summary =
              snapshot.data ??
              const _DashboardSummary(totalLessons: 0, completedLessons: 0, videoCandidates: 0, pendingVideos: 0, approvedVideos: 0);
          final progress = summary.totalLessons == 0
              ? 0.0
              : summary.completedLessons / summary.totalLessons;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 11),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 2,
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 104,
                        color: Colors.white.withValues(alpha: 0.13),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                appText(
                                  'ছোট্ট পদক্ষেপ, বড় স্বপ্ন',
                                  'LITTLE STEPS, BIG DREAMS',
                                  'خطوات صغيرة، أحلام كبيرة',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 17),
                        Text(
                          appText(
                            'শিখি • খেলি • স্বপ্ন গড়ি',
                            'Learn • Play • Dream big',
                            'نتعلّم • نلعب • نحلم',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          appText(
                            'প্রতিদিনের ছোট্ট শেখা হোক আনন্দের নতুন অভিযান।',
                            'Turn every little lesson into a joyful new adventure.',
                            'لنجعل كل درس صغير مغامرة جديدة مليئة بالمرح.',
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.55,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => widget.onOpenTab(1),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Text(
                              appText(
                                'পাঠ শুরু করো',
                                'Explore lessons',
                                'ابدأ الدروس',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DashboardMetric(
                      icon: Icons.menu_book_rounded,
                      value: summary.totalLessons.toString(),
                      label: appText('শেখার পাঠ', 'Lessons', 'الدروس'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DashboardMetric(
                      icon: Icons.check_circle_rounded,
                      value: summary.completedLessons.toString(),
                      label: appText('সম্পন্ন পাঠ', 'Completed', 'مكتمل'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DashboardMetric(
                      icon: Icons.ondemand_video_rounded,
                      value: summary.videoCandidates.toString(),
                      label: appText(
                        'ভিডিও রেকর্ড',
                        'Video candidates',
                        'سجلات الفيديو',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(
                    appText(
                      '${summary.pendingVideos}টি ভিডিও যাচাইয়ের অপেক্ষায়',
                      '${summary.pendingVideos} videos pending review',
                      '${summary.pendingVideos} فيديو بانتظار المراجعة',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    appText(
                      '${summary.approvedVideos}টি রিভিউ-সম্পন্ন রেকর্ড • নিরাপত্তা যাচাই ও প্রয়োজনীয় Google সেটআপ ছাড়া শিশুদের player চালু হবে না।',
                      '${summary.approvedVideos} reviewed records • Child playback remains locked until all safety checks and required Google setup are complete.',
                      '${summary.approvedVideos} سجل تمت مراجعته • يظل تشغيل الأطفال مقفلاً حتى اكتمال فحوصات السلامة وإعداد Google المطلوب.',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights_rounded, color: scheme.primary),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              appText(
                                'তোমার শেখার অগ্রগতি',
                                'Your learning progress',
                                'تقدّمك في التعلّم',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            (progress * 100).round().toString() + '%',
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        summary.completedLessons.toString() +
                            ' / ' +
                            summary.totalLessons.toString() +
                            appText(
                              'টি পাঠ সম্পন্ন',
                              ' lessons completed',
                              ' دروس مكتملة',
                            ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appText(
                  'তোমার শ্রেণি বেছে নাও',
                  'Choose your class',
                  'اختر صفك',
                ),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.15,
                children: levels.entries.map((entry) {
                  final index = levels.keys.toList().indexOf(entry.key);
                  final icons = <IconData>[
                    Icons.child_care_rounded,
                    Icons.face_3_rounded,
                    Icons.school_rounded,
                    Icons.menu_book_rounded,
                    Icons.auto_stories_rounded,
                  ];
                  return Material(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => widget.onSelectLevel(entry.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              foregroundColor: scheme.onPrimaryContainer,
                              child: Icon(icons[index]),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                levelLabel(entry.key),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right, color: scheme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                appText(
                  'এক জায়গায় শেখার সব আয়োজন',
                  'Everything you need to learn in one place',
                  'كل ما تحتاج إليه للتعلّم في مكان واحد',
                ),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _DashboardShortcut(
                    icon: Icons.menu_book_rounded,
                    title: appText(
                      'পাঠ ও ছবি',
                      'Lessons & Pictures',
                      'الدروس والصور',
                    ),
                    detail: appText(
                      'বর্ণ, শব্দ, গল্প ও অনুশীলন',
                      'Letters, words, stories and practice',
                      'الحروف والكلمات والقصص والتدريب',
                    ),
                    onTap: () => widget.onOpenTab(1),
                  ),
                  _DashboardShortcut(
                    icon: Icons.ondemand_video_rounded,
                    title: appText(
                      'ভিডিও লাইব্রেরি',
                      'Video library',
                      'مكتبة الفيديو',
                    ),
                    detail: appText(
                      'English, Arabic ও শেখার কার্টুন',
                      'English, Arabic and learning cartoons',
                      'الإنجليزية والعربية ورسوم تعليمية',
                    ),
                    onTap: () => widget.onOpenTab(2),
                  ),
                  _DashboardShortcut(
                    icon: Icons.extension_rounded,
                    title: appText(
                      'গেম ও খেলাধুলা',
                      'Games & Play',
                      'الألعاب والمرح',
                    ),
                    detail: appText(
                      'মজার প্রশ্ন ও বর্ণের গেম',
                      'Fun quizzes and letter games',
                      'اختبارات ممتعة وألعاب الحروف',
                    ),
                    onTap: () => widget.onOpenTab(3),
                  ),
                  _DashboardShortcut(
                    icon: Icons.grid_view_rounded,
                    title: appText(
                      'আরও সুবিধা',
                      'More features',
                      'المزيد من الميزات',
                    ),
                    detail: appText(
                      'কুইজ, অগ্রগতি ও সেটিংস',
                      'Quizzes, progress and settings',
                      'الاختبارات والتقدم والإعدادات',
                    ),
                    onTap: () => widget.onOpenTab(4),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                    child: const Icon(Icons.favorite_rounded),
                  ),
                  title: Text(
                    appText(
                      'আনন্দের সঙ্গে শিখো',
                      'Learn with joy',
                      'تعلّم بفرح',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    appText(
                      'ছোট ছোট বিরতি নাও, নতুন কিছু শেখো, আর প্রতিদিনের চেষ্টা উদযাপন করো।',
                      'Take short breaks, learn something new, and celebrate your effort each day.',
                      'خذ فترات راحة قصيرة، وتعلّم شيئًا جديدًا، واحتفل بمحاولاتك كل يوم.',
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

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: scheme.onPrimaryContainer,
                size: 21,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardShortcut extends StatelessWidget {
  const _DashboardShortcut({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreHubScreen extends StatefulWidget {
  const _MoreHubScreen({required this.level});

  final String level;

  @override
  State<_MoreHubScreen> createState() => _MoreHubScreenState();
}

class _MoreHubScreenState extends State<_MoreHubScreen> {
  Future<void> _openQuiz() async {
    final allQuestions = await LearningRepository().loadQuizzes();
    if (!mounted) return;
    final questions = allQuestions
        .where((question) => question.level == widget.level)
        .toList();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => QuizScreen(questions: questions)));
  }

  Future<void> _openProgress() async {
    final lessons = await LearningRepository().loadLessons();
    final prefs = await SharedPreferences.getInstance();
    final completed =
        (prefs.getStringList('completed_lesson_ids') ?? <String>[]).toSet();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgressScreen(
          lessons: lessons
              .where((lesson) => lesson.level == widget.level)
              .toList(),
          completed: completed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(appText('আরও সুবিধা', 'More', 'المزيد'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 40,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    appText(
                      'শেখা, অনুশীলন ও অগ্রগতি',
                      'Learning, practice and progress',
                      'التعلّم والتدريب والتقدّم',
                    ),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: Text(
                appText(
                  'কুইজ ও প্রশ্নোত্তর',
                  'Quiz & Questions',
                  'اختبار وأسئلة',
                ),
              ),
              subtitle: Text(
                appText(
                  'নিজের শেখা যাচাই করো',
                  'Check what you learned',
                  'تحقق مما تعلمته',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openQuiz,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(appText('আমার অগ্রগতি', 'My progress', 'تقدمي')),
              subtitle: Text(
                appText(
                  'কতগুলো পাঠ শেষ হয়েছে দেখো',
                  'See completed lessons',
                  'شاهد الدروس المكتملة',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openProgress,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(
                appText(
                  'থিম ও সেটিংস',
                  'Theme & Settings',
                  'المظهر والإعدادات',
                ),
              ),
              subtitle: Text(
                appText(
                  'রং, ভাষা, ভয়েস ও অন্যান্য পছন্দ',
                  'Colors, language, voice and preferences',
                  'الألوان واللغة والصوت والتفضيلات',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(
                appText('অভিভাবক কর্নার', 'Parent corner', 'ركن الوالدين'),
              ),
              subtitle: Text(
                appText(
                  'শিশুর শেখায় পাশে থাকার পরামর্শ',
                  'Tips to support your child',
                  'نصائح لدعم تعلم طفلك',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ParentCornerScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              appText(
                'Chotto Pathshala • শেখা হোক আনন্দের গল্প',
                'Chotto Pathshala • Let learning be a joyful story',
                'Chotto Pathshala • لنجعل التعلّم حكاية ممتعة',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
