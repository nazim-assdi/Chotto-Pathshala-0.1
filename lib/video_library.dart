import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

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

class VideoFeedSource {
  const VideoFeedSource({required this.name, required this.subject, required this.language, required this.format, this.channelId, this.legacyUser});
  final String name, subject, language, format;
  final String? channelId, legacyUser;
  Uri get feedUri => Uri.https('www.youtube.com', '/xml/feeds/videos.xml',
    channelId != null ? {'channel_id': channelId!} : {'user': legacyUser!});
}

/// Channel feeds discover metadata only. They never approve or play a video.
const videoFeedSources = <VideoFeedSource>[
  VideoFeedSource(name: 'Learn With Zakaria', channelId: 'UCtlcIZVBdFPSAtCoNZsTusg', subject: 'Arabic', language: 'English + Arabic', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Arabic Khatawaat', channelId: 'UCW2AgHPThj9_8raWYE2yjfw', subject: 'Arabic', language: 'Arabic', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Alif Baa Taa Kids', channelId: 'UCQPYspoIhOtBS58s6QxjKMQ', subject: 'Arabic', language: 'Arabic', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'Kalam Kids', channelId: 'UCdr_45nR1o2P4ycckLh1xOQ', subject: 'ইসলাম শিক্ষা', language: 'English + Arabic', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'Arabic for the World for Kids', channelId: 'UCUv6vbrigNkwpybcjvOA5Mg', subject: 'Arabic', language: 'Arabic', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'One4Kids / Zaky', channelId: 'UC5vfWTTPnKdFp-8s0KbqJhw', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'Omar & Hana', channelId: 'UC178EmfQAV3OT-UpuO6WUMg', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'Muslim Reminder Kids', channelId: 'UCUUQonfh_yNkI6h0O2a6nRA', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'IQRA Cartoon', channelId: 'UCSL4Dn-FQlvHZiSKipQZMqw', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'DUA KIDS', channelId: 'UCRb4jRq4VZWPNNUCE-_Ydaw', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: 'Ousratouna', channelId: 'UCWIdqSQekeGmUWlSFeCiEnA', subject: 'ইসলাম শিক্ষা', language: 'Arabic', format: 'কার্টুন'),
  VideoFeedSource(name: 'Abata', channelId: 'UCxHAohzMS4a2alUmWZeyZuw', subject: 'ইসলাম শিক্ষা', language: 'Arabic', format: 'কার্টুন'),
  VideoFeedSource(name: 'Free Quran Education', legacyUser: 'NAKcollection', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Muslim Kids TV', legacyUser: 'miloproductionsinc', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Discover Islam UK', legacyUser: 'DiscoverIslamUK', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Noor Kids', legacyUser: 'NoorKids', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Zulfy World', channelId: 'UCRNQLb5rFcMX5o1RMZE9LCg', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'ইসলামিক গল্প'),
  VideoFeedSource(name: 'SciShow Kids', legacyUser: 'scishowkids', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'KidsEduc', channelId: 'UCFCbjNyMJqEWKQEhFwfUjkA', subject: 'English', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Homeschool Pop', channelId: 'UCfPyVJEBD7Di1YYjTdS2v8g', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Math & Learning Videos 4 Kids', channelId: 'UCZXWbHkJAHqy6fGYPNsnqzw', subject: 'গণিত', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Wizz Learning', channelId: 'UCG9banTw-zsDXFrNdDQfg6Q', subject: 'English', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Kids Learning Videos', legacyUser: 'Kidslearningvideo', subject: 'English', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Preschool Prep Company', legacyUser: 'PreschoolPrep', subject: 'English', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Burka Avenger', channelId: 'UCOkkZbztV5LM4-VMNjbg5JQ', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'ইসলামিক কার্টুন'),
  VideoFeedSource(name: '5-Minute Crafts KIDS', channelId: 'UC57XAjJ04TY8gNxOWf-Sy0Q', subject: 'শিল্প ও সৃজনশীলতা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Curious George Official', channelId: 'UCu7IDy0y-ZA0qaG51wrQY6w', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'কার্টুন'),
  VideoFeedSource(name: 'Octonauts', channelId: 'UCXLLQkbYE-G9jYrra7R4Qsw', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English', format: 'কার্টুন'),
  VideoFeedSource(name: 'Wizz Cartoons', channelId: 'UCN3j3Equ2SHwJhLPERmQquw', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'কার্টুন'),
  VideoFeedSource(name: 'Wizz Explore', channelId: 'UCpetG1dVOjzFF3pcqA18YIQ', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Wizz Friends', channelId: 'UCkHrTT9PChTkFH_qUtoo2lw', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'কার্টুন'),
  VideoFeedSource(name: 'Kids Star TV', channelId: 'UCmxi_8fP1jVKSBMU4VgwkUg', subject: 'সাধারণ জ্ঞান', language: 'English', format: 'কার্টুন'),
  VideoFeedSource(name: 'Reqaman', channelId: 'UCP2t9ae-Veze7Nofsg-fubQ', subject: 'Arabic', language: 'Arabic', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'YouQaria Kids', channelId: 'UCwiIpiPPMB17SigZ4n3jpmA', subject: 'ইসলাম শিক্ষা', language: 'Arabic', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Islam Channel Kids', legacyUser: 'ickidsonline', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
  VideoFeedSource(name: 'Mountain of Light', legacyUser: 'supportpeace', subject: 'ইসলাম শিক্ষা', language: 'English', format: 'শিক্ষামূলক পাঠ'),
];
const videoSubjects = <String>['English','Arabic','বাংলা','গণিত','বিজ্ঞান ও প্রকৃতি','ইসলাম শিক্ষা','ইতিহাস','ভূগোল','কম্পিউটার','শিল্প ও সৃজনশীলতা','স্বাস্থ্য ও জীবনদক্ষতা','সাধারণ জ্ঞান'];
const videoLanguages = <String>['English','Arabic','বাংলা','English + Arabic'];
const videoFormats = <String>['শিক্ষামূলক পাঠ','ইসলামিক কার্টুন','কার্টুন','ইসলামিক গল্প'];

String? parseYouTubeVideoId(String input) {
  final value = input.trim();
  if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value)) return value;
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority) return null;
  final host = uri.host.toLowerCase();
  if (!const {'youtube.com','www.youtube.com','m.youtube.com','youtu.be','www.youtu.be'}.contains(host)) return null;
  String? id;
  if (host.endsWith('youtu.be')) {
    id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  } else if (uri.path == '/watch') {
    id = uri.queryParameters['v'];
  } else if (uri.pathSegments.length >= 2 && const {'embed','shorts','live','v'}.contains(uri.pathSegments.first)) {
    id = uri.pathSegments[1];
  }
  return id != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id) ? id : null;
}

/// Parse Atom XML to PENDING_REVIEW candidates, with all safety fields unset.
List<VideoCatalogItem> parseYouTubeAtomFeed(
  String raw,
  VideoFeedSource source, {
  Set<String> existingIds = const <String>{},
}) {
  final document = xml.XmlDocument.parse(raw);
  final seen = <String>{...existingIds};
  final result = <VideoCatalogItem>[];
  for (final entry in document.descendants
      .whereType<xml.XmlElement>()
      .where((node) => node.name.local == 'entry')) {
    String field(String localName) {
      for (final node in entry.descendants.whereType<xml.XmlElement>()) {
        if (node.name.local == localName) {
          return node.innerText.trim();
        }
      }
      return '';
    }
    final id = field('videoId');
    final title = field('title').replaceAll(RegExp(r'\s+'), ' ').trim();
    final validId = RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id);
    final lowerTitle = title.toLowerCase();
    if (!validId ||
        title.isEmpty ||
        lowerTitle.contains('#shorts') ||
        lowerTitle.contains('shorts video') ||
        !seen.add(id)) {
      continue;
    }
    result.add(VideoCatalogItem(
      videoId: id,
      title: title,
      channel: source.name,
      subject: source.subject,
      language: source.language,
      format: source.format,
      source: 'CHANNEL_FEED',
      reviewStatus: 'PENDING_REVIEW',
      ageBand: '',
      madeForKidsStatus: 'NOT_CHECKED',
      rightsCheck: '',
      embeddingStatus: 'NOT_CHECKED',
    ));
  }
  return result;
}
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
    this.format = 'শিক্ষামূলক পাঠ',
    this.source = 'BUNDLED',
    this.contentSuitabilityConfirmed = false,
    this.reviewer = '',
    this.reviewedAt = '',
    this.reviewNotes = '',
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
  final String embeddingStatus, format, source;
  final bool contentSuitabilityConfirmed;
  final String reviewer, reviewedAt, reviewNotes;

  Map<String, dynamic> toJson() => {
    'video_id': videoId, 'title': title, 'channel': channel, 'subject': subject,
    'language': language, 'format': format, 'source': source,
    'review_status': reviewStatus, 'age_band': ageBand,
    'made_for_kids_status': madeForKidsStatus, 'rights_check': rightsCheck,
    'embedding_status': embeddingStatus,
    'content_suitability_confirmed': contentSuitabilityConfirmed,
    'reviewer': reviewer, 'reviewed_at': reviewedAt, 'review_notes': reviewNotes,
  };

  VideoCatalogItem asPendingCandidate() => VideoCatalogItem(
    videoId: videoId, title: title, channel: channel, subject: subject,
    language: language, format: format, source: source,
    reviewStatus: 'PENDING_REVIEW', ageBand: '',
    madeForKidsStatus: 'NOT_CHECKED', rightsCheck: '',
    embeddingStatus: 'NOT_CHECKED', contentSuitabilityConfirmed: false,
    reviewer: '', reviewedAt: '', reviewNotes: '',
  );

  VideoCatalogItem withReview({
    required String reviewStatus,
    required String ageBand,
    required String madeForKidsStatus,
    required String rightsCheck,
    required String embeddingStatus,
    required bool contentSuitabilityConfirmed,
    required String reviewer,
    required String reviewedAt,
    required String reviewNotes,
  }) => VideoCatalogItem(
    videoId: videoId, title: title, channel: channel, subject: subject,
    language: language, format: format, source: source,
    reviewStatus: reviewStatus, ageBand: ageBand,
    madeForKidsStatus: madeForKidsStatus, rightsCheck: rightsCheck,
    embeddingStatus: embeddingStatus,
    contentSuitabilityConfirmed: contentSuitabilityConfirmed,
    reviewer: reviewer, reviewedAt: reviewedAt, reviewNotes: reviewNotes,
  );

  bool get isLocallyManaged => source == 'CHANNEL_FEED' || source == 'USER_ADDED';

  bool get isApproved =>
      reviewStatus == 'APPROVED' &&
      ageBand.isNotEmpty &&
      madeForKidsStatus == 'CONFIRMED_MADE_FOR_KIDS' &&
      rightsCheck == 'CONFIRMED' &&
      embeddingStatus == 'CONFIRMED_EMBEDDABLE' &&
      contentSuitabilityConfirmed &&
      reviewer.trim().isNotEmpty &&
      reviewedAt.trim().isNotEmpty &&
      reviewNotes.trim().isNotEmpty;

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
        embeddingStatus: (json['embedding_status'] ?? 'NOT_CHECKED').toString().trim(),
        format: (json['format'] ?? 'শিক্ষামূলক পাঠ').toString().trim(),
        source: (json['source'] ?? 'BUNDLED').toString().trim(),
        contentSuitabilityConfirmed: json['content_suitability_confirmed'] == true,
        reviewer: (json['reviewer'] ?? '').toString().trim(),
        reviewedAt: (json['reviewed_at'] ?? '').toString().trim(),
        reviewNotes: (json['review_notes'] ?? '').toString().trim(),
      );
}

class VideoLibraryRepository {
  static final ValueNotifier<int> catalogRevision = ValueNotifier<int>(0);

  static void notifyCatalogChanged() {
    catalogRevision.value++;
  }

  static const String _assetPath = 'assets/videos/video_catalog.json';
  static const String userCandidatesKey = 'video_library_user_candidates_v1';
  static const String feedCandidatesKey = 'video_library_feed_candidates_v1';
  static const String reviewRecordsKey = 'video_library_review_records_v1';

  Future<List<VideoCatalogItem>> load() async {
    final bundled = parse(await rootBundle.loadString(_assetPath));
    final prefs = await SharedPreferences.getInstance();
    final merged = <String, VideoCatalogItem>{
      for (final item in bundled) item.videoId: item,
    };
    for (final key in [feedCandidatesKey, userCandidatesKey]) {
      for (final raw in prefs.getStringList(key) ?? const <String>[]) {
        try {
          final value = jsonDecode(raw);
          if (value is! Map) continue;
          final candidate = VideoCatalogItem.fromJson(
            value.map((k, v) => MapEntry(k.toString(), v)),
          ).asPendingCandidate();
          if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(candidate.videoId) &&
              candidate.title.isNotEmpty && candidate.channel.isNotEmpty) {
            merged.putIfAbsent(candidate.videoId, () => candidate);
          }
        } catch (_) {
          // Ignore corrupt local candidate metadata.
        }
      }
    }
    final reviewed = applyReviewRecords(
      merged.values.toList(growable: false),
      prefs.getStringList(reviewRecordsKey) ?? const <String>[],
    );
    return List<VideoCatalogItem>.unmodifiable(
      reviewed.take(videoLibraryTargetCount),
    );
  }

  @visibleForTesting
  static List<VideoCatalogItem> applyReviewRecords(
    List<VideoCatalogItem> items,
    List<String> rawRecords,
  ) {
    final merged = <String, VideoCatalogItem>{
      for (final item in items) item.videoId: item,
    };
    for (final raw in rawRecords) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final values = decoded.map((key, value) => MapEntry(key.toString(), value));
        final review = VideoCatalogItem.fromJson(values);
        final current = merged[review.videoId];
        if (current == null) continue;
        if (!{'APPROVED', 'REJECTED', 'PENDING_REVIEW'}.contains(review.reviewStatus)) {
          continue;
        }
        if (review.reviewer.isEmpty || review.reviewedAt.isEmpty) continue;
        if (review.reviewStatus == 'APPROVED' && !review.isApproved) continue;
        if (review.reviewStatus == 'REJECTED' && review.reviewNotes.isEmpty) continue;
        merged[review.videoId] = current.withReview(
          reviewStatus: review.reviewStatus,
          ageBand: review.ageBand,
          madeForKidsStatus: review.madeForKidsStatus,
          rightsCheck: review.rightsCheck,
          embeddingStatus: review.embeddingStatus,
          contentSuitabilityConfirmed: review.contentSuitabilityConfirmed,
          reviewer: review.reviewer,
          reviewedAt: review.reviewedAt,
          reviewNotes: review.reviewNotes,
        );
      } catch (_) {
        // Ignore malformed local review records; the base item stays pending.
      }
    }
    return merged.values.toList(growable: false);
  }

  Future<void> saveReview(VideoCatalogItem item) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(item.videoId)) {
      throw const FormatException('Invalid YouTube video ID.');
    }
    if (!{'APPROVED', 'REJECTED', 'PENDING_REVIEW'}.contains(item.reviewStatus)) {
      throw const FormatException('Invalid review status.');
    }
    if (item.reviewer.trim().isEmpty || item.reviewedAt.trim().isEmpty) {
      throw const FormatException('Reviewer and review date are required.');
    }
    if (item.reviewStatus == 'APPROVED' && !item.isApproved) {
      throw const FormatException('Complete all approval checks and evidence first.');
    }
    if (item.reviewStatus == 'REJECTED' && item.reviewNotes.trim().isEmpty) {
      throw const FormatException('A rejection reason is required.');
    }
    final prefs = await SharedPreferences.getInstance();
    final records = <String, VideoCatalogItem>{};
    for (final raw in prefs.getStringList(reviewRecordsKey) ?? const <String>[]) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final record = VideoCatalogItem.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
        records[record.videoId] = record;
      } catch (_) {}
    }
    records[item.videoId] = item;
    await prefs.setStringList(
      reviewRecordsKey,
      records.values.map((record) => jsonEncode(record.toJson())).toList(),
    );
    notifyCatalogChanged();
  }

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

class VideoReviewDashboard extends StatefulWidget {
  const VideoReviewDashboard({
    super.key,
    this.repository,
    this.previewLauncher,
  });

  final VideoLibraryRepository? repository;
  final Future<bool> Function(String videoId)? previewLauncher;

  @override
  State<VideoReviewDashboard> createState() => _VideoReviewDashboardState();
}

class _VideoReviewDashboardState extends State<VideoReviewDashboard> {
  late final VideoLibraryRepository _repository;
  late Future<List<VideoCatalogItem>> _itemsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? VideoLibraryRepository();
    _itemsFuture = _repository.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _itemsFuture = _repository.load());
    await _itemsFuture;
  }

  Future<void> _preview(VideoCatalogItem item) async {
    var opened = false;
    try {
      opened = widget.previewLauncher != null
          ? await widget.previewLauncher!(item.videoId)
          : await launchUrl(
              Uri.https('www.youtube.com', '/watch', {'v': item.videoId}),
              mode: LaunchMode.externalApplication,
            );
    } catch (_) {
      opened = false;
    }
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText(
        'YouTube খোলা যায়নি। Browser বা internet সংযোগ পরীক্ষা করো।',
        'Could not open YouTube. Check the browser and internet connection.',
        'تعذر فتح YouTube. تحقق من المتصفح واتصال الإنترنت.',
      ))),
    );
  }

  Future<void> _edit(VideoCatalogItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VideoReviewEditorScreen(
          item: item,
          repository: _repository,
          previewLauncher: widget.previewLauncher,
        ),
      ),
    );
    if (changed == true && mounted) {
      setState(() => _itemsFuture = _repository.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appText('ভিডিও যাচাই Dashboard', 'Video review dashboard', 'لوحة مراجعة الفيديو')),
        actions: [
          IconButton(
            tooltip: appText('তালিকা refresh', 'Refresh list', 'تحديث القائمة'),
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<VideoCatalogItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(appText(
                'ভিডিও তালিকা লোড করা যায়নি।',
                'Could not load the video catalogue.',
                'تعذر تحميل قائمة الفيديو.',
              )),
            );
          }
          final all = snapshot.data!;
          final pending = all.where((item) => item.isPendingReview).length;
          final approved = all.where((item) => item.isApproved).length;
          final rejected = all.where((item) => item.reviewStatus == 'REJECTED').length;
          final query = _searchController.text.trim().toLowerCase();
          final visible = all.where((item) {
            final matchesStatus = switch (_status) {
              'approved' => item.isApproved,
              'rejected' => item.reviewStatus == 'REJECTED',
              'all' => true,
              _ => item.isPendingReview,
            };
            final text = '${item.title} ${item.channel} ${item.videoId} ${item.subject}'.toLowerCase();
            return matchesStatus && (query.isEmpty || text.contains(query));
          }).toList(growable: false);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ReviewCountPill(label: appText('যাচাই বাকি', 'Pending', 'قيد المراجعة'), value: pending),
                        _ReviewCountPill(label: appText('অনুমোদিত', 'Approved', 'معتمد'), value: approved),
                        _ReviewCountPill(label: appText('বাতিল', 'Rejected', 'مرفوض'), value: rejected),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!videoLibraryAvailableForChildren)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(appText(
                          'এই Build-এ YouTube child-directed configuration চালু নেই। ভিডিও যাচাই করে Approved করা যাবে, কিন্তু Google-এর প্রয়োজনীয় setup সম্পন্ন না হওয়া পর্যন্ত শিশুদের player lock থাকবে।',
                          'YouTube child-directed configuration is not enabled in this build. You can review videos, but child playback remains locked until the required Google setup is completed.',
                          'إعداد YouTube الموجّه للأطفال غير مفعّل في هذا الإصدار. يمكنك مراجعة الفيديوهات، لكن تشغيل الأطفال سيظل مقفلاً حتى إكمال إعداد Google المطلوب.',
                        )),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(appText(
                        'এই Review Dashboard-এ PIN নেই। এটি বড়দের যাচাইয়ের জন্য—শিশুকে একা এই স্ক্রিন ব্যবহার করতে দেবে না।',
                        'This review dashboard has no PIN. It is intended for adult review; do not leave a child alone on this screen.',
                        'لوحة المراجعة هذه لا تحتوي على رمز PIN. وهي مخصصة لمراجعة البالغين؛ لا تترك الطفل يستخدم هذه الشاشة بمفرده.',
                      ), style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: appText('ভিডিও খুঁজুন...', 'Search videos...', 'ابحث عن فيديوهات...'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _reviewFilterChip('pending', appText('যাচাই বাকি', 'Pending', 'قيد المراجعة')),
                          _reviewFilterChip('all', appText('সব', 'All', 'الكل')),
                          _reviewFilterChip('approved', appText('অনুমোদিত', 'Approved', 'معتمد')),
                          _reviewFilterChip('rejected', appText('বাতিল', 'Rejected', 'مرفوض')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(appText('${visible.length}টি ভিডিও', '${visible.length} videos', '${visible.length} فيديو'), style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? Center(child: Text(appText('এই তালিকায় ভিডিও নেই।', 'No videos in this view.', 'لا توجد فيديوهات في هذا العرض.')))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          final status = item.isApproved
                              ? appText('অনুমোদিত', 'Approved', 'معتمد')
                              : item.reviewStatus == 'REJECTED'
                                  ? appText('বাতিল', 'Rejected', 'مرفوض')
                                  : appText('যাচাই বাকি', 'Pending review', 'قيد المراجعة');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('${item.channel} • ${item.subject} • ${item.language}', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 6),
                                  Text(status, style: TextStyle(color: item.isApproved ? Colors.green : item.reviewStatus == 'REJECTED' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _preview(item),
                                        icon: const Icon(Icons.open_in_new_rounded),
                                        label: Text(appText('ভিডিও Preview', 'Preview video', 'معاينة الفيديو')),
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => _edit(item),
                                        icon: const Icon(Icons.fact_check_outlined),
                                        label: Text(appText('যাচাই করুন', 'Review', 'مراجعة')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _reviewFilterChip(String value, String label) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _status == value,
          onSelected: (_) => setState(() => _status = value),
        ),
      );
}

class _ReviewCountPill extends StatelessWidget {
  const _ReviewCountPill({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.video_library_outlined, size: 16),
        label: Text('$label: $value'),
      );
}

class VideoReviewEditorScreen extends StatefulWidget {
  const VideoReviewEditorScreen({
    super.key,
    required this.item,
    required this.repository,
    this.previewLauncher,
  });

  final VideoCatalogItem item;
  final VideoLibraryRepository repository;
  final Future<bool> Function(String videoId)? previewLauncher;

  @override
  State<VideoReviewEditorScreen> createState() => _VideoReviewEditorScreenState();
}

class _VideoReviewEditorScreenState extends State<VideoReviewEditorScreen> {
  static const List<String> _ageBands = [
    'Playgroup (2–3)',
    'Nursery (3–4)',
    'KG (4–5)',
    'Class 1 (5–6)',
    'Class 2 (6–7)',
  ];

  late String? _ageBand;
  late bool _contentSuitable;
  late bool _madeForKids;
  late bool _rightsConfirmed;
  late bool _embeddingConfirmed;
  late final TextEditingController _reviewerController;
  late final TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ageBand = _ageBands.contains(widget.item.ageBand) ? widget.item.ageBand : null;
    _contentSuitable = widget.item.contentSuitabilityConfirmed;
    _madeForKids = widget.item.madeForKidsStatus == 'CONFIRMED_MADE_FOR_KIDS';
    _rightsConfirmed = widget.item.rightsCheck == 'CONFIRMED';
    _embeddingConfirmed = widget.item.embeddingStatus == 'CONFIRMED_EMBEDDABLE';
    _reviewerController = TextEditingController(text: widget.item.reviewer);
    _notesController = TextEditingController(text: widget.item.reviewNotes);
  }

  @override
  void dispose() {
    _reviewerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canApprove =>
      _ageBand != null &&
      _contentSuitable &&
      _madeForKids &&
      _rightsConfirmed &&
      _embeddingConfirmed &&
      _reviewerController.text.trim().isNotEmpty &&
      _notesController.text.trim().isNotEmpty &&
      !_saving;

  Future<void> _preview() async {
    var opened = false;
    try {
      opened = widget.previewLauncher != null
          ? await widget.previewLauncher!(widget.item.videoId)
          : await launchUrl(
              Uri.https('www.youtube.com', '/watch', {'v': widget.item.videoId}),
              mode: LaunchMode.externalApplication,
            );
    } catch (_) {
      opened = false;
    }
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText('YouTube খোলা যায়নি।', 'Could not open YouTube.', 'تعذر فتح YouTube.'))),
    );
  }

  Future<void> _save(String status) async {
    final reviewer = _reviewerController.text.trim();
    final notes = _notesController.text.trim();
    if (reviewer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appText('যাচাইকারীর নাম লিখুন।', 'Enter reviewer name.', 'أدخل اسم المراجع.'))));
      return;
    }
    if (status == 'APPROVED' && !_canApprove) return;
    if (status == 'REJECTED' && notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appText('বাতিলের কারণ লিখুন।', 'Enter a rejection reason.', 'أدخل سبب الرفض.'))));
      return;
    }
    setState(() => _saving = true);
    final reviewed = widget.item.withReview(
      reviewStatus: status,
      ageBand: _ageBand ?? '',
      madeForKidsStatus: _madeForKids ? 'CONFIRMED_MADE_FOR_KIDS' : 'NOT_CHECKED',
      rightsCheck: _rightsConfirmed ? 'CONFIRMED' : '',
      embeddingStatus: _embeddingConfirmed ? 'CONFIRMED_EMBEDDABLE' : 'NOT_CHECKED',
      contentSuitabilityConfirmed: _contentSuitable,
      reviewer: reviewer,
      reviewedAt: DateTime.now().toIso8601String(),
      reviewNotes: notes,
    );
    try {
      await widget.repository.saveReview(reviewed);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appText('সংরক্ষণ করা যায়নি: $error', 'Could not save: $error', 'تعذر الحفظ: $error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appText('ভিডিও যাচাই', 'Review video', 'مراجعة الفيديو'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.item.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('${widget.item.channel} • ${widget.item.videoId}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _preview,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text(appText('YouTube-এ পুরো ভিডিও দেখুন', 'Watch full video on YouTube', 'شاهد الفيديو كاملاً على YouTube')),
          ),
          const SizedBox(height: 8),
          Text(appText(
            'ভিডিওটি নতুন Browser/YouTube tab-এ খুলবে। শুরু থেকে শেষ পর্যন্ত দেখে এই অ্যাপে ফিরে এসে যাচাই করুন। Preview করলেই ভিডিও অনুমোদিত হবে না।',
            'The video opens in your browser/YouTube app. Watch it from beginning to end, return here and complete the checks. Preview alone never approves a video.',
            'سيُفتح الفيديو في المتصفح أو تطبيق YouTube. شاهده من البداية إلى النهاية ثم ارجع لإكمال الفحوصات. المعاينة وحدها لا تعني الموافقة.',
          ), style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _ageBand,
            decoration: InputDecoration(
              labelText: appText('কোন শ্রেণির জন্য উপযুক্ত?', 'Suitable age/class band', 'الفئة العمرية/الصف المناسب'),
              border: const OutlineInputBorder(),
            ),
            items: _ageBands.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: _saving ? null : (value) => setState(() => _ageBand = value),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _contentSuitable,
            onChanged: _saving ? null : (value) => setState(() => _contentSuitable = value ?? false),
            title: Text(appText('পুরো ভিডিও দেখে নির্বাচিত বয়সের জন্য নিরাপদ ও শিক্ষামূলক নিশ্চিত করেছি', 'I watched the full video and confirmed it is suitable for the selected age group', 'شاهدت الفيديو كاملاً وتأكدت من ملاءمته للفئة العمرية المحددة')),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _madeForKids,
            onChanged: _saving ? null : (value) => setState(() => _madeForKids = value ?? false),
            title: Text(appText('YouTube-এর Made for Kids status নিশ্চিত করেছি', 'I verified the video’s Made for Kids status with YouTube evidence', 'تحققت من حالة Made for Kids بمصدر موثوق من YouTube')),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _rightsConfirmed,
            onChanged: _saving ? null : (value) => setState(() => _rightsConfirmed = value ?? false),
            title: Text(appText('অ্যাপে embed করার জন্য ব্যবহার-অনুমতি / লাইসেন্স নিশ্চিত করেছি', 'I confirmed permission or a licence to include this video in the app', 'أكدت الإذن أو الترخيص لإدراج هذا الفيديو في التطبيق')),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _embeddingConfirmed,
            onChanged: _saving ? null : (value) => setState(() => _embeddingConfirmed = value ?? false),
            title: Text(appText('YouTube-এর embedding অনুমতি নিশ্চিত করেছি', 'I confirmed that YouTube allows this video to be embedded', 'أكدت أن YouTube يسمح بتضمين هذا الفيديو')),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewerController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: appText('যাচাইকারীর নাম', 'Reviewer name', 'اسم المراجع'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            onChanged: (_) => setState(() {}),
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: appText('প্রমাণ / যাচাইয়ের নোট (আবশ্যক)', 'Evidence / review notes (required)', 'أدلة / ملاحظات المراجعة (مطلوبة)'),
              hintText: appText('যেমন: YouTube status source, licence URL, content notes', 'e.g. YouTube status source, licence URL, content notes', 'مثال: مصدر حالة YouTube ورابط الترخيص وملاحظات المحتوى'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _saving ? null : () => _save('PENDING_REVIEW'),
                child: Text(appText('Pending হিসেবে রাখুন', 'Save as pending', 'حفظ كمعلّق')),
              ),
              OutlinedButton(
                onPressed: _saving ? null : () => _save('REJECTED'),
                child: Text(appText('Reject', 'Reject', 'رفض')),
              ),
              FilledButton.icon(
                onPressed: _canApprove ? () => _save('APPROVED') : null,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(appText('Approve', 'Approve', 'موافقة')),
              ),
            ],
          ),
          if (_saving) const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
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
  String _selectedFormat = 'সব ধরন';
  bool _savedOnly = false;
  bool _refreshingFeeds = false;
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
      final matchesFormat = _selectedFormat == 'সব ধরন' || item.format == _selectedFormat;
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
          matchesFormat &&
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
      _selectedFormat = 'সব ধরন';
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

  Future<void> _storeCandidates(String key, List<VideoCatalogItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      items.map((item) => jsonEncode(item.asPendingCandidate().toJson())).toList(),
    );
  }

  Future<void> _refreshChannelFeeds() async {
    if (_refreshingFeeds) return;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appText(
          'Web preview-তে browser CORS সীমাবদ্ধতার কারণে feed refresh নাও চলতে পারে। Android/Desktop app থেকে চেষ্টা করো।',
          'Browser CORS may block feed refresh in the web preview. Try the Android or desktop app.',
          'قد تمنع قيود CORS تحديث الخلاصات في معاينة الويب. جرّب تطبيق Android أو سطح المكتب.',
        ))),
      );
      return;
    }

    setState(() => _refreshingFeeds = true);
    final discovered = <String, VideoCatalogItem>{};
    try {
      final existingIds = (await _repository.load()).map((item) => item.videoId).toSet();
      const batchSize = 6;
      for (var offset = 0; offset < videoFeedSources.length; offset += batchSize) {
        final batch = videoFeedSources.skip(offset).take(batchSize);
        final groups = await Future.wait(batch.map((source) async {
          try {
            final response = await http.get(
              source.feedUri,
              headers: const {'Accept': 'application/atom+xml, application/xml, text/xml'},
            ).timeout(const Duration(seconds: 5));
            if (response.statusCode != 200) return <VideoCatalogItem>[];
            return parseYouTubeAtomFeed(
              response.body,
              source,
              existingIds: {...existingIds, ...discovered.keys},
            );
          } catch (_) {
            return <VideoCatalogItem>[];
          }
        }));
        for (final group in groups) {
          for (final item in group) {
            if (existingIds.length + discovered.length >= videoLibraryTargetCount) {
              break;
            }
            discovered.putIfAbsent(item.videoId, () => item);
          }
          if (existingIds.length + discovered.length >= videoLibraryTargetCount) {
            break;
          }
        }
      }

      if (discovered.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final stored = <String, VideoCatalogItem>{};
        for (final raw in prefs.getStringList(VideoLibraryRepository.feedCandidatesKey) ?? const <String>[]) {
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            final item = VideoCatalogItem.fromJson(map).asPendingCandidate();
            stored[item.videoId] = item;
          } catch (_) {}
        }
        stored.addAll(discovered);
        await _storeCandidates(VideoLibraryRepository.feedCandidatesKey, stored.values.toList());
        VideoLibraryRepository.notifyCatalogChanged();
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshingFeeds = false;
          _catalogFuture = _repository.load();
        });
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(discovered.isEmpty
            ? appText('নতুন feed ভিডিও পাওয়া যায়নি; আগের তালিকা রাখা হয়েছে।', 'No new feed videos found; the saved catalogue is unchanged.', 'لم يتم العثور على فيديوهات جديدة؛ تم الاحتفاظ بالقائمة السابقة.')
            : appText(
                '${discovered.length}টি নতুন ভিডিও review queue-তে যোগ হয়েছে। সবগুলো pending review।',
                '${discovered.length} new videos added to the review queue. All remain pending review.',
                'تمت إضافة ${discovered.length} فيديو إلى قائمة المراجعة. كلها قيد المراجعة.',
              )),
      ),
    );
  }

  Future<void> _addVideoCandidate() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    var subject = 'English';
    var language = 'English';
    var format = 'শিক্ষামূলক পাঠ';

    final result = await showDialog<VideoCatalogItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refreshDialog) => AlertDialog(
          title: Text(appText('নিজের শেখার ভিডিও যোগ', 'Add a learning video', 'أضف فيديو تعليميًا')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  maxLength: 100,
                  decoration: InputDecoration(labelText: appText('ভিডিওর নাম', 'Video title', 'عنوان الفيديو')),
                ),
                TextField(
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(labelText: appText('YouTube URL বা ১১ অক্ষরের ID', 'YouTube URL or 11-character ID', 'رابط YouTube أو معرّف من 11 حرفًا')),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: language,
                  decoration: InputDecoration(labelText: appText('ভাষা', 'Language', 'اللغة')),
                  items: videoLanguages.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) { if (value != null) refreshDialog(() => language = value); },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: subject,
                  decoration: InputDecoration(labelText: appText('বিষয়', 'Subject', 'الموضوع')),
                  items: videoSubjects.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) { if (value != null) refreshDialog(() => subject = value); },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: format,
                  decoration: InputDecoration(labelText: appText('ধরন', 'Format', 'النوع')),
                  items: videoFormats.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) { if (value != null) refreshDialog(() => format = value); },
                ),
                const SizedBox(height: 8),
                Text(
                  appText(
                    'ভিডিওটি শুধু review queue-তে থাকবে; শিশুদের player-এ চালু হবে না।',
                    'The video enters the review queue only and will not play in the child player.',
                    'سيُضاف الفيديو إلى قائمة المراجعة فقط ولن يعمل في مشغل الأطفال.',
                  ),
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(appText('বাতিল', 'Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () {
                final id = parseYouTubeVideoId(urlController.text);
                if (titleController.text.trim().isEmpty || id == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(appText('সঠিক শিরোনাম ও YouTube URL/ID দিন।', 'Enter a title and a valid YouTube URL or ID.', 'أدخل عنوانًا ورابط YouTube أو معرّفًا صالحًا.'))),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  VideoCatalogItem(
                    videoId: id,
                    title: titleController.text.trim(),
                    channel: 'নিজে যোগ করা ভিডিও',
                    subject: subject,
                    language: language,
                    format: format,
                    source: 'USER_ADDED',
                    reviewStatus: 'PENDING_REVIEW',
                    ageBand: '',
                    madeForKidsStatus: 'NOT_CHECKED',
                    rightsCheck: '',
                    embeddingStatus: 'NOT_CHECKED',
                  ),
                );
              },
              child: Text(appText('Review queue-তে যোগ', 'Add to review queue', 'أضف إلى قائمة المراجعة')),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    urlController.dispose();
    if (result == null || !mounted) return;
    final current = await _repository.load();
    if (!mounted) return;
    if (current.length >= videoLibraryTargetCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appText(
          'ভিডিও সংগ্রহের সর্বোচ্চ সীমা ২,০০০টি। নতুন ভিডিও যোগ করতে আগে একটি local candidate মুছে ফেলো।',
          'The library is at its 2,000-record limit. Remove a local candidate before adding another video.',
          'وصلت المكتبة إلى حد 2000 سجل. احذف مرشحًا محليًا قبل إضافة فيديو آخر.',
        ))),
      );
      return;
    }
    if (current.any((item) => item.videoId == result.videoId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appText('এই ভিডিওটি আগে থেকেই আছে।', 'This video is already in the library.', 'هذا الفيديو موجود بالفعل.'))),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(VideoLibraryRepository.userCandidatesKey) ?? <String>[];
    saved.add(jsonEncode(result.asPendingCandidate().toJson()));
    await prefs.setStringList(VideoLibraryRepository.userCandidatesKey, saved);
    VideoLibraryRepository.notifyCatalogChanged();
    if (!mounted) return;
    setState(() {
      _catalogFuture = _repository.load();
      _selectedReviewStatus = 'pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText('ভিডিওটি pending review-তে যোগ হয়েছে।', 'Video added as pending review.', 'تمت إضافة الفيديو للمراجعة.'))),
    );
  }

  Future<void> _removeLocalCandidate(VideoCatalogItem item) async {
    final key = item.source == 'CHANNEL_FEED'
        ? VideoLibraryRepository.feedCandidatesKey
        : VideoLibraryRepository.userCandidatesKey;
    final prefs = await SharedPreferences.getInstance();
    final remaining = <String>[];
    for (final raw in prefs.getStringList(key) ?? const <String>[]) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if ((map['video_id'] ?? '').toString() != item.videoId) remaining.add(raw);
      } catch (_) {}
    }
    await prefs.setStringList(key, remaining);
    VideoLibraryRepository.notifyCatalogChanged();
    if (mounted) setState(() => _catalogFuture = _repository.load());
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
              tooltip: appText('Channel feed refresh', 'Refresh channel feeds', 'تحديث خلاصات القنوات'),
              onPressed: _refreshingFeeds ? null : _refreshChannelFeeds,
              icon: Icon(_refreshingFeeds ? Icons.sync_rounded : Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: appText('ভিডিও যাচাই Dashboard', 'Video review dashboard', 'لوحة مراجعة الفيديو'),
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => VideoReviewDashboard(repository: _repository),
                  ),
                );
                if (mounted) setState(() => _catalogFuture = _repository.load());
              },
              icon: const Icon(Icons.fact_check_outlined),
            ),
            IconButton(
              tooltip: appText('নিজের ভিডিও যোগ', 'Add YouTube URL', 'أضف رابط YouTube'),
              onPressed: _addVideoCandidate,
              icon: const Icon(Icons.add_circle_outline_rounded),
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
                        const SizedBox(height: 10),
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
          appText('ভিডিওর ধরন', 'Video format', 'نوع الفيديو'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 7,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: Text(appText('সব ধরন', 'All formats', 'كل الأنواع')),
              selected: _selectedFormat == 'সব ধরন',
              onSelected: (_) => setState(() {
                _selectedFormat = 'সব ধরন';
                _visibleLimit = videoLibraryPageSize;
              }),
            ),
            ...videoFormats.map((format) => ChoiceChip(
              label: Text(format),
              selected: _selectedFormat == format,
              onSelected: (_) => setState(() {
                _selectedFormat = format;
                _visibleLimit = videoLibraryPageSize;
              }),
            )),
          ],
        ),
        const SizedBox(height: 10),
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
                            _selectedFormat != 'সব ধরন' ||
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
                              onTap: () => _openPlayer(item),
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
                                    if (item.isLocallyManaged)
                                      IconButton(
                                        tooltip: appText('Review queue থেকে মুছুন', 'Remove candidate', 'إزالة المرشح'),
                                        onPressed: () => _removeLocalCandidate(item),
                                        icon: const Icon(Icons.delete_outline_rounded),
                                      ),
                                    IconButton(
                                      tooltip: item.canPlayForChildren
                                          ? appText('ভিডিও চালান', 'Play video', 'تشغيل الفيديو')
                                          : appText('যাচাই ও অনুমোদন প্রয়োজন', 'Review approval required', 'مطلوب اعتماد المراجعة'),
                                      onPressed: () => _openPlayer(item),
                                      icon: Icon(
                                        item.canPlayForChildren
                                            ? Icons.play_circle_fill_rounded
                                            : Icons.lock_outline_rounded,
                                        size: item.canPlayForChildren ? 24 : 18,
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
                        'লাইব্রেরিতে 36টি configured channel/feed source, bundled records এবং নিজের যোগ করা pending candidates আছে। Feed refresh বা URL import কোনো ভিডিও approve করে না। Child playback-এর জন্য আলাদা safety, Made for Kids, embedding, rights review ও Google client setup দরকার.',
                        'Child playback requires per-video safety, Made for Kids, embedding and usage-rights checks, plus the Google child-directed client setup.',
                        'يتطلب تشغيل الأطفال فحوصات السلامة وحالة Made for Kids والتضمين وحقوق الاستخدام لكل فيديو، بالإضافة إلى إعداد عميل Google الموجّه للأطفال.',
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
