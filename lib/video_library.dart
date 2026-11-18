import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// The catalogue supports up to 2,000 individually reviewed video records.
/// This is capacity only, not a claim that all records are approved or playable.
const int videoLibraryTargetCount = 2000;
const int videoLibraryPageSize = 20;
const bool videoLibraryAvailableForChildren = false;

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

  bool get isApproved =>
      reviewStatus == 'APPROVED' &&
      ageBand.isNotEmpty &&
      madeForKidsStatus == 'CONFIRMED_MADE_FOR_KIDS' &&
      rightsCheck == 'CONFIRMED';

  factory VideoCatalogItem.fromJson(Map<String, dynamic> json) =>
      VideoCatalogItem(
        videoId: (json['video_id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        channel: (json['channel'] ?? '').toString(),
        subject: (json['subject'] ?? '').toString(),
        language: (json['language'] ?? '').toString(),
        reviewStatus: (json['review_status'] ?? 'PENDING_REVIEW').toString(),
        ageBand: (json['age_band'] ?? '').toString(),
        madeForKidsStatus:
            (json['made_for_kids_status'] ?? 'NOT_CHECKED').toString(),
        rightsCheck: (json['rights_check'] ?? '').toString(),
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
  String _selectedCategory = 'সব';
  bool _savedOnly = false;
  int _visibleLimit = videoLibraryPageSize;

  static const List<String> _categories = <String>[
    'সব',
    'বাংলা',
    'English',
    'Arabic',
    'ইসলাম শিক্ষা',
    'গণিত',
    'বিজ্ঞান ও প্রকৃতি',
  ];

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
          _selectedCategory == 'সব' || item.subject == _selectedCategory;
      final matchesSaved = !_savedOnly || _savedIds.contains(item.videoId);
      final searchText = <String>[
        item.title,
        item.channel,
        item.subject,
        item.language,
      ].join(' ').toLowerCase();
      return matchesCategory &&
          matchesSaved &&
          (query.isEmpty || searchText.contains(query));
    }).toList(growable: false);
  }

  void _showReviewNotice(VideoCatalogItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.title),
        content: Text(
          appText(
            'এই ভিডিওটি এখনো শিশুদের জন্য আলাদাভাবে যাচাই করা হয়নি। বয়স-উপযোগিতা, Made for Kids অবস্থা ও ব্যবহারের অধিকার নিশ্চিত না হওয়া পর্যন্ত চালু করা হবে না।',
            'This video has not completed an individual child-safety review. It cannot play until age suitability, Made for Kids status and usage rights are confirmed.',
            'لم تكتمل بعد مراجعة سلامة هذا الفيديو للأطفال. لن يتم تشغيله حتى يتم تأكيد ملاءمته للعمر وحالة Made for Kids وحقوق الاستخدام.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(appText('ঠিক আছে', 'Got it', 'حسنًا')),
          ),
        ],
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
            final filtered = _filter(items);
            final visible = filtered.take(_visibleLimit).toList(growable: false);
            final hasMore = visible.length < filtered.length;
            final pendingCount = items.where((item) => !item.isApproved).length;
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
                                appText('শেখার জন্য বাছাই করা ভিডিও',
                                    'Videos made for learning',
                                    'فيديوهات مختارة للتعلم'),
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
                                    value: videoLibraryTargetCount.toString(),
                                    label: appText('লক্ষ্য', 'Target', 'الهدف'),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((category) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8),
                                child: ChoiceChip(
                                  label: Text(_localizedCategory(category)),
                                  selected: _selectedCategory == category,
                                  onSelected: (_) => setState(() {
                                    _selectedCategory = category;
                                    _visibleLimit = videoLibraryPageSize;
                                  }),
                                ),
                              );
                            }).toList(),
                          ),
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
                          appText(
                            'কোনো ভিডিও মেলেনি। অন্য শব্দ বা ক্যাটাগরি দিয়ে খুঁজে দেখো।',
                            'No videos found. Try another search or category.',
                            'لم يتم العثور على فيديوهات. جرّب بحثًا أو تصنيفًا آخر.',
                          ),
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
                              onTap: () => _showReviewNotice(item),
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
                                        _categoryIcon(item.subject),
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
                                                text: appText(
                                                  'যাচাই চলছে',
                                                  'In review',
                                                  'قيد المراجعة',
                                                ),
                                              ),
                                              Text(
                                                item.language,
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
                                    const Icon(Icons.lock_outline_rounded, size: 18),
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
                        'নিরাপত্তার জন্য এখনো ভিডিও প্লে বন্ধ। প্রতিটি ভিডিও আলাদাভাবে যাচাই ও অনুমোদনের পরই চালু হবে। ১,০০০ হলো লাইব্রেরির লক্ষ্য—বর্তমান ভিডিও সংখ্যা নয়।',
                        'Playback remains off for safety. Each video must pass an individual review before it can be enabled. 2,000 is the library capacity, not the current video count.',
                        'التشغيل متوقف حاليًا حفاظًا على السلامة. يجب مراجعة كل فيديو واعتماده بشكل منفصل قبل تفعيله. 2000 هي سعة المكتبة وليست العدد الحالي للفيديوهات.',
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

  String _localizedCategory(String category) {
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

  IconData _categoryIcon(String subject) {
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
