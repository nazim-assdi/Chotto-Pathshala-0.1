import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

const _approvedKey = 'approved_learning_video_ids_v1';
const _customKey = 'custom_learning_videos_v1';
const _remoteKey = 'remote_learning_videos_v1';

class LearningVideo {
  const LearningVideo({
    required this.id, required this.title, required this.subject,
    required this.language, required this.channel, required this.summary,
  });
  final String id, title, subject, language, channel, summary;

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'subject': subject,
    'language': language, 'channel': channel, 'summary': summary,
  };

  factory LearningVideo.fromJson(Map<String, dynamic> j) => LearningVideo(
    id: j['id']?.toString() ?? '',
    title: j['title']?.toString() ?? '',
    subject: j['subject']?.toString() ?? 'সাধারণ জ্ঞান',
    language: j['language']?.toString() ?? 'বাংলা',
    channel: j['channel']?.toString() ?? 'অভিভাবক-যোগ করা',
    summary: j['summary']?.toString() ?? '',
  );
}

// Curated starter candidates. None is visible in child mode until a parent
// watches it through to the end and approves it on this device.
const _starter = <LearningVideo>[
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
  }) : assert((channelId == null) != (legacyUser == null));

  final String name, subject, language;
  final String? channelId, legacyUser;

  Uri get feedUri => Uri.https(
    'www.youtube.com',
    '/feeds/videos.xml',
    channelId != null ? {'channel_id': channelId!} : {'user': legacyUser!},
  );
}

// Discovery sources only. Individual uploads remain pending until a parent
// watches the whole video and checks suitability for the child.
const _videoFeeds = <_VideoFeedSource>[
  _VideoFeedSource(name: 'Learn With Zakaria', channelId: 'UCtlcIZVBdFPSAtCoNZsTusg', subject: 'Arabic', language: 'English + Arabic'),
  _VideoFeedSource(name: 'Arabic Khatawaat', channelId: 'UCW2AgHPThj9_8raWYE2yjfw', subject: 'Arabic', language: 'Arabic'),
  _VideoFeedSource(name: 'Alif Baa Taa Kids', legacyUser: 'alifbaataakids', subject: 'Arabic', language: 'Arabic'),
  _VideoFeedSource(name: 'One4Kids / Zaky', channelId: 'UC5vfWTTPnKdFp-8s0KbqJhw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Omar & Hana', channelId: 'UC178EmfQAV3OT-UpuO6WUMg', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Muslim Reminder Kids', channelId: 'UCUUQonfh_yNkI6h0O2a6nRA', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'IQRA Cartoon', channelId: 'UCSL4Dn-FQlvHZiSKipQZMqw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'DUA KIDS', channelId: 'UCRb4jRq4VZWPNNUCE-_Ydaw', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Ousratouna', channelId: 'UCWIdqSQekeGmUWlSFeCiEnA', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Abata', channelId: 'UCxHAohzMS4a2alUmWZeyZuw', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Free Quran Education', legacyUser: 'NAKcollection', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Muslim Kids TV', legacyUser: 'miloproductionsinc', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Discover Islam UK', legacyUser: 'DiscoverIslamUK', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Noor Kids', legacyUser: 'NoorKids', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Zulfy World', channelId: 'UCRNQLb5rFcMX5o1RMZE9LCg', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'SciShow Kids', legacyUser: 'scishowkids', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'KidsEduc', channelId: 'UCFCbjNyMJqEWKQEhFwfUjkA', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Homeschool Pop', channelId: 'UCfPyVJEBD7Di1YYjTdS2v8g', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Math & Learning Videos 4 Kids', channelId: 'UCZXWbHkJAHqy6fGYPNsnqzw', subject: 'গণিত', language: 'English'),
  _VideoFeedSource(name: 'Wizz Learning', channelId: 'UCG9banTw-zsDXFrNdDQfg6Q', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Kids Learning Videos', legacyUser: 'Kidslearningvideo', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Preschool Prep Company', legacyUser: 'PreschoolPrep', subject: 'English', language: 'English'),
  _VideoFeedSource(name: 'Burka Avenger', channelId: 'UCOkkZbztV5LM4-VMNjbg5JQ', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: '5-Minute Crafts KIDS', channelId: 'UC57XAjJ04TY8gNxOWf-Sy0Q', subject: 'শিল্প ও সৃজনশীলতা', language: 'English'),
  _VideoFeedSource(name: 'Curious George Official', channelId: 'UCu7IDy0y-ZA0qaG51wrQY6w', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Octonauts', channelId: 'UCXLLQkbYE-G9jYrra7R4Qsw', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'Wizz Cartoons', channelId: 'UCN3j3Equ2SHwJhLPERmQquw', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Wizz Explore', channelId: 'UCpetG1dVOjzFF3pcqA18YIQ', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English'),
  _VideoFeedSource(name: 'Wizz Friends', channelId: 'UCkHrTT9PChTkFH_qUtoo2lw', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Kids Star TV', channelId: 'UCmxi_8fP1jVKSBMU4VgwkUg', subject: 'সাধারণ জ্ঞান', language: 'English'),
  _VideoFeedSource(name: 'Reqaman', channelId: 'UCP2t9ae-Veze7Nofsg-fubQ', subject: 'Arabic', language: 'Arabic'),
  _VideoFeedSource(name: 'YouQaria Kids', channelId: 'UCwiIpiPPMB17SigZ4n3jpmA', subject: 'ইসলাম শিক্ষা', language: 'Arabic'),
  _VideoFeedSource(name: 'Islam Channel Kids', legacyUser: 'ickidsonline', subject: 'ইসলাম শিক্ষা', language: 'English'),
  _VideoFeedSource(name: 'Mountain of Light', legacyUser: 'supportpeace', subject: 'ইসলাম শিক্ষা', language: 'English'),
];

const _subjects = <String>['সব বিষয়','English','Arabic','বাংলা','গণিত','বিজ্ঞান ও প্রকৃতি','ইসলাম শিক্ষা','ইতিহাস','ভূগোল','কম্পিউটার','শিল্প ও সৃজনশীলতা','স্বাস্থ্য ও জীবনদক্ষতা','সাধারণ জ্ঞান'];
const _languages = <String>['সব ভাষা','English','Arabic','বাংলা'];

bool get _hasInlinePlayer => kIsWeb || {
  TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS,
}.contains(defaultTargetPlatform);

String? _videoId(String input) {
  final value = input.trim();
  final match = RegExp(r'(?:youtu\.be/|[?&]v=|/embed/|/shorts/)([A-Za-z0-9_-]{11})').firstMatch(value);
  if (match != null) return match.group(1);
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value) ? value : null;
}

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});
  @override State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  List<LearningVideo> _custom = [];
  List<LearningVideo> _remote = [];
  bool _refreshing = false;
  Set<String> _approved = {};
  final Set<String> _reviewed = {};
  bool _loading = true, _parentMode = false;
  String _subject = 'সব বিষয়', _language = 'সব ভাষা';

  List<LearningVideo> get _all => [..._starter, ..._remote, ..._custom];
  List<LearningVideo> get _visible => _all.where((v) {
    if (!_parentMode && !_approved.contains(v.id)) return false;
    if (_subject != 'সব বিষয়' && v.subject != _subject) return false;
    if (_language != 'সব ভাষা' && !v.language.toLowerCase().contains(_language.toLowerCase())) return false;
    return true;
  }).toList();

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final custom = <LearningVideo>[];
      for (final raw in p.getStringList(_customKey) ?? <String>[]) {
        try {
          final v = LearningVideo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          if (v.id.isNotEmpty && !_starter.any((s) => s.id == v.id)) custom.add(v);
        } catch (_) {}
      }
      final remote = <LearningVideo>[];
      for (final raw in p.getStringList(_remoteKey) ?? <String>[]) {
        try {
          final v = LearningVideo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          if (v.id.isNotEmpty &&
              !_starter.any((s) => s.id == v.id) &&
              !custom.any((s) => s.id == v.id)) {
            remote.add(v);
          }
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _custom = custom;
        _remote = remote;
        _approved = (p.getStringList(_approvedKey) ?? <String>[]).toSet();
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Web preview-তে YouTube feed CORS সীমাবদ্ধতার কারণে refresh করা যায় না; Android/iOS-এ চেষ্টা করুন।'),
        ));
      }
      return;
    }
    if (mounted) {
      setState(() => _refreshing = true);
    }
    final discovered = <LearningVideo>[];
    final seen = <String>{
      ..._starter.map((v) => v.id),
      ..._remote.map((v) => v.id),
      ..._custom.map((v) => v.id),
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
            final response = await http.get(source.feedUri, headers: const {
              'Accept': 'application/atom+xml, application/xml, text/xml',
            }).timeout(const Duration(seconds: 10));
            if (response.statusCode != 200) return <LearningVideo>[];
            final document = xml.XmlDocument.parse(response.body);
            final entries = document.descendants.whereType<xml.XmlElement>()
                .where((node) => node.name.local == 'entry');
            final items = <LearningVideo>[];
            for (final entry in entries.take(15)) {
              final id = childText(entry, 'videoId');
              final title = childText(entry, 'title').replaceAll(RegExp(r'\s+'), ' ').trim();
              final lower = title.toLowerCase();
              if (!RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id) ||
                  title.isEmpty ||
                  lower.contains('#shorts') ||
                  lower.contains('shorts video')) {
                continue;
              }
              items.add(LearningVideo(
                id: id,
                title: title,
                subject: source.subject,
                language: source.language,
                channel: source.name,
                summary: 'অনলাইন feed থেকে পাওয়া ভিডিও প্রার্থী। শিশুদের দেখানোর আগে অভিভাবকের পূর্ণ preview ও অনুমোদন প্রয়োজন।',
              ));
            }
            return items;
          } catch (_) {
            return <LearningVideo>[];
          }
        }));
        for (final group in results) {
          for (final video in group) {
            if (seen.add(video.id)) discovered.add(video);
          }
        }
      }
    } catch (_) {
      // Keep the last saved catalogue if network access fails.
    }

    if (!mounted) return;
    if (discovered.isNotEmpty) {
      final merged = <String, LearningVideo>{
        for (final video in _remote) video.id: video,
        for (final video in discovered) video.id: video,
      };
      setState(() {
        _remote = merged.values.toList();
        _refreshing = false;
        _reviewed.clear();
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _remoteKey,
          _remote.map((video) => jsonEncode(video.toJson())).toList(),
        );
      } catch (_) {}
    } else {
      setState(() => _refreshing = false);
    }

    if (showMessage && mounted) {
      final count = _starter.length + _remote.length + _custom.length;
      final message = discovered.isEmpty
          ? 'নতুন ভিডিও পাওয়া যায়নি; আগের সংরক্ষিত তালিকা রাখা হয়েছে।'
          : 'নতুন ${discovered.length}টি ভিডিও প্রার্থী যোগ হয়েছে। মোট $countটি। সবগুলো অভিভাবক যাচাইয়ের অপেক্ষায়।';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _saveCustom() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_customKey, _custom.map((v) => jsonEncode(v.toJson())).toList());
  }

  Future<void> _saveApproved() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_approvedKey, _approved.toList()..sort());
  }

  Future<bool> _parentCheck() async {
    final a = 12 + Random().nextInt(8), b = 7 + Random().nextInt(6);
    final input = TextEditingController();
    final result = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.family_restroom, size: 38),
        title: const Text('অভিভাবক যাচাই'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ভিডিও যোগ বা অনুমোদন করতে অভিভাবকের উত্তর প্রয়োজন।'),
          const SizedBox(height: 14),
          Text('$a × $b = কত?', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          TextField(controller: input, autofocus: true, keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'উত্তর লিখুন')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('বাতিল')),
          FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(input.text.trim()) == a * b), child: const Text('যাচাই')),
        ],
      ),
    );
    input.dispose();
    if (result != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অভিভাবক যাচাই সম্পন্ন হয়নি।')));
    }
    return result == true;
  }

  Future<void> _toggleParent() async {
    if (_parentMode) {
      setState(() { _parentMode = false; _subject = 'সব বিষয়'; _language = 'সব ভাষা'; });
    } else if (await _parentCheck() && mounted) {
      setState(() { _parentMode = true; _subject = 'সব বিষয়'; _language = 'সব ভাষা'; });
    }
  }

  Future<void> _addVideo() async {
    final title = TextEditingController(), url = TextEditingController();
    String subject = 'English', language = 'English';
    final result = await showDialog<LearningVideo>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
        title: const Text('নতুন শিক্ষামূলক ভিডিও যোগ'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, maxLength: 80, decoration: const InputDecoration(labelText: 'ভিডিওর নাম')),
          TextField(controller: url, keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'YouTube URL বা Video ID')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: language, decoration: const InputDecoration(labelText: 'ভিডিওর ভাষা'),
            items: _languages.where((x) => x != 'সব ভাষা').map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) { if (x != null) refresh(() => language = x); },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: subject, decoration: const InputDecoration(labelText: 'বিষয়'),
            items: _subjects.where((x) => x != 'সব বিষয়').map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (x) { if (x != null) refresh(() => subject = x); },
          ),
          const SizedBox(height: 10),
          const Text('নতুন ভিডিও স্বয়ংক্রিয়ভাবে শিশুদের তালিকায় আসবে না; আগে অভিভাবককে preview করে অনুমোদন করতে হবে।', style: TextStyle(fontSize: 12)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          FilledButton(onPressed: () {
            final id = _videoId(url.text);
            if (title.text.trim().isEmpty || id == null) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('সঠিক নাম ও বৈধ YouTube URL দিন।')));
              return;
            }
            Navigator.pop(ctx, LearningVideo(id: id, title: title.text.trim(), subject: subject, language: language,
              channel: 'অভিভাবক-যোগ করা উৎস', summary: 'অভিভাবকের দেওয়া ভিডিও; অনুমোদনের অপেক্ষায়'));
          }, child: const Text('যোগ করুন')),
        ],
      )),
    );
    title.dispose(); url.dispose();
    if (result == null || !mounted) return;
    if (_all.any((v) => v.id == result.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এই ভিডিওটি আগে থেকেই তালিকায় আছে।')));
      return;
    }
    setState(() => _custom.add(result));
    await _saveCustom();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ভিডিওটি যাচাই তালিকায় যোগ হয়েছে; শিশুদের জন্য এখনো অনুমোদিত নয়।')));
  }

  Future<void> _openVideo(LearningVideo video) async {
    if (!_hasInlinePlayer) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('নিরাপদ in-app player এই প্ল্যাটফর্মে নেই। Android, iOS, macOS বা Web সংস্করণে preview করুন।'),
      ));
      return;
    }
    final complete = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => _LearningVideoPlayerScreen(video: video, reviewMode: _parentMode),
    ));
    if (_parentMode && complete == true && mounted) {
      setState(() => _reviewed.add(video.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পুরো ভিডিও দেখা হয়েছে। এখন অনুমোদন করতে পারবেন।')));
    }
  }

  Future<bool> _confirmIslamicReview(LearningVideo video) async {
    var ageAppropriate = false;
    var noUnsuitableContent = false;
    var noMusic = false;
    var valuesAndAccuracy = false;
    var educational = false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refresh) => AlertDialog(
          title: const Text('ইসলামিক ও শিশু-নিরাপত্তা যাচাই'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('পুরো ভিডিওটি দেখে প্রতিটি শর্ত নিশ্চিত করুন। সবগুলো না মিললে অনুমোদন করবেন না।'),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: ageAppropriate,
                  onChanged: (v) => refresh(() => ageAppropriate = v ?? false),
                  title: const Text('এই বয়সের শিশুর জন্য উপযুক্ত'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: noUnsuitableContent,
                  onChanged: (v) => refresh(() => noUnsuitableContent = v ?? false),
                  title: const Text('অশালীন দৃশ্য, ভাষা বা সহিংসতা নেই'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: noMusic,
                  onChanged: (v) => refresh(() => noMusic = v ?? false),
                  title: const Text('বাদ্যযন্ত্র বা বাদ্যযন্ত্রসহ গান নেই'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: valuesAndAccuracy,
                  onChanged: (v) => refresh(() => valuesAndAccuracy = v ?? false),
                  title: const Text('ইসলামি মূল্যবোধের বিরোধী বা ভুল ধর্মীয় তথ্য নেই'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: educational,
                  onChanged: (v) => refresh(() => educational = v ?? false),
                  title: const Text('শিক্ষামূলক তথ্য সঠিক এবং নির্ভরযোগ্য'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('অনুমোদন নয়'),
            ),
            FilledButton(
              onPressed: ageAppropriate && noUnsuitableContent && noMusic && valuesAndAccuracy && educational
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: const Text('সব শর্ত মেনে অনুমোদন'),
            ),
          ],
        ),
      ),
    );
    return accepted == true;
  }

  Future<void> _approve(LearningVideo video) async {
    if (!_reviewed.contains(video.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আগে পুরো ভিডিও preview করুন।')));
      return;
    }
    final approved = await _confirmIslamicReview(video);
    if (!mounted || approved != true) return;
    setState(() => _approved.add(video.id));
    await _saveApproved();
  }

  Future<void> _revoke(LearningVideo video) async {
    setState(() => _approved.remove(video.id));
    await _saveApproved();
  }

  @override Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ইসলামিক-ফিল্টার করা ভিডিও'),
        actions: [
          IconButton(tooltip: 'ভিডিও তালিকা refresh', onPressed: _refreshing ? null : () => _refreshRemoteCatalog(showMessage: true), icon: Icon(_refreshing ? Icons.sync : Icons.refresh)),
          IconButton(tooltip: _parentMode ? 'শিশু মোড' : 'অভিভাবক মোড', onPressed: _toggleParent,
            icon: Icon(_parentMode ? Icons.child_care : Icons.admin_panel_settings_outlined)),
          if (_parentMode) IconButton(tooltip: 'নতুন ভিডিও যোগ', onPressed: _addVideo, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF075E3B), Color(0xFF159B65)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.verified_user_outlined, color: Colors.white, size: 28),
                SizedBox(width: 9),
                Expanded(child: Text('শুধু অভিভাবক-অনুমোদিত পাঠ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
              ]),
              const SizedBox(height: 8),
              Text(_parentMode
                  ? 'অভিভাবক মোড: ভিডিও পুরোটা দেখে তারপর শিশুদের জন্য অনুমোদন করুন।'
                  : 'শিশু মোড: কেবল অভিভাবকের অনুমোদিত ভিডিও দেখানো হচ্ছে।',
                style: const TextStyle(color: Colors.white, height: 1.45)),
              const SizedBox(height: 10),
              Text('অনুমোদিত ভিডিও: ${_approved.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('মোট ভিডিও প্রার্থী: ${_starter.length + _remote.length + _custom.length}টি • উৎস: ${_videoFeeds.length}টি', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              if (_refreshing) const Padding(padding: EdgeInsets.only(top: 7), child: LinearProgressIndicator()),
            ]),
          ),
          if (_parentMode) const Card(child: Padding(padding: EdgeInsets.all(13), child: Text(
            'YouTube নিজস্ব বিজ্ঞাপন বা player overlay দেখাতে পারে—অ্যাপ সেগুলো পুরোপুরি নিয়ন্ত্রণ করতে পারে না। তাই অনুমোদনের আগে পুরো ভিডিও দেখে নিন। এখানে সাধারণ YouTube search, Shorts বা random feed নেই।',
            style: TextStyle(height: 1.45),
          ))),
          if (!_hasInlinePlayer) const Card(child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('এই প্ল্যাটফর্মে in-app player নেই'),
            subtitle: Text('Windows/Linux সংস্করণ বাইরে YouTube খুলবে না। Android, iOS, macOS বা Web থেকে ভিডিও preview/play করুন।'),
          )),
          const SizedBox(height: 8),
          const Text('ভাষা', style: TextStyle(fontWeight: FontWeight.w900)),
          Wrap(spacing: 7, children: _languages.map((x) => ChoiceChip(
            label: Text(x), selected: _language == x, onSelected: (_) => setState(() => _language = x),
          )).toList()),
          const SizedBox(height: 8),
          const Text('বিষয়', style: TextStyle(fontWeight: FontWeight.w900)),
          Wrap(spacing: 7, runSpacing: 5, children: _subjects.map((x) => ChoiceChip(
            label: Text(x), selected: _subject == x, onSelected: (_) => setState(() => _subject = x),
          )).toList()),
          const SizedBox(height: 10),
          Text(_parentMode ? 'অভিভাবক যাচাই তালিকা' : 'শিশুদের ভিডিও',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          if (visible.isEmpty) Card(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.video_library_outlined, size: 42),
              const SizedBox(height: 10),
              Text(_parentMode
                  ? 'এই ফিল্টারে ভিডিও নেই। অন্য বিষয়/ভাষা বেছে নিন বা নতুন ভিডিও যোগ করুন।'
                  : 'এখনো কোনো ভিডিও অভিভাবক অনুমোদন করেননি। অভিভাবক মোডে গিয়ে ভিডিও যাচাই করুন।',
                textAlign: TextAlign.center),
              if (!_parentMode) OutlinedButton.icon(onPressed: _toggleParent, icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('অভিভাবক মোড খুলুন')),
            ]),
          )),
          ...visible.map((v) => _VideoCard(
            video: v, parentMode: _parentMode, approved: _approved.contains(v.id),
            reviewed: _reviewed.contains(v.id), canPlay: _hasInlinePlayer,
            onOpen: () => _openVideo(v), onApprove: () => _approve(v), onRevoke: () => _revoke(v),
          )),
          const SizedBox(height: 10),
          const Text('English ও Arabic-কে অগ্রাধিকার দিয়ে ৩৪টি নির্দিষ্ট channel/feed থেকে সাম্প্রতিক ভিডিও প্রার্থী আনা হয়। ইন্টারনেট না থাকলে আগের সংরক্ষিত তালিকা থাকবে। নতুন ভিডিও অভিভাবকের অনুমোদন ছাড়া শিশুদের মোডে আসবে না.',
            style: TextStyle(fontSize: 12, height: 1.45)),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.parentMode, required this.approved,
    required this.reviewed, required this.canPlay, required this.onOpen, required this.onApprove, required this.onRevoke});
  final LearningVideo video;
  final bool parentMode, approved, reviewed, canPlay;
  final VoidCallback onOpen, onApprove, onRevoke;

  @override Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AspectRatio(aspectRatio: 16 / 9, child: Stack(fit: StackFit.expand, children: [
        Image.network('https://img.youtube.com/vi/${video.id}/hqdefault.jpg', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.video_library_outlined, size: 44))),
        Align(alignment: Alignment.center, child: CircleAvatar(
          radius: 27, backgroundColor: Colors.black.withValues(alpha: 0.72),
          child: Icon(canPlay ? Icons.play_arrow_rounded : Icons.lock_outline, color: Colors.white, size: 36))),
        Positioned(left: 9, top: 9, child: DecoratedBox(
          decoration: BoxDecoration(color: approved ? Colors.green.shade700 : Colors.black87, borderRadius: BorderRadius.circular(20)),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(approved ? 'অনুমোদিত' : (parentMode ? 'যাচাই বাকি' : 'নিরাপদ তালিকা'),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))))),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(video.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        Text('${video.subject} • ${video.language}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(video.summary),
        const SizedBox(height: 4),
        Text('উৎস: ${video.channel}', style: Theme.of(context).textTheme.bodySmall),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 10), child: parentMode
        ? Wrap(alignment: WrapAlignment.end, spacing: 8, children: [
            OutlinedButton.icon(onPressed: canPlay ? onOpen : null, icon: const Icon(Icons.preview_outlined), label: const Text('সম্পূর্ণ Preview')),
            if (approved)
              TextButton.icon(onPressed: onRevoke, icon: const Icon(Icons.remove_circle_outline), label: const Text('অনুমোদন বাতিল'))
            else
              FilledButton.icon(onPressed: reviewed ? onApprove : null, icon: const Icon(Icons.verified_outlined), label: const Text('শিশুদের জন্য অনুমোদন')),
          ])
        : SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: canPlay ? onOpen : null, icon: const Icon(Icons.play_circle_outline), label: const Text('ভিডিও দেখো')))),
    ]),
  );
}

class _LearningVideoPlayerScreen extends StatefulWidget {
  const _LearningVideoPlayerScreen({required this.video, required this.reviewMode});
  final LearningVideo video;
  final bool reviewMode;
  @override State<_LearningVideoPlayerScreen> createState() => _LearningVideoPlayerScreenState();
}

class _LearningVideoPlayerScreenState extends State<_LearningVideoPlayerScreen> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  bool _ended = false;

  @override void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id, autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false, showFullscreenButton: false,
        privacyEnhancedMode: true, strictRelatedVideos: true,
        enableCaption: true, captionLanguage: 'en', interfaceLanguage: 'en',
        playsInline: true,
      ),
    );
    _subscription = _controller.listen((value) {
      if (value.playerState == PlayerState.ended && mounted && !_ended) setState(() => _ended = true);
    });
  }

  @override void dispose() {
    _subscription?.cancel();
    _controller.close();
    super.dispose();
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.video.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
    body: ListView(padding: const EdgeInsets.all(14), children: [
      ClipRRect(borderRadius: BorderRadius.circular(18), child: _ended
        ? AspectRatio(aspectRatio: 16 / 9, child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle, color: Colors.green, size: 54), SizedBox(height: 8),
              Text('ভিডিও শেষ হয়েছে', style: TextStyle(fontWeight: FontWeight.w900)),
            ])))
        : YoutubePlayer(controller: _controller, aspectRatio: 16 / 9)),
      const SizedBox(height: 12),
      if (!_ended) YoutubeValueBuilder(controller: _controller, builder: (context, value) {
        final playing = value.playerState == PlayerState.playing;
        return FilledButton.icon(
          onPressed: (value.playerState != PlayerState.unknown) ? () {
            if (playing) { _controller.pauseVideo(); } else { _controller.playVideo(); }
          } : null,
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          label: Text(playing ? 'বিরতি' : 'ভিডিও চালু করো'),
        );
      }) else ...[
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
          'ভিডিও শেষ। অ্যাপ নিজে থেকে অন্য YouTube ভিডিও চালাবে না। শিশুদের তালিকায় আনতে অভিভাবককে অনুমোদন করতে হবে.',
          style: TextStyle(height: 1.45)))),
        FilledButton.icon(onPressed: () => Navigator.pop(context, widget.reviewMode),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(widget.reviewMode ? 'Preview শেষ — অভিভাবক মোডে ফিরুন' : 'সম্পন্ন')),
      ],
      const SizedBox(height: 12),
      Text(widget.video.summary, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('বিষয়: ${widget.video.subject} • ভাষা: ${widget.video.language}'),
      const SizedBox(height: 10),
      const Text('এই player সাধারণ YouTube search/feed দেখায় না। তবুও YouTube নিজস্ব বিজ্ঞাপন ও কিছু platform overlay নিয়ন্ত্রণ করে; অভিভাবকের preview ছাড়া কোনো ভিডিও অনুমোদন করবেন না.',
        style: TextStyle(fontSize: 12, height: 1.45)),
    ]),
  );
}
