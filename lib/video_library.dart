// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'desktop_video_player.dart';

const _customKey = 'custom_learning_videos_v1';
const _remoteKey = 'remote_learning_videos_v1';

class LearningVideo {
  const LearningVideo({
    required this.id, required this.title, required this.subject,
    required this.language, required this.channel, required this.summary,
    this.format = 'শিক্ষামূলক পাঠ',
  });
  final String id, title, subject, language, channel, summary, format;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'subject': subject,
    'language': language, 'channel': channel, 'summary': summary,
    'format': format,
  };

  factory LearningVideo.fromJson(Map<String, dynamic> j) => LearningVideo(
    id: j['id']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    subject: j['subject']?.toString() ?? 'সাধারণ জ্ঞান',
    language: j['language']?.toString() ?? 'বাংলা',
    channel: j['channel']?.toString() ?? 'অভিভাবক-যোগ করা',
    summary: j['summary']?.toString() ?? '',
    format: j['format']?.toString() ?? 'শিক্ষামূলক পাঠ',
  );
}

// Starter entries are bundled examples. Feed results are imported from the listed channel sources.
const _starter = <LearningVideo>[
  LearningVideo(id: 'AwccZotbJS4', title: 'Islamic Learning for Kids in Arabic', subject: 'ইসলাম শিক্ষা', language: 'Arabic', channel: 'Kalam Kids', summary: 'শিশুদের জন্য সালাত, দান, রমজান ও হজের পরিচিতি', format: 'ইসলামিক কার্টুন'),
  LearningVideo(id: 'ASXzhX-J598', title: 'English Alphabet A to Z', subject: 'English', language: 'English', channel: 'Learn With Zakaria – English', summary: 'ইংরেজি বর্ণমালা A থেকে Z পরিচিতি'),
  LearningVideo(id: 'Pr-WLaESc18', title: 'Colors with Cars – English', subject: 'English', language: 'English', channel: 'Learn With Zakaria – English', summary: 'ইংরেজিতে রঙের নাম শেখা'),
  LearningVideo(id: 'Ktcxk4lxh3I', title: 'School Vocabulary and Dialogues', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'স্কুলের শব্দ ও ছোট কথোপকথন; ইংরেজি ও আরবি'),
  LearningVideo(id: 'z01UZ8r_ZOw', title: 'Animal World – Questions and Answers', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English', channel: 'Learn with Zakaria', summary: 'প্রাণীজগৎ সম্পর্কে শিশুদের সাধারণ জ্ঞান'),
  LearningVideo(id: '2xgyEC9WCA4', title: 'Arabic Numbers 1 to 20', subject: 'গণিত', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবিতে ১ থেকে ২০ পর্যন্ত সংখ্যা গণনা'),
  LearningVideo(id: 'zMhSljAXJjE', title: 'Learn Addition for Kids', subject: 'গণিত', language: 'English', channel: 'Learn with Zakaria', summary: 'শিশুদের জন্য প্রাথমিক যোগ শেখা'),
  LearningVideo(id: 'EiMf3iwvEkc', title: 'Read Simple Arabic Words', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সহজ আরবি শব্দ পড়ার অনুশীলন'),
  LearningVideo(id: '_BgE9-UScDs', title: 'Fruits and Vegetables in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'ফল ও সবজির আরবি নাম'),
  LearningVideo(id: 'N18JXcJr1wo', title: 'Vegetable Names in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সবজির আরবি নাম ও শব্দভান্ডার'),
  LearningVideo(id: 'NchbzH5HM0U', title: 'The Five Pillars of Islam', subject: 'ইসলাম শিক্ষা', language: 'English', channel: 'Learn with Zakaria', summary: 'ইসলামের পাঁচটি স্তম্ভ সম্পর্কে পরিচিতি'),
  LearningVideo(id: 'MPCvPqIeCCs', title: 'Surah Al-Fatiha for Children', subject: 'ইসলাম শিক্ষা', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সূরা আল-ফাতিহা শোনা ও মুখস্থের অনুশীলন'),
  LearningVideo(id: 'itFDZmIZ6pg', title: 'Learn Arabic Alphabet with Animals', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'প্রাণীর উদাহরণ দিয়ে আরবি বর্ণমালা শেখা'),
  LearningVideo(id: 'W4M4oHBGSkA', title: 'Arabic Alphabet for Children', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবি হরফ ও শব্দের পরিচিতি'),
  LearningVideo(id: 'iJm8_qxFAPA', title: 'Learn Colors in Arabic and English', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'ইংরেজি ও আরবিতে রঙের নাম শেখা'),
  LearningVideo(id: 'IB72L8OXSBs', title: 'Colors in English and Arabic', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'ইংরেজি ও আরবিতে ১১টি রঙের নাম'),
  LearningVideo(id: 'rxqzUKWYykM', title: 'Learn Colors in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবি ভাষায় বিভিন্ন রঙের নাম ও শব্দভান্ডার'),
  LearningVideo(id: '9YftisfXP70', title: 'Fruit Names in Arabic for Kids', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'শিশুদের জন্য ফলের আরবি নাম শেখা'),
];


class _VideoFeedSource {
  const _VideoFeedSource({
    required this.name,
    required this.subject,
    required this.language,
    this.channelId,
    this.legacyUser,
    this.format = 'শিক্ষামূলক পাঠ',
  }) : assert((channelId == null) != (legacyUser == null));

  final String name, subject, language, format;
  final String? channelId, legacyUser;

  Uri get feedUri => Uri.https(
    'www.youtube.com',
    '/feeds/videos.xml',
    channelId != null ? {'channel_id': channelId!} : {'user': legacyUser!},
  );
}

// Channel feeds are source discovery, not a guarantee that every upload is suitable for every child.
const _videoFeeds = <_VideoFeedSource>[
  _VideoFeedSource(name: 'Learn With Zakaria', channelId: 'UCtlcIZVBdFPSAtCoNZsTusg', subject: 'Arabic', language: 'English + Arabic'),
  _VideoFeedSource(name: 'Arabic Khatawaat', channelId: 'UCW2AgHPThj9_8raWYE2yjfw', subject: 'Arabic', language: 'Arabic'),
  _VideoFeedSource(name: 'Alif Baa Taa Kids', channelId: 'UCQPYspoIhOtBS58s6QxjKMQ', subject: 'Arabic', language: 'Arabic', format: 'ইসলামিক কার্টুন'),
  _VideoFeedSource(name: 'Kalam Kids', channelId: 'UCdr_45nR1o2P4ycckLh1xOQ', subject: 'ইসলাম শিক্ষা', language: 'English + Arabic', format: 'ইসলামিক কার্টুন'),
  _VideoFeedSource(name: 'Arabic for the World for Kids', channelId: 'UCUv6vbrigNkwpybcjvOA5Mg', subject: 'Arabic', language: 'Arabic', format: 'শিক্ষামূলক পাঠ'),
  _VideoFeedSource(name: 'One4Kids / Zaky', format: 'ইসলামিক কার্টুন', channelId: 'UC5vfWTTPnKdFp-8s0KbqJhw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Omar & Hana', format: 'ইসলামিক কার্টুন', channelId: 'UC178EmfQAV3OT-UpuO6WUMg', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Muslim Reminder Kids', channelId: 'UCUUQonfh_yNkI6h0O2a6nRA', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'IQRA Cartoon', format: 'ইসলামিক কার্টুন', channelId: 'UCSL4Dn-FQlvHZiSKipQZMqw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'DUA KIDS', format: 'ইসলামিক কার্টুন', channelId: 'UCRb4jRq4VZWPNNUCE-_Ydaw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Ousratouna', format: 'কার্টুন', channelId: 'UCWIdqSQekeGmUWlSFeCiEnA', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Abata', format: 'কার্টুন', channelId: 'UCxHAohzMS4a2alUmWZeyZuw', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Free Quran Education', legacyUser: 'NAKcollection', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Muslim Kids TV', legacyUser: 'miloproductionsinc', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Discover Islam UK', legacyUser: 'DiscoverIslamUK', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Noor Kids', legacyUser: 'NoorKids', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Zulfy World', format: 'ইসলামিক গল্প', channelId: 'UCRNQLb5rFcMX5o1RMZE9LCg', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'SciShow Kids', legacyUser: 'scishowkids', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'KidsEduc', channelId: 'UCFCbjNyMJqEWKQEhFwfUjkA', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Homeschool Pop', channelId: 'UCfPyVJEBD7Di1YYjTdS2v8g', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Math & Learning Videos 4 Kids', channelId: 'UCZXWbHkJAHqy6fGYPNsnqzw', subject: 'গণিত', language: 'English'),
  _VideoFeedSource(name: 'Wizz Learning', channelId: 'UCG9banTw-zsDXFrNdDQfg6Q', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Kids Learning Videos', legacyUser: 'Kidslearningvideo', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Preschool Prep Company', legacyUser: 'PreschoolPrep', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Burka Avenger', format: 'ইসলামিক কার্টুন', channelId: 'UCOkkZbztV5LM4-VMNjbg5JQ', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: '5-Minute Crafts KIDS', channelId: 'UC57XAjJ04TY8gNxOWf-Sy0Q', subject: 'শিল্প ও সৃজনশীলতা', language: 'English'),
  _VideoFeedSource(name: 'Curious George Official', format: 'কার্টুন', channelId: 'UCu7IDy0y-ZA0qaG51wrQY6w', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Octonauts', format: 'কার্টুন', channelId: 'UCXLLQkbYE-G9jYrra7R4Qsw', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'Wizz Cartoons', format: 'কার্টুন', channelId: 'UCN3j3Equ2SHwJhLPERmQquw', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Wizz Explore', channelId: 'UCpetG1dVOjzFF3pcqA18YIQ', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'Wizz Friends', format: 'কার্টুন', channelId: 'UCkHrTT9PChTkFH_qUtoo2lw', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Kids Star TV', format: 'কার্টুন', channelId: 'UCmxi_8fP1jVKSBMU4VgwkUg', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Reqaman', channelId: 'UCP2t9ae-Veze7Nofsg-fubQ', subject: 'Arabic', language: 'Arabic'),
  _VideoFeedSource(name: 'YouQaria Kids', channelId: 'UCwiIpiPPMB17SigZ4n3jpmA', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Islam Channel Kids', legacyUser: 'ickidsonline', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Mountain of Light', legacyUser: 'supportpeace', subject: 'ইসলাম শিক্ষা', language: 'English'),
];

const _subjects = <String>['সব বিষয়','English','Arabic','বাংলা','গণিত','বিজ্ঞান ও প্রকৃতি','ইসলাম শিক্ষা','ইতিহাস','ভূগোল','কম্পিউটার','শিল্প ও সৃজনশীলতা','স্বাস্থ্য ও জীবনদক্ষতা','সাধারণ জ্ঞান'];
const _languages = <String>['সব ভাষা','English','Arabic','বাংলা'];
const _formats = <String>['সব ধরন','ইসলামিক কার্টুন','কার্টুন','ইসলামিক গল্প','শিক্ষামূলক পাঠ'];

String? _videoId(String input) {
  final value = input.trim();
  final match = RegExp(r'(?:youtu\.be/|[?&]v=|/embed/|/shorts/)([A-Za-z0-9_-]{11})').firstMatch(value);
  if (match != null) return match.group(1);
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value) ? value : null;
}


/// Number of video entries the library is designed to collect.
const int videoLibraryTarget = 500;

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  List<LearningVideo> _custom = [];
  List<LearningVideo> _remote = [];
  bool _refreshing = false;
  bool _loading = true;
  String _subject = 'সব বিষয়';
  String _language = 'সব ভাষা';
  String _format = 'সব ধরন';
  String _query = '';
  int _displayLimit = 30;
  final TextEditingController _searchController = TextEditingController();

  List<LearningVideo> get _all {
    final unique = <String, LearningVideo>{};
    for (final item in [..._starter, ..._remote, ..._custom]) {
      unique[item.id] = item;
    }
    return unique.values.toList();
  }

  List<LearningVideo> get _visible => _all.where((item) {
    if (_subject != 'সব বিষয়' && item.subject != _subject) return false;
    if (_language != 'সব ভাষা' &&
        !item.language.toLowerCase().contains(_language.toLowerCase())) {
      return false;
    }
    if (_format != 'সব ধরন' && item.format != _format) return false;
    if (_query.isNotEmpty) {
      final haystack = [
        item.title,
        item.subject,
        item.language,
        item.channel,
        item.summary,
        item.format,
      ].join(' ').toLowerCase();
      if (!haystack.contains(_query)) return false;
    }
    return true;
  }).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = <LearningVideo>[];
      for (final raw in prefs.getStringList(_customKey) ?? <String>[]) {
        try {
          final item = LearningVideo.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (item.id.isNotEmpty && !_starter.any((x) => x.id == item.id)) {
            custom.add(item);
          }
        } catch (_) {
          // Ignore malformed local records.
        }
      }

      final remote = <LearningVideo>[];
      for (final raw in prefs.getStringList(_remoteKey) ?? <String>[]) {
        try {
          final item = LearningVideo.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (item.id.isNotEmpty &&
              !_starter.any((x) => x.id == item.id) &&
              !custom.any((x) => x.id == item.id)) {
            remote.add(item);
          }
        } catch (_) {
          // Ignore malformed cached feed entries.
        }
      }

      if (!mounted) return;
      setState(() {
        _custom = custom;
        _remote = remote;
        _loading = false;
      });
      unawaited(_refreshRemoteCatalog());
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshRemoteCatalog({bool showMessage = false}) async {
    if (_refreshing || kIsWeb) {
      if (kIsWeb && showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Web preview-তে YouTube feed-এর CORS সীমাবদ্ধতা থাকতে পারে। Android/iOS/macOS-এ refresh করুন।',
            ),
          ),
        );
      }
      return;
    }

    if (mounted) setState(() => _refreshing = true);

    final discovered = <LearningVideo>[];
    final seen = <String>{
      ..._starter.map((item) => item.id),
      ..._remote.map((item) => item.id),
      ..._custom.map((item) => item.id),
    };

    String childText(xml.XmlElement parent, String localName) {
      for (final element in parent.descendants.whereType<xml.XmlElement>()) {
        if (element.name.local == localName) return element.innerText.trim();
      }
      return '';
    }

    try {
      const batchSize = 8;
      for (var offset = 0; offset < _videoFeeds.length; offset += batchSize) {
        final batch = _videoFeeds.skip(offset).take(batchSize);
        final results = await Future.wait(batch.map((source) async {
          try {
            final response = await http.get(
              source.feedUri,
              headers: const {
                'Accept': 'application/atom+xml, application/xml, text/xml',
              },
            ).timeout(const Duration(seconds: 12));
            if (response.statusCode != 200) return <LearningVideo>[];

            final document = xml.XmlDocument.parse(response.body);
            final entries = document.descendants
                .whereType<xml.XmlElement>()
                .where((node) => node.name.local == 'entry');
            final items = <LearningVideo>[];

            // The public YouTube Atom feed normally exposes up to 15 recent uploads.
            for (final entry in entries.take(15)) {
              final id = childText(entry, 'videoId');
              final title = childText(entry, 'title')
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim();
              final lower = title.toLowerCase();
              if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id) ||
                  title.isEmpty ||
                  lower.contains('#shorts') ||
                  lower.contains('shorts video')) {
                continue;
              }

              items.add(
                LearningVideo(
                  id: id,
                  title: title,
                  subject: source.subject,
                  language: source.language,
                  channel: source.name,
                  format: source.format,
                  summary: 'নির্দিষ্ট channel feed থেকে সংগৃহীত ভিডিও।',
                ),
              );
            }
            return items;
          } catch (_) {
            return <LearningVideo>[];
          }
        }));

        for (final group in results) {
          for (final item in group) {
            if (seen.add(item.id)) discovered.add(item);
          }
        }
      }
    } catch (_) {
      // Keep the last saved catalogue when network access fails.
    }

    if (!mounted) return;

    if (discovered.isNotEmpty) {
      final merged = <String, LearningVideo>{
        for (final item in _remote) item.id: item,
        for (final item in discovered) item.id: item,
      };
      setState(() {
        _remote = merged.values.toList();
        _refreshing = false;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _remoteKey,
          _remote.map((item) => jsonEncode(item.toJson())).toList(),
        );
      } catch (_) {
        // The in-memory catalogue remains usable for this session.
      }
    } else {
      setState(() => _refreshing = false);
    }

    if (showMessage && mounted) {
      final count = _all.length;
      final message = discovered.isEmpty
          ? 'নতুন feed ভিডিও পাওয়া যায়নি। আগের সংরক্ষিত তালিকা রাখা হয়েছে।'
          : discovered.length.toString() +
              'টি নতুন ভিডিও যোগ হয়েছে। বর্তমানে মোট ' +
              count.toString() +
              'টি পাওয়া গেছে।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _saveCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _customKey,
      _custom.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> _addVideo() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String subject = 'English';
    String language = 'English';
    String format = 'শিক্ষামূলক পাঠ';

    final result = await showDialog<LearningVideo>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refresh) => AlertDialog(
          title: const Text('নতুন শেখার ভিডিও যোগ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'ভিডিওর নাম'),
                ),
                TextField(
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'YouTube URL বা Video ID',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: language,
                  decoration: const InputDecoration(labelText: 'ভিডিওর ভাষা'),
                  items: _languages
                      .where((item) => item != 'সব ভাষা')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) refresh(() => language = value);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: subject,
                  decoration: const InputDecoration(labelText: 'বিষয়'),
                  items: _subjects
                      .where((item) => item != 'সব বিষয়')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) refresh(() => subject = value);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: format,
                  decoration: const InputDecoration(labelText: 'ধরন'),
                  items: _formats
                      .where((item) => item != 'সব ধরন')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) refresh(() => format = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('বাতিল'),
            ),
            FilledButton(
              onPressed: () {
                final id = _videoId(urlController.text);
                if (titleController.text.trim().isEmpty || id == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('সঠিক নাম ও বৈধ YouTube URL দিন।'),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  LearningVideo(
                    id: id,
                    title: titleController.text.trim(),
                    subject: subject,
                    language: language,
                    channel: 'নিজে যোগ করা ভিডিও',
                    summary: 'নিজে যোগ করা ভিডিও।',
                    format: format,
                  ),
                );
              },
              child: const Text('ভিডিও যোগ করো'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    urlController.dispose();

    if (result == null || !mounted) return;
    if (_all.any((item) => item.id == result.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই ভিডিওটি আগেই আছে।')),
      );
      return;
    }

    setState(() => _custom.add(result));
    await _saveCustom();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ভিডিওটি লাইব্রেরিতে যোগ হয়েছে।')),
    );
  }

  Future<void> _openVideo(LearningVideo video) async {
    if (hasDesktopVideoPlayer) {
      try {
        await openDesktopVideoPlayer(videoId: video.id, title: video.title);
      } catch (error) {
        if (!mounted) return;
        final details = error.toString();
        final message = details.contains('WEBVIEW2_RUNTIME_MISSING')
            ? 'এই Windows ডিভাইসে Microsoft Edge WebView2 Runtime পাওয়া যায়নি। Runtime ইনস্টল করে আবার চেষ্টা করুন।'
            : 'ভিডিও player চালু করা যায়নি। Windows-এ WebView2 Runtime এবং Linux-এ WebKitGTK 4.1 ও libsoup 3 প্রয়োজন হতে পারে।';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _LearningVideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    final visible = _visible;
    final progress =
        (all.length / videoLibraryTarget).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ভিডিও শেখার জগৎ'),
        actions: [
          IconButton(
            tooltip: 'ভিডিও তালিকা refresh',
            onPressed: _refreshing
                ? null
                : () => _refreshRemoteCatalog(showMessage: true),
            icon: Icon(_refreshing ? Icons.sync : Icons.refresh),
          ),
          IconButton(
            tooltip: 'নিজের ভিডিও যোগ',
            onPressed: _addVideo,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 26),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF075E3B), Color(0xFF179B70)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.video_library_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '৫০০+ শেখার ভিডিও সংগ্রহ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        all.length.toString() +
                            'টি ভিডিওর তথ্য পাওয়া গেছে • লক্ষ্য ' +
                            videoLibraryTarget.toString() +
                            '+',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white24,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'English • Arabic • ইসলাম শিক্ষা • গণিত • বিজ্ঞান • কার্টুন',
                        style: TextStyle(color: Colors.white, height: 1.4),
                      ),
                      if (_refreshing)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ভিডিওর নাম ও channel feed থেকে সংগ্রহ করা হয়; অ্যাপ প্রতিটি ভিডিওর দৃশ্য, শব্দ, বিজ্ঞাপন বা ধর্মীয় বিষয়বস্তু স্বয়ংক্রিয়ভাবে যাচাই করতে পারে না। YouTube বিজ্ঞাপন বা বাইরের overlay দেখাতে পারে।',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value.trim().toLowerCase();
                    _displayLimit = 30;
                  }),
                  decoration: InputDecoration(
                    hintText: 'ভিডিও, বিষয় বা channel খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'সার্চ মুছুন',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _displayLimit = 30;
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ভিডিওর ধরন',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  children: _formats
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: _format == item,
                          onSelected: (_) => setState(() {
                            _format = item;
                            _displayLimit = 30;
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ভাষা',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Wrap(
                  spacing: 7,
                  children: _languages
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: _language == item,
                          onSelected: (_) => setState(() {
                            _language = item;
                            _displayLimit = 30;
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'বিষয়',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  children: _subjects
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: _subject == item,
                          onSelected: (_) => setState(() {
                            _subject = item;
                            _displayLimit = 30;
                          }),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ভিডিও লাইব্রেরি',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      visible.length.toString() + 'টি পাওয়া গেছে',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (visible.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.video_library_outlined,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'এই ফিল্টারে এখনো কোনো ভিডিও নেই।',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _subject = 'সব বিষয়';
                                _language = 'সব ভাষা';
                                _format = 'সব ধরন';
                                _query = '';
                                _searchController.clear();
                                _displayLimit = 30;
                              });
                            },
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('সব ফিল্টার সরাও'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...visible.take(_displayLimit).map(
                  (item) => _VideoCard(
                    video: item,
onOpen: () => _openVideo(item),
                  ),
                ),
                if (visible.length > _displayLimit)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _displayLimit += 30),
                      icon: const Icon(Icons.expand_more),
                      label: Text(
                        'আরও ৩০টি ভিডিও দেখুন (' +
                            (visible.length - _displayLimit).toString() +
                            'টি বাকি)',
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  _videoFeeds.length.toString() +
                      'টি নির্দিষ্ট channel/feed থেকে সর্বশেষ ভিডিও আনা হয়; প্রতিটি feed থেকে সর্বোচ্চ ১৫টি এন্ট্রি নেওয়া হয়। Feed ব্যর্থ হলে বা channel-এ কম ভিডিও থাকলে প্রকৃত মোট সংখ্যা ৫০০-এর কম হতে পারে।',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
required this.onOpen,
  });

  final LearningVideo video;
final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/' + video.id + '/hqdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.video_library_outlined,
                      size: 44,
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.black.withValues(alpha: 0.72),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  left: 9,
                  top: 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        video.format,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  video.subject + ' • ' + video.language,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(video.summary),
                const SizedBox(height: 4),
                Text(
                  'উৎস: ' + video.channel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('ভিডিও দেখো'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningVideoPlayerScreen extends StatefulWidget {
  const _LearningVideoPlayerScreen({required this.video});

  final LearningVideo video;

  @override
  State<_LearningVideoPlayerScreen> createState() =>
      _LearningVideoPlayerScreenState();
}

class _LearningVideoPlayerScreenState
    extends State<_LearningVideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        privacyEnhancedMode: true,
        strictRelatedVideos: true,
        enableCaption: true,
        captionLanguage: 'en',
        interfaceLanguage: 'en',
        playsInline: true,
      ),
    );
    _subscription = _controller.listen((value) {
      if (value.playerState == PlayerState.ended && mounted && !_ended) {
        setState(() => _ended = true);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.video.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _ended
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 54,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'ভিডিও শেষ হয়েছে',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    )
                  : YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    ),
            ),
            const SizedBox(height: 12),
            if (!_ended)
              YoutubeValueBuilder(
                controller: _controller,
                builder: (context, value) {
                  final playing = value.playerState == PlayerState.playing;
                  return FilledButton.icon(
                    onPressed: value.playerState != PlayerState.unknown
                        ? () {
                            if (playing) {
                              _controller.pauseVideo();
                            } else {
                              _controller.playVideo();
                            }
                          }
                        : null,
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    label: Text(playing ? 'বিরতি' : 'ভিডিও চালু করো'),
                  );
                },
              )
            else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'ভিডিও শেষ হয়েছে। পরের ভিডিওটি নিজে বেছে নাও।',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('সম্পন্ন'),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              widget.video.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'বিষয়: ' +
                  widget.video.subject +
                  ' • ভাষা: ' +
                  widget.video.language,
            ),
            const SizedBox(height: 10),
            const Text(
              'এই player সাধারণ YouTube search/feed দেখায় না এবং নিজে থেকে পরের ভিডিও চালায় না। YouTube-এর বিজ্ঞাপন বা platform overlay অ্যাপ সম্পূর্ণ নিয়ন্ত্রণ করতে পারে না।',
              style: TextStyle(fontSize: 12, height: 1.45),
            ),
          ],
        ),
      );
}
