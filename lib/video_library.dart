import 'dart:convert';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_language.dart';
import 'video_player_screen.dart';

/// The catalogue supports up to 2,000 individually reviewed video records.
/// This is capacity only, not a claim that all records are approved or playable.
const int videoLibraryTargetCount = 2000;
const int videoLibraryPageSize = 20;
/// Enable only after the owner completes Google's child-directed API Client
/// notification and privacy setup. The default remains locked for every build.
const bool videoLibraryAvailableForChildren = bool.fromEnvironment(
  'YOUTUBE_CHILD_DIRECTED_CLIENT_CONFIRMED',
  defaultValue: false,
);

class VideoCatalogItem {
  const VideoCatalogItem({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.subject,
    required this.language,
    required this.reviewStatus,
    required this.ageBand,
    required this.madeForKidsStatus,
    required this.rightsCheck,
    required this.embeddingStatus,
  });

  final String videoId;
  final String title;
  final String channel;
  final String subject;
  final String language;
  final String reviewStatus;
  final String ageBand;
  final String madeForKidsStatus;
  final String rightsCheck;
  final String embeddingStatus;

  bool get isApproved =>
      reviewStatus == 'APPROVED' &&
      ageBand.isNotEmpty &&
      madeForKidsStatus == 'CONFIRMED_MADE_FOR_KIDS' &&
      rightsCheck == 'CONFIRMED' &&
      embeddingStatus == 'CONFIRMED_EMBEDDABLE';

  bool get canPlayForChildren =>
      videoLibraryAvailableForChildren && isApproved;

  bool get isPendingReview => reviewStatus == 'PENDING_REVIEW';

  factory VideoCatalogItem.fromJson(Map<String, dynamic> json) =>
      VideoCatalogItem(
        videoId: (json['video_id'] ?? '').toString(),
        title: (json['title'] ?? '').toString().trim(),
        channel: (json['channel'] ?? '').toString().trim(),
        subject: (json['subject'] ?? '').toString().trim(),
        language: (json['language'] ?? '').toString().trim(),
        reviewStatus: (json['review_status'] ?? 'PENDING_REVIEW').toString().trim(),
        ageBand: (json['age_band'] ?? '').toString().trim(),
        madeForKidsStatus:
            (json['made_for_kids_status'] ?? 'NOT_CHECKED').toString().trim(),
        rightsCheck: (json['rights_check'] ?? '').toString().trim(),
        embeddingStatus:
            (json['embedding_status'] ?? 'NOT_CHECKED').toString().trim(),
      );
}

class VideoLibraryRepository {
  static const String _assetPath = 'assets/videos/video_catalog.json';

  Future<List<VideoCatalogItem>> load() async =>
      parse(await rootBundle.loadString(_assetPath));

  List<VideoCatalogItem> parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Video catalogue root must be an object.');
    }
    final rawItems = decoded['items'];
    if (rawItems is! List) {
      throw const FormatException('Video catalogue items must be a list.');
    }

    final seen = <String>{};
    final items = <VideoCatalogItem>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) continue;
      final item = VideoCatalogItem.fromJson(
        rawItem.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (!_validVideoId(item.videoId) ||
          item.title.trim().isEmpty ||
          item.channel.trim().isEmpty ||
          !seen.add(item.videoId)) {
        continue;
      }
      items.add(item);
      if (items.length >= videoLibraryTargetCount) break;
    }
    return List<VideoCatalogItem>.unmodifiable(items);
  }

  bool _validVideoId(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value);
}

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({
    super.key,
    this.repository,
  });

  final VideoLibraryRepository? repository;

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  static const String _savedKey = 'video_library_saved_ids';

  final TextEditingController _searchController = TextEditingController();
  late final VideoLibraryRepository _repository;
  late Future<List<VideoCatalogItem>> _catalogFuture;
  Set<String> _savedIds = <String>{};
  String _selectedSubject = 'সব';
  String _selectedLanguage = 'সব';
  String _selectedReviewStatus = 'all';
  bool _savedOnly = false;
  bool _parentMode = false;
  int _visibleLimit = videoLibraryPageSize;


  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? VideoLibraryRepository();
    _catalogFuture = _repository.load();
    _loadSavedIds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedIds = (prefs.getStringList(_savedKey) ?? <String>[]).toSet();
    });
  }

  Future<void> _toggleSaved(VideoCatalogItem item) async {
    final next = Set<String>.from(_savedIds);
    if (next.contains(item.videoId)) {
      next.remove(item.videoId);
    } else {
      next.add(item.videoId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedKey, next.toList()..sort());
    if (!mounted) return;
    setState(() {
      _savedIds = next;
      _visibleLimit = videoLibraryPageSize;
    });
  }

  List<VideoCatalogItem> _filter(List<VideoCatalogItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((item) {
      final matchesCategory =
          _selectedSubject == 'সব' || item.subject == _selectedSubject;
      final matchesSaved = !_savedOnly || _savedIds.contains(item.videoId);
      final matchesLanguage =
          _selectedLanguage == 'সব' || item.language == _selectedLanguage;
      final matchesReviewStatus = switch (_selectedReviewStatus) {
        'pending' => item.isPendingReview,
        'approved' => item.isApproved,
        'rejected' => item.reviewStatus == 'REJECTED',
        _ => true,
      };
      final searchText = <String>[
        item.title,
        item.channel,
        item.videoId,
        item.reviewStatus,
        item.subject,
        item.language,
      ].join(' ').toLowerCase();
      return matchesCategory &&
          matchesSaved &&
          matchesLanguage &&
          matchesReviewStatus &&
          (query.isEmpty || searchText.contains(query));
    }).toList(growable: false);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedSubject = 'সব';
      _selectedLanguage = 'সব';
      _selectedReviewStatus = 'all';
      _savedOnly = false;
      _visibleLimit = videoLibraryPageSize;
    });
  }

  String _emptyStateMessage() {
    if (_selectedReviewStatus == 'approved') {
      return appText(
        'এখনো কোনো ভিডিও অনুমোদিত হয়নি। প্রতিটি ভিডিওর নিরাপত্তা ও ব্যবহারের অধিকার যাচাইয়ের পর এখানে দেখা যাবে।',
        'No approved videos yet. Videos will appear here only after individual safety and usage-rights review.',
        'لا توجد فيديوهات معتمدة بعد. ستظهر الفيديوهات هنا بعد مراجعة السلامة وحقوق الاستخدام لكل فيديو.',
      );
    }
    if (_selectedReviewStatus == 'pending') {
      return appText(
        'যাচাইয়ের অপেক্ষায় কোনো ভিডিও নেই।',
        'There are no videos waiting for review.',
        'لا توجد فيديوهات بانتظار المراجعة.',
      );
    }
    if (_selectedReviewStatus == 'rejected') {
      return appText(
        'এখনো কোনো ভিডিও বাতিল হিসেবে চিহ্নিত হয়নি।',
        'No rejected videos are recorded.',
        'لم يتم تسجيل أي فيديو مرفوض.',
      );
    }
    return appText(
      'কোনো ভিডিও মেলেনি। অন্য শব্দ বা ক্যাটাগরি দিয়ে খুঁজে দেখো।',
      'No videos found. Try another search or category.',
      'لم يتم العثور على فيديوهات. جرّب بحثًا أو تصنيفًا آخر.',
    );
  }

  String _localizedReviewStatus(VideoCatalogItem item) {
    if (item.isApproved) {
      return appText('অনুমোদিত', 'Approved', 'معتمد');
    }
    if (item.reviewStatus == 'REJECTED') {
      return appText('অনুমোদিত নয়', 'Not approved', 'غير معتمد');
    }
    return appText('যাচাই বাকি', 'In review', 'قيد المراجعة');
  }

  void _showReviewNotice(VideoCatalogItem item) {
    final message = item.isApproved
        ? appText(
            'ভিডিওটির রেকর্ড-ভিত্তিক যাচাই সম্পন্ন, কিন্তু Google-এ child-directed API client notification ও privacy setup নিশ্চিত না হওয়া পর্যন্ত player lock থাকবে।',
            'This video passed its record-level checks, but playback stays locked until the child-directed API Client notification and privacy setup with Google are confirmed.',
            'اجتاز الفيديو فحوصات السجل، لكن سيظل التشغيل مقفلاً حتى تأكيد إشعار عميل YouTube الموجّه للأطفال وإعدادات الخصوصية لدى Google.',
          )
        : item.reviewStatus == 'REJECTED'
            ? appText(
                'এই ভিডিওটি পর্যালোচনায় অনুমোদিত হয়নি। শিশুদের জন্য এটি চালানো যাবে না।',
                'This video was not approved during review and cannot be played for children.',
                'لم تتم الموافقة على هذا الفيديو أثناء المراجعة ولا يمكن تشغيله للأطفال.',
              )
            : appText(
                'এই ভিডিওটি এখনো শিশুদের জন্য আলাদাভাবে যাচাই করা হয়নি। বয়স-উপযোগিতা, Made for Kids অবস্থা ও ব্যবহারের অধিকার নিশ্চিত না হওয়া পর্যন্ত চালু করা হবে না।',
                'This video has not completed an individual child-safety review. It cannot play until age suitability, Made for Kids status and usage rights are confirmed.',
                'لم تكتمل بعد مراجعة سلامة هذا الفيديو للأطفال. لن يتم تشغيله حتى يتم تأكيد ملاءمته للعمر وحالة Made for Kids وحقوق الاستخدام.',
              );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(appText('ঠিক আছে', 'Got it', 'حسنًا')),
          ),
        ],
      ),
    );
  }

  Future<bool> _verifyParent() async {
    final random = Random.secure();
    final first = 12 + random.nextInt(8);
    final second = 7 + random.nextInt(6);
    var enteredAnswer = '';
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(
          'অভিভাবক যাচাই',
          'Parent check',
          'التحقق من ولي الأمر',
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appText(
              'ভিডিও Preview খুলতে অভিভাবকের উত্তর প্রয়োজন।',
              'A parent must pass this check before opening video previews.',
              'يجب على ولي الأمر اجتياز هذا التحقق قبل فتح معاينات الفيديو.',
            )),
            const SizedBox(height: 14),
            Text(
              '$first × $second = কত?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) => enteredAnswer = value,
              decoration: InputDecoration(
                labelText: appText('উত্তর লিখুন', 'Enter answer', 'أدخل الإجابة'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(appText('বাতিল', 'Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(int.tryParse(enteredAnswer.trim()) == first * second),
            child: Text(appText('যাচাই', 'Verify', 'تحقق')),
          ),
        ],
      ),
    );
    if (verified != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appText(
            'অভিভাবক যাচাই সম্পন্ন হয়নি।',
            'Parent verification was not completed.',
            'لم يكتمل التحقق من ولي الأمر.',
          )),
        ),
      );
    }
    return verified == true;
  }

  Future<void> _toggleParentMode() async {
    if (_parentMode) {
      setState(() {
        _parentMode = false;
        _selectedSubject = 'সব';
        _selectedLanguage = 'সব';
        _selectedReviewStatus = 'all';
        _visibleLimit = videoLibraryPageSize;
      });
      return;
    }

    if (!await _verifyParent() || !mounted) return;
    setState(() {
      _parentMode = true;
      _selectedSubject = 'সব';
      _selectedLanguage = 'সব';
      _selectedReviewStatus = 'all';
      _visibleLimit = videoLibraryPageSize;
    });
  }

  Future<void> _openParentPreview(VideoCatalogItem item) async {
    if (!_parentMode) {
      _showReviewNotice(item);
      return;
    }

    final continuePreview = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appText(
          'অভিভাবক Preview',
          'Parent preview',
          'معاينة ولي الأمر',
        )),
        content: Text(appText(
          'ভিডিওটি YouTube অ্যাপ বা browser-এ খুলবে। সেখানে YouTube-এর নিজস্ব বিজ্ঞাপন, পরবর্তী ভিডিও, search ও অন্যান্য content দেখা যেতে পারে। শিশুকে একা রেখে এই Preview চালাবেন না। এটি ভিডিওকে Approved করবে না।',
          'This opens the video in the YouTube app or browser. YouTube may show its own ads, recommendations, search and other content. Do not leave a child alone during this preview. Opening it does not approve the video.',
          'سيُفتح الفيديو في تطبيق YouTube أو المتصفح. قد يعرض YouTube إعلاناته وتوصياته والبحث ومحتوى آخر. لا تترك الطفل وحده أثناء المعاينة. فتح الفيديو لا يعني اعتماده.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(appText('বাতিল', 'Cancel', 'إلغاء')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(appText(
              'YouTube-এ খুলুন',
              'Open YouTube',
              'افتح YouTube',
            )),
          ),
        ],
      ),
    );

    if (continuePreview != true || !mounted) return;

    final uri = Uri.https(
      'www.youtube.com',
      '/watch',
      <String, String>{'v': item.videoId},
    );
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(opened
              ? appText(
                  'YouTube খোলা হয়েছে। অভিভাবকের সঙ্গে ভিডিওটি দেখুন। এটি এখনো Approved নয়।',
                  'YouTube opened. Review the video with a parent. It is not approved.',
                  'تم فتح YouTube. راجع الفيديو مع ولي الأمر. لم تتم الموافقة عليه.',
                )
              : appText(
                  'YouTube খোলা যায়নি। browser বা YouTube app আছে কি না দেখুন।',
                  'Could not open YouTube. Check that a browser or the YouTube app is available.',
                  'تعذر فتح YouTube. تحقق من توفر المتصفح أو تطبيق YouTube.',
                )),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appText(
            'YouTube খোলা যায়নি। পরে আবার চেষ্টা করুন।',
            'Could not open YouTube. Try again later.',
            'تعذر فتح YouTube. حاول مرة أخرى لاحقًا.',
          )),
        ),
      );
    }
  }

  void _openPlayer(VideoCatalogItem item) {
    if (!item.canPlayForChildren) {
      _showReviewNotice(item);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VideoPlayerScreen(
          videoId: item.videoId,
          title: item.title,
          subject: item.subject,
          language: item.language,
          isPlayable: item.canPlayForChildren,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguageController.selected,
      builder: (context, language, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            appText('ভিডিও শেখার জগৎ', 'Video learning world',
                'عالم التعلم بالفيديو'),
          ),
          actions: [
            IconButton(
              tooltip: _parentMode
                  ? appText('শিশু মোডে ফিরুন', 'Return to child mode', 'العودة إلى وضع الطفل')
                  : appText('অভিভাবক মোড খুলুন', 'Open parent mode', 'افتح وضع ولي الأمر'),
              onPressed: _toggleParentMode,
              icon: Icon(
                _parentMode
                    ? Icons.child_care_rounded
                    : Icons.admin_panel_settings_outlined,
              ),
            ),
            IconButton(
              tooltip: appText('সেভ করা ভিডিও', 'Saved videos', 'الفيديوهات المحفوظة'),
              onPressed: () => setState(() {
                _savedOnly = !_savedOnly;
                _visibleLimit = videoLibraryPageSize;
              }),
              icon: Icon(
                _savedOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<VideoCatalogItem>>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    appText(
                      'ভিডিও তালিকা লোড করা যায়নি। পরে আবার চেষ্টা করো।',
                      'The video catalogue could not be loaded. Please try again.',
                      'تعذر تحميل قائمة الفيديو. حاول مرة أخرى لاحقًا.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final items = snapshot.data!;
            final subjectOptions = items
                .map((item) => item.subject.trim())
                .where((subject) => subject.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            final subjectFilters = <String>['সব', ...subjectOptions];
            final subjectCounts = <String, int>{
              for (final subject in subjectOptions)
                subject: items.where((item) => item.subject == subject).length,
            };
            final languageOptions = items
                .map((item) => item.language)
                .where((value) => value.trim().isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            final languageCounts = <String, int>{
              for (final language in languageOptions)
                language: items.where((item) => item.language == language).length,
            };
            final rejectedCount =
                items.where((item) => item.reviewStatus == 'REJECTED').length;
            final filtered = _filter(items);
            final visible = filtered.take(_visibleLimit).toList(growable: false);
            final hasMore = visible.length < filtered.length;
            final pendingCount = items.where((item) => item.isPendingReview).length;
            final approvedCount = items.where((item) => item.isApproved).length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appText('ভিডিও শেখার সংগ্রহ',
                                    'Learning video library',
                                    'مكتبة فيديوهات التعلم'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appText(
                                  'বাংলা, English, Arabic, গণিত ও ইসলাম শিক্ষার বিষয়ভিত্তিক সংগ্রহ',
                                  'Browse Bangla, English, Arabic, Maths and Islamic learning topics',
                                  'تصفح موضوعات البنغالية والإنجليزية والعربية والرياضيات والدراسات الإسلامية',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _MetricPill(
                                    value: items.length.toString(),
                                    label: appText('মোট ভিডিও', 'Videos', 'الفيديوهات'),
                                  ),
                                  const SizedBox(width: 8),
                                  _MetricPill(
                                    value: pendingCount.toString(),
                                    label: appText('যাচাই বাকি', 'In review',
                                        'قيد المراجعة'),
                                  ),
                                  const SizedBox(width: 8),
                                  _MetricPill(
                                    value: approvedCount.toString(),
                                    label: appText('অনুমোদিত', 'Approved',
                                        'معتمد'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() => _visibleLimit = videoLibraryPageSize),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: appText('ভিডিও বা বিষয় খুঁজুন...',
                                'Search videos or subjects...',
                                'ابحث عن فيديو أو موضوع...'),
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _visibleLimit = videoLibraryPageSize);
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appText('বিষয়ভিত্তিক ফিল্টার', 'Filter by subject', 'تصفية حسب الموضوع'),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: subjectFilters.map((subject) {
                              final count = subject == 'সব'
                                  ? items.length
                                  : subjectCounts[subject] ?? 0;
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    '${_localizedSubject(subject)} ($count)',
                                  ),
                                  selected: _selectedSubject == subject,
                                  onSelected: (_) => setState(() {
                                    _selectedSubject = subject;
                                    _visibleLimit = videoLibraryPageSize;
                                  }),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ExpansionTile(
                          leading: const Icon(Icons.tune_rounded),
                          title: Text(appText(
                            'আরও ফিল্টার',
                            'More filters',
                            'المزيد من عوامل التصفية',
                          )),
                          subtitle: Text(appText(
                            'ভাষা ও যাচাইয়ের অবস্থা',
                            'Language and review status',
                            'اللغة وحالة المراجعة',
                          )),
                          childrenPadding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
                          children: [
        Text(
          appText('ভাষা', 'Language', 'اللغة'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(appText('সব ভাষা', 'All languages', 'كل اللغات')),
                selected: _selectedLanguage == 'সব',
                onSelected: (_) => setState(() {
                  _selectedLanguage = 'সব';
                  _visibleLimit = videoLibraryPageSize;
                }),
              ),
              const SizedBox(width: 8),
              ...languageOptions.map((language) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(appText(
                        'ভাষা: $language (${languageCounts[language]})',
                        'Language: $language (${languageCounts[language]})',
                        'اللغة: $language (${languageCounts[language]})',
                      )),
                      selected: _selectedLanguage == language,
                      onSelected: (_) => setState(() {
                        _selectedLanguage = language;
                        _visibleLimit = videoLibraryPageSize;
                      }),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          appText('যাচাইয়ের অবস্থা', 'Review status', 'حالة المراجعة'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: Text(appText('সব (${items.length})', 'All (${items.length})', 'الكل (${items.length})')),
              selected: _selectedReviewStatus == 'all',
              onSelected: (_) => setState(() {
                _selectedReviewStatus = 'all';
                _visibleLimit = videoLibraryPageSize;
              }),
            ),
            ChoiceChip(
              label: Text(appText('যাচাই বাকি ($pendingCount)', 'Pending ($pendingCount)', 'قيد المراجعة ($pendingCount)')),
              selected: _selectedReviewStatus == 'pending',
              onSelected: (_) => setState(() {
                _selectedReviewStatus = 'pending';
                _visibleLimit = videoLibraryPageSize;
              }),
            ),
            ChoiceChip(
              label: Text(appText('অনুমোদিত ($approvedCount)', 'Approved ($approvedCount)', 'معتمد ($approvedCount)')),
              selected: _selectedReviewStatus == 'approved',
              onSelected: (_) => setState(() {
                _selectedReviewStatus = 'approved';
                _visibleLimit = videoLibraryPageSize;
              }),
            ),
            if (rejectedCount > 0)
              ChoiceChip(
                label: Text(appText('অনুমোদিত নয় ($rejectedCount)', 'Not approved ($rejectedCount)', 'غير معتمد ($rejectedCount)')),
                selected: _selectedReviewStatus == 'rejected',
                onSelected: (_) => setState(() {
                  _selectedReviewStatus = 'rejected';
                  _visibleLimit = videoLibraryPageSize;
                }),
              ),
          ],
        ),
                          ],
                        ),
                        if (_savedOnly) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                appText('শুধু সেভ করা ভিডিও',
                                    'Saved videos only', 'الفيديوهات المحفوظة فقط'),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => setState(() {
                                  _savedOnly = false;
                                  _visibleLimit = videoLibraryPageSize;
                                }),
                                child: Text(appText('সব দেখুন', 'Show all', 'عرض الكل')),
                              ),
                            ],
                          ),
                        ],
                        if (_selectedSubject != 'সব' ||
                            _selectedLanguage != 'সব' ||
                            _selectedReviewStatus != 'all' ||
                            _searchController.text.isNotEmpty ||
                            _savedOnly)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: Text(appText('ফিল্টার মুছুন', 'Clear filters', 'مسح عوامل التصفية')),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appText(
                                  '${filtered.length}টি ভিডিও রেকর্ড',
                                  '${filtered.length} video records',
                                  '${filtered.length} سجل فيديو',
                                ),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              appText('প্রতি পৃষ্ঠায় ২০টি', '20 per page',
                                  '20 لكل صفحة'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _emptyStateMessage(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = visible[index];
                          final isSaved = _savedIds.contains(item.videoId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _parentMode ? _openParentPreview(item) : _openPlayer(item),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 76,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        _subjectIcon(item.subject),
                                        size: 34,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.channel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              _StatusTag(
                                                text: _localizedReviewStatus(item),
                                              ),
                                              Text(
                                                '${_localizedSubject(item.subject)} • ${item.language}',
                                                style: Theme.of(context).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: isSaved
                                          ? appText('সেভ থেকে বাদ দিন',
                                              'Remove saved', 'إزالة من المحفوظات')
                                          : appText('পরে দেখার জন্য সেভ করুন',
                                              'Save for later', 'احفظ للمشاهدة لاحقًا'),
                                      onPressed: () => _toggleSaved(item),
                                      icon: Icon(
                                        isSaved
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: _parentMode
                                          ? appText('YouTube-এ Parent Preview', 'Parent preview on YouTube', 'معاينة ولي الأمر على YouTube')
                                          : item.canPlayForChildren
                                              ? appText('ভিডিও চালান', 'Play video', 'تشغيل الفيديو')
                                              : appText('যাচাই ও অনুমোদন প্রয়োজন', 'Review approval required', 'مطلوب اعتماد المراجعة'),
                                      onPressed: () => _parentMode
                                          ? _openParentPreview(item)
                                          : _openPlayer(item),
                                      icon: Icon(
                                        _parentMode
                                            ? Icons.open_in_new_rounded
                                            : item.canPlayForChildren
                                                ? Icons.play_circle_fill_rounded
                                                : Icons.lock_outline_rounded,
                                        size: _parentMode || item.canPlayForChildren ? 24 : 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: visible.length,
                      ),
                    ),
                  ),
                if (hasMore)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _visibleLimit = (_visibleLimit + videoLibraryPageSize)
                                .clamp(0, filtered.length)
                                .toInt();
                          }),
                          icon: const Icon(Icons.expand_more_rounded),
                          label: Text(
                            appText('আরও ২০টি দেখুন', 'Load 20 more', 'تحميل 20 أخرى'),
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Text(
                      appText(
                        _parentMode
                            ? 'Parent Preview শুধু অভিভাবকের জন্য। YouTube বাইরে খুলবে; প্রতিটি ভিডিওর child-safety, Made for Kids, embedding ও rights যাচাই না হওয়া পর্যন্ত শিশুর Playback locked থাকবে।'
                            : 'শিশুদের Playback চালু করতে প্রতিটি ভিডিওর safety, Made for Kids, embedding ও ব্যবহারাধিকার যাচাই এবং Google child-directed client setup সম্পন্ন করতে হবে।',
                        _parentMode
                            ? 'Parent Preview is for guardians only and opens YouTube externally. Child playback stays locked until each video’s safety, Made for Kids, embedding and rights checks are complete.'
                            : 'Child playback requires per-video safety, Made for Kids, embedding and usage-rights checks, plus the Google child-directed client setup.',
                        _parentMode
                            ? 'معاينة ولي الأمر مخصصة للأوصياء وتفتح YouTube خارج التطبيق. يظل تشغيل الطفل مقفلاً حتى اكتمال فحوصات السلامة وحالة Made for Kids والتضمين والحقوق لكل فيديو.'
                            : 'يتطلب تشغيل الأطفال فحوصات السلامة وحالة Made for Kids والتضمين وحقوق الاستخدام لكل فيديو، بالإضافة إلى إعداد عميل Google الموجّه للأطفال.',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _localizedSubject(String category) {
    switch (category) {
      case 'সব':
        return appText('সব', 'All', 'الكل');
      case 'বাংলা':
        return appText('বাংলা', 'Bangla', 'البنغالية');
      case 'English':
        return 'English';
      case 'Arabic':
        return 'Arabic';
      case 'ইসলাম শিক্ষা':
        return appText('ইসলাম শিক্ষা', 'Islamic Studies', 'الدراسات الإسلامية');
      case 'গণিত':
        return appText('গণিত', 'Mathematics', 'الرياضيات');
      case 'বিজ্ঞান ও প্রকৃতি':
        return appText('বিজ্ঞান ও প্রকৃতি', 'Science & Nature', 'العلوم والطبيعة');
      default:
        return category;
    }
  }

  IconData _subjectIcon(String subject) {
    if (subject == 'ইসলাম শিক্ষা') return Icons.mosque_rounded;
    if (subject == 'গণিত') return Icons.calculate_rounded;
    if (subject == 'Arabic') return Icons.translate_rounded;
    if (subject == 'English') return Icons.abc_rounded;
    if (subject == 'বাংলা') return Icons.menu_book_rounded;
    return Icons.pets_rounded;
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
