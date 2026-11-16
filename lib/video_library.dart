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
import 'app_language.dart';

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
final _starter = <LearningVideo>[
  const LearningVideo(id: 'AwccZotbJS4', title: 'Islamic Learning for Kids in Arabic', subject: 'ইসলাম শিক্ষা', language: 'Arabic', channel: 'Kalam Kids', summary: 'শিশুদের জন্য সালাত, দান, রমজান ও হজের পরিচিতি', format: 'ইসলামিক কার্টুন'),
  const LearningVideo(id: 'ASXzhX-J598', title: 'English Alphabet A to Z', subject: 'English', language: 'English', channel: 'Learn With Zakaria – English', summary: 'ইংরেজি বর্ণমালা A থেকে Z পরিচিতি'),
  const LearningVideo(id: 'Pr-WLaESc18', title: 'Colors with Cars – English', subject: 'English', language: 'English', channel: 'Learn With Zakaria – English', summary: 'ইংরেজিতে রঙের নাম শেখা'),
  const LearningVideo(id: 'Ktcxk4lxh3I', title: 'School Vocabulary and Dialogues', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'স্কুলের শব্দ ও ছোট কথোপকথন; ইংরেজি ও আরবি'),
  const LearningVideo(id: 'z01UZ8r_ZOw', title: 'Animal World – Questions and Answers', subject: 'বিজ্ঞান ও প্রকৃতি', language: 'English', channel: 'Learn with Zakaria', summary: 'প্রাণীজগৎ সম্পর্কে শিশুদের সাধারণ জ্ঞান'),
  const LearningVideo(id: '2xgyEC9WCA4', title: 'Arabic Numbers 1 to 20', subject: 'গণিত', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবিতে ১ থেকে ২০ পর্যন্ত সংখ্যা গণনা'),
  const LearningVideo(id: 'zMhSljAXJjE', title: 'Learn Addition for Kids', subject: 'গণিত', language: 'English', channel: 'Learn with Zakaria', summary: 'শিশুদের জন্য প্রাথমিক যোগ শেখা'),
  const LearningVideo(id: 'EiMf3iwvEkc', title: 'Read Simple Arabic Words', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সহজ আরবি শব্দ পড়ার অনুশীলন'),
  const LearningVideo(id: '_BgE9-UScDs', title: 'Fruits and Vegetables in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'ফল ও সবজির আরবি নাম'),
  const LearningVideo(id: 'N18JXcJr1wo', title: 'Vegetable Names in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সবজির আরবি নাম ও শব্দভান্ডার'),
  const LearningVideo(id: 'NchbzH5HM0U', title: 'The Five Pillars of Islam', subject: 'ইসলাম শিক্ষা', language: 'English', channel: 'Learn with Zakaria', summary: 'ইসলামের পাঁচটি স্তম্ভ সম্পর্কে পরিচিতি'),
  const LearningVideo(id: 'MPCvPqIeCCs', title: 'Surah Al-Fatiha for Children', subject: 'ইসলাম শিক্ষা', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'সূরা আল-ফাতিহা শোনা ও মুখস্থের অনুশীলন'),
  const LearningVideo(id: 'itFDZmIZ6pg', title: 'Learn Arabic Alphabet with Animals', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'প্রাণীর উদাহরণ দিয়ে আরবি বর্ণমালা শেখা'),
  const LearningVideo(id: 'W4M4oHBGSkA', title: 'Arabic Alphabet for Children', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবি হরফ ও শব্দের পরিচিতি'),
  const LearningVideo(id: 'iJm8_qxFAPA', title: 'Learn Colors in Arabic and English', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'ইংরেজি ও আরবিতে রঙের নাম শেখা'),
  const LearningVideo(id: 'IB72L8OXSBs', title: 'Colors in English and Arabic', subject: 'English', language: 'English + Arabic', channel: 'Learn with Zakaria', summary: 'ইংরেজি ও আরবিতে ১১টি রঙের নাম'),
  const LearningVideo(id: 'rxqzUKWYykM', title: 'Learn Colors in Arabic', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'আরবি ভাষায় বিভিন্ন রঙের নাম ও শব্দভান্ডার'),
  const LearningVideo(id: '9YftisfXP70', title: 'Fruit Names in Arabic for Kids', subject: 'Arabic', language: 'Arabic', channel: 'Learn with Zakaria', summary: 'শিশুদের জন্য ফলের আরবি নাম শেখা'),
  const LearningVideo(id: '7pT9_P8ERx0', title: 'বাংলা স্বরবর্ণ শেখা', subject: 'বাংলা', language: 'বাংলা', channel: 'Gollachhut', summary: 'শিশুদের বাংলা স্বরবর্ণের পরিচিতি', format: 'শিক্ষামূলক পাঠ'),
  const LearningVideo(id: 'ANEVT9ucRE0', title: 'বাংলায় কুরআন শিক্ষা', subject: 'ইসলাম শিক্ষা', language: 'বাংলা', channel: 'Ustadh Aminul Islam', summary: 'বাংলা ভাষায় কুরআন ও ইসলামিক জ্ঞান শেখার পরিচিতি', format: 'শিক্ষামূলক পাঠ'),
  const LearningVideo(id: 'wq8VDpbUqeE', title: 'আয় আয় চাঁদ মামা', subject: 'বাংলা', language: 'বাংলা', channel: 'Gollachhut', summary: 'বাংলা শিশুতোষ ছড়া', format: 'বাংলা ছড়া ও কার্টুন'),
  const LearningVideo(id: 'Qbq9jUbvln0', title: 'হাট্টিমাটিম টিম', subject: 'বাংলা', language: 'বাংলা', channel: 'Gollachhut', summary: 'বাংলা শিশুতোষ ছড়া ও ভাষা চর্চা', format: 'বাংলা ছড়া ও কার্টুন'),
  const LearningVideo(id: '4AtkggEGPtw', title: 'আয় বৃষ্টি ঝেঁপে', subject: 'বাংলা', language: 'বাংলা', channel: 'Gollachhut', summary: 'বাংলা শিশুতোষ ছড়া', format: 'বাংলা ছড়া ও কার্টুন'),
  const LearningVideo(id: 'D30tFdV-Fmc', title: 'The Evil Eye and How to Protect Yourself', subject: 'ইসলাম শিক্ষা', language: 'English', channel: 'One4Kids / Zaky', summary: 'শিশুদের জন্য বদনজর সম্পর্কে সহজ ইসলামিক শিক্ষা', format: 'ইসলামিক গল্প'),
  const LearningVideo(id: 'Bw433ZDXNyc', title: 'Learn Surat At-Takathur with Zaky', subject: 'ইসলাম শিক্ষা', language: 'English', channel: 'One4Kids / Zaky', summary: 'শিশুদের জন্য সূরা আত-তাকাসুরের সহজ পরিচিতি', format: 'শিক্ষামূলক পাঠ'),
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

  // Bengali-language Islamic learning and children's education sources.
  _VideoFeedSource(name: 'IQRA Cartoon Bangla', channelId: 'UCuAyZMb3xHNyfKe4qEDo4kg', subject: 'ইসলাম শিক্ষা', language: 'বাংলা', format: 'ইসলামিক কার্টুন'),
  _VideoFeedSource(name: 'Nobider Kahini - নবীদের কাহিনী', channelId: 'UCeR1Of2EdepL0-b88e8cJaQ', subject: 'ইসলাম শিক্ষা', language: 'বাংলা', format: 'ইসলামিক গল্প'),
  _VideoFeedSource(name: 'Bangla Islamic Kids & Cartoon Videos', channelId: 'UCgyC38y6cvZYjY_TFF0_ZPQ', subject: 'ইসলাম শিক্ষা', language: 'বাংলা', format: 'ইসলামিক কার্টুন'),
  _VideoFeedSource(name: 'Ustadh Aminul Islam', channelId: 'UCNMGnHg6QE587Wwm8qw-wqQ', subject: 'ইসলাম শিক্ষা', language: 'বাংলা', format: 'শিক্ষামূলক পাঠ'),
  _VideoFeedSource(name: 'Kids Bangla Study', channelId: 'UCif_wCWoqCJckhqW9jgyadA', subject: 'বাংলা', language: 'বাংলা', format: 'শিক্ষামূলক পাঠ'),
  _VideoFeedSource(name: 'Kiddiestv Bangla', channelId: 'UC6Ce0W_c7mCNu87Qnx4ZNaw', subject: 'বাংলা', language: 'বাংলা', format: 'বাংলা ছড়া ও কার্টুন'),
];

const _subjects = <String>['সব বিষয়','English','Arabic','বাংলা','গণিত','বিজ্ঞান ও প্রকৃতি','ইসলাম শিক্ষা','ইতিহাস','ভূগোল','কম্পিউটার','শিল্প ও সৃজনশীলতা','স্বাস্থ্য ও জীবনদক্ষতা','সাধারণ জ্ঞান'];
const _languages = <String>['সব ভাষা','English','Arabic','বাংলা'];
const _formats = <String>['সব ধরন','ইসলামিক কার্টুন','কার্টুন','ইসলামিক গল্প','শিক্ষামূলক পাঠ','বাংলা ছড়া ও কার্টুন'];

/// Localizes app-owned filter values without changing stable stored source keys.
const Map<String, List<String>> _videoLabelTranslations = {
  'সব বিষয়':['All subjects','كل المواد'],
  'সব ভাষা':['All languages','كل اللغات'],
  'সব ধরন':['All formats','كل الأنواع'],
  'English':['English','الإنجليزية'],
  'Arabic':['Arabic','العربية'],
  'বাংলা':['Bangla','البنغالية'],
  'English + Arabic':['English + Arabic','الإنجليزية + العربية'],
  'গণিত':['Mathematics','الرياضيات'],
  'বিজ্ঞান ও প্রকৃতি':['Science and Nature','العلوم والطبيعة'],
  'ইসলাম শিক্ষা':['Islamic Studies','الدراسات الإسلامية'],
  'ইতিহাস':['History','التاريخ'],
  'ভূগোল':['Geography','الجغرافيا'],
  'কম্পিউটার':['Computing','الحاسوب'],
  'শিল্প ও সৃজনশীলতা':['Arts and Creativity','الفنون والإبداع'],
  'স্বাস্থ্য ও জীবনদক্ষতা':['Health and Life Skills','الصحة والمهارات الحياتية'],
  'সাধারণ জ্ঞান':['General Knowledge','المعرفة العامة'],
  'ইসলামিক কার্টুন':['Islamic cartoons','رسوم إسلامية'],
  'কার্টুন':['Cartoons','رسوم متحركة'],
  'ইসলামিক গল্প':['Islamic stories','قصص إسلامية'],
  'শিক্ষামূলক পাঠ':['Learning lesson','درس تعليمي'],
  'বাংলা ছড়া ও কার্টুন':['Bangla rhymes and cartoons','أناشيد ورسوم بنغالية'],
};

String localizedVideoFilterLabel(String source) {
  final values = _videoLabelTranslations[source];
  if (values == null) return source;
  switch (AppLanguageController.selected.value) {
    case 'English': return values[0];
    case 'العربية': return values[1];
    default: return source;
  }
}

const Map<String, List<String>> _videoSummaryTranslations = {
  'শিশুদের জন্য সালাত, দান, রমজান ও হজের পরিচিতি':['An introduction to prayer, charity, Ramadan and Hajj for children','تعريف للأطفال بالصلاة والصدقة ورمضان والحج'],
  'ইংরেজি বর্ণমালা A থেকে Z পরিচিতি':['Meet the English alphabet from A to Z','تعرّف إلى الحروف الإنجليزية من A إلى Z'],
  'ইংরেজিতে রঙের নাম শেখা':['Learn the names of colours in English','تعلّم أسماء الألوان باللغة الإنجليزية'],
  'স্কুলের শব্দ ও ছোট কথোপকথন; ইংরেজি ও আরবি':['School words and short conversations in English and Arabic','كلمات المدرسة ومحادثات قصيرة بالإنجليزية والعربية'],
  'প্রাণীজগৎ সম্পর্কে শিশুদের সাধারণ জ্ঞান':['Discover facts about animals','تعرّف إلى معلومات عن عالم الحيوانات'],
  'আরবিতে ১ থেকে ২০ পর্যন্ত সংখ্যা গণনা':['Count from 1 to 20 in Arabic','تعلّم العدّ من ١ إلى ٢٠ باللغة العربية'],
  'শিশুদের জন্য প্রাথমিক যোগ শেখা':['Learn simple addition','تعلّم الجمع بطريقة بسيطة'],
  'সহজ আরবি শব্দ পড়ার অনুশীলন':['Practise reading simple Arabic words','تدرّب على قراءة كلمات عربية سهلة'],
  'ফল ও সবজির আরবি নাম':['Learn fruit and vegetable names in Arabic','تعلّم أسماء الفواكه والخضروات بالعربية'],
  'সবজির আরবি নাম ও শব্দভান্ডার':['Learn Arabic vegetable names and words','تعلّم أسماء الخضروات ومفرداتها بالعربية'],
  'ইসলামের পাঁচটি স্তম্ভ সম্পর্কে পরিচিতি':['An introduction to the Five Pillars of Islam','تعرّف إلى أركان الإسلام الخمسة'],
  'সূরা আল-ফাতিহা শোনা ও মুখস্থের অনুশীলন':['Listen to and practise memorising Surah Al-Fatihah','استمع إلى سورة الفاتحة وتدرّب على حفظها'],
  'প্রাণীর উদাহরণ দিয়ে আরবি বর্ণমালা শেখা':['Learn Arabic letters using animal examples','تعلّم الحروف العربية من خلال أمثلة الحيوانات'],
  'আরবি হরফ ও শব্দের পরিচিতি':['Meet Arabic letters and words','تعرّف إلى الحروف والكلمات العربية'],
  'ইংরেজি ও আরবিতে রঙের নাম শেখা':['Learn colour names in English and Arabic','تعلّم أسماء الألوان بالإنجليزية والعربية'],
  'ইংরেজি ও আরবিতে ১১টি রঙের নাম':['Learn eleven colour names in English and Arabic','تعلّم أحد عشر اسمًا للون بالإنجليزية والعربية'],
  'আরবি ভাষায় বিভিন্ন রঙের নাম ও শব্দভান্ডার':['Learn Arabic colour names and vocabulary','تعلّم أسماء الألوان ومفرداتها بالعربية'],
  'শিশুদের জন্য ফলের আরবি নাম শেখা':['Learn Arabic names for fruits','تعلّم أسماء الفواكه باللغة العربية'],
  'শিশুদের বাংলা স্বরবর্ণের পরিচিতি':['Meet the Bangla vowel letters','تعرّف إلى حروف العلة البنغالية'],
  'বাংলা ভাষায় কুরআন ও ইসলামিক জ্ঞান শেখার পরিচিতি':['An introduction to learning about the Quran and Islam in Bangla','مقدمة للتعرّف إلى القرآن والمعرفة الإسلامية باللغة البنغالية'],
  'বাংলা শিশুতোষ ছড়া':['Bangla nursery rhyme','أنشودة أطفال بنغالية'],
  'বাংলা শিশুতোষ ছড়া ও ভাষা চর্চা':['Bangla nursery rhymes and language practice','أناشيد أطفال بنغالية وتدريب لغوي'],
  'শিশুদের জন্য বদনজর সম্পর্কে সহজ ইসলামিক শিক্ষা':['A simple lesson for children about the evil eye','درس مبسّط للأطفال عن العين'],
  'শিশুদের জন্য সূরা আত-তাকাসুরের সহজ পরিচিতি':['A simple introduction to Surah At-Takathur for children','تعريف مبسّط للأطفال بسورة التكاثر'],
  'নির্দিষ্ট channel feed থেকে সংগৃহীত ভিডিও।':['Video collected from a selected channel feed.','فيديو جُمع من خلاصة قناة محددة.'],
  'নিজে যোগ করা ভিডিও।':['Video added by the user.','فيديو أضافه المستخدم.'],
};

String localizedVideoSummary(String source) {
  final values = _videoSummaryTranslations[source];
  if (values == null) return source;
  switch (AppLanguageController.selected.value) {
    case 'English': return values[0];
    case 'العربية': return values[1];
    default: return source;
  }
}

String _videoDigits(int number) {
  final locale = AppLanguageController.selected.value;
  final symbols = locale == 'বাংলা' ? '০১২৩৪৫৬৭৮৯'
      : locale == 'العربية' ? '٠١٢٣٤٥٦٧٨٩' : '0123456789';
  return number.toString().split('').map((digit) {
    final value = int.tryParse(digit);
    return value == null ? digit : symbols[value];
  }).join();
}

String _videoCountLabel(int count) {
  final digits = _videoDigits(count);
  return appText('$digitsটি ভিডিও', '$digits videos', '$digits فيديو');
}


String? _videoId(String input) {
  final value = input.trim();
  final match = RegExp(r'(?:youtu\.be/|[?&]v=|/embed/|/shorts/)([A-Za-z0-9_-]{11})').firstMatch(value);
  if (match != null) return match.group(1);
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value) ? value : null;
}


/// Number of video entries the library is designed to collect.
const int videoLibraryTarget = 600;

int get videoFeedSourceCount => _videoFeeds.length;
int get banglaVideoFeedSourceCount =>
    _videoFeeds.where((source) => source.language == 'বাংলা').length;
int get videoLibraryTheoreticalCapacity => _videoFeeds.length * 15 + _starter.length;
List<String> get banglaVideoSourceNames => _videoFeeds
    .where((source) => source.language == 'বাংলা')
    .map((source) => source.name)
    .toList(growable: false);

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
  bool _loadFailed = false;
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
      if (mounted) setState(() { _loading = false; _loadFailed = true; });
    }
  }

  Future<void> _refreshRemoteCatalog({bool showMessage = false}) async {
    if (_refreshing || kIsWeb) {
      if (kIsWeb && showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              appText('Web preview-তে YouTube feed-এর CORS সীমাবদ্ধতা থাকতে পারে। Android/iOS/macOS-এ refresh করুন।', 'YouTube feed refresh may be blocked by browser CORS in the web preview. Refresh on Android, iOS or macOS.', 'قد تمنع قيود CORS في المتصفح تحديث خلاصة YouTube في معاينة الويب. حدّثها على Android أو iOS أو macOS.'),
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
          ? appText('নতুন feed ভিডিও পাওয়া যায়নি। আগের সংরক্ষিত তালিকা রাখা হয়েছে।', 'No new feed videos were found. Your saved list has been kept.', 'لم يتم العثور على فيديوهات جديدة. احتفظنا بالقائمة المحفوظة.')
          : appText(
              '${discovered.length}টি নতুন ভিডিও যোগ হয়েছে। বর্তমানে মোট ${count}টি পাওয়া গেছে।',
              '${_videoDigits(discovered.length)} new videos added. ${_videoDigits(count)} videos are now available.',
              'أُضيف ${_videoDigits(discovered.length)} فيديو جديد. يتوفر الآن ${_videoDigits(count)} فيديو.',
            );
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
          title: Text(appText('নতুন শেখার ভিডিও যোগ','Add a learning video','إضافة فيديو تعليمي')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  maxLength: 80,
                  decoration: InputDecoration(labelText: appText('ভিডিওর নাম', 'Video title', 'عنوان الفيديو')),
                ),
                TextField(
                  controller: urlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: appText('YouTube URL বা Video ID', 'YouTube URL or video ID', 'رابط YouTube أو معرّف الفيديو'),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: language,
                  decoration: InputDecoration(labelText: appText('ভিডিওর ভাষা', 'Video language', 'لغة الفيديو')),
                  items: _languages
                      .where((item) => item != 'সব ভাষা')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(localizedVideoFilterLabel(item)),
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
                  decoration: InputDecoration(labelText: appText('বিষয়','Subject','الموضوع')),
                  items: _subjects
                      .where((item) => item != 'সব বিষয়')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(localizedVideoFilterLabel(item)),
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
                  decoration: InputDecoration(labelText: appText('ধরন', 'Format', 'النوع')),
                  items: _formats
                      .where((item) => item != 'সব ধরন')
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(localizedVideoFilterLabel(item)),
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
              child: Text(appText('বাতিল','Cancel','إلغاء')),
            ),
            FilledButton(
              onPressed: () {
                final id = _videoId(urlController.text);
                if (titleController.text.trim().isEmpty || id == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(appText('সঠিক নাম ও বৈধ YouTube URL দিন।', 'Enter a title and a valid YouTube URL or video ID.', 'أدخل عنوانًا ورابط YouTube أو معرّف فيديو صحيحًا.')),
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
              child: Text(appText('ভিডিও যোগ করো','Add video','أضف فيديو')),
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
        SnackBar(content: Text(appText('এই ভিডিওটি আগেই আছে।', 'This video is already in your library.', 'هذا الفيديو موجود بالفعل في مكتبتك.'))),
      );
      return;
    }

    setState(() => _custom.add(result));
    await _saveCustom();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appText('ভিডিওটি লাইব্রেরিতে যোগ হয়েছে।', 'The video was added to your library.', 'تمت إضافة الفيديو إلى مكتبتك.'))),
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
            ? appText('এই Windows ডিভাইসে Microsoft Edge WebView2 Runtime পাওয়া যায়নি। Runtime ইনস্টল করে আবার চেষ্টা করুন।', 'Microsoft Edge WebView2 Runtime was not found on this Windows device. Install it and try again.', 'لم يتم العثور على Microsoft Edge WebView2 Runtime على جهاز Windows هذا. ثبّته ثم حاول مرة أخرى.')
            : appText('ভিডিও player চালু করা যায়নি। Windows-এ WebView2 Runtime এবং Linux-এ WebKitGTK 4.1 ও libsoup 3 প্রয়োজন হতে পারে।', 'The video player could not start. Windows may need WebView2 Runtime; Linux may need WebKitGTK 4.1 and libsoup 3.', 'تعذّر تشغيل مشغّل الفيديو. قد يحتاج Windows إلى WebView2، وقد يحتاج Linux إلى WebKitGTK 4.1 وlibsoup 3.');
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

  void _applyCollection({
    String subject = 'সব বিষয়',
    String language = 'সব ভাষা',
    String format = 'সব ধরন',
  }) {
    setState(() {
      _subject = subject;
      _language = language;
      _format = format;
      _displayLimit = 30;
    });
  }

  int _collectionCount({
    String subject = 'সব বিষয়',
    String language = 'সব ভাষা',
    String format = 'সব ধরন',
  }) {
    return _all.where((item) {
      if (subject != 'সব বিষয়' && item.subject != subject) return false;
      if (language != 'সব ভাষা' &&
          !item.language.toLowerCase().contains(language.toLowerCase())) {
        return false;
      }
      if (format != 'সব ধরন' && item.format != format) return false;
      return true;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    final visible = _visible;
    final progress =
        (all.length / videoLibraryTarget).clamp(0.0, 1.0).toDouble();
    final scheme = Theme.of(context).colorScheme;
    final displayed = visible.take(_displayLimit).toList(growable: false);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(appText('ভিডিও শেখার জগৎ','Video learning world','عالم التعلم بالفيديو')),
        actions: [
          IconButton(
            tooltip: appText('ভিডিও তালিকা refresh','Refresh videos','تحديث الفيديوهات'),
            onPressed: _refreshing
                ? null
                : () => _refreshRemoteCatalog(showMessage: true),
            icon: Icon(_refreshing ? Icons.sync : Icons.refresh),
          ),
          IconButton(
            tooltip: appText('নিজের ভিডিও যোগ','Add your video','أضف الفيديو الخاص بك'),
            onPressed: _addVideo,
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(appText('ভিডিও লোড হচ্ছে…', 'Loading videos…', 'جارٍ تحميل الفيديوهات…'))]))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                if (_loadFailed) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(appText('সংরক্ষিত ভিডিও তালিকা পড়া যায়নি। ডিভাইসের স্টোরেজ অনুমতি পরীক্ষা করে আবার চেষ্টা করো।', 'The saved video list could not be loaded. Check device storage access and try again.', 'تعذّر تحميل قائمة الفيديوهات المحفوظة. تحقّق من الوصول إلى مساحة التخزين وحاول مرة أخرى.')))),
                Container(
                  padding: const EdgeInsets.all(21),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF064E3B),
                        Color(0xFF087F5B),
                        Color(0xFF16A477),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF087F5B).withValues(alpha: 0.18),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -6,
                        top: -13,
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 104,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              appText('ছোট্ট পাঠশালা • শেখার ভিডিও', 'Chotto Pathshala • Learning videos', 'تشوتو باتشالا • فيديوهات تعليمية'),
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 13),
                          const Text(
                            appText('দেখে শিখি،\nআনন্দে বড় হই!', 'Watch, learn,\nand grow with joy!', 'شاهد وتعلّم،\nوانمُ بفرح!'),
                            style: TextStyle(color: Colors.white, fontSize: 27, height: 1.16, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            appText('বাংলা • ইসলামিক শিক্ষা • English • Arabic', 'Bangla • Islamic learning • English • Arabic', 'البنغالية • التعليم الإسلامي • الإنجليزية • العربية'),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.4),
                          ),
                          const SizedBox(height: 17),
                          Row(
                            children: [
                              _VideoHeroMetric(value: all.length.toString(), label: appText('পাওয়া ভিডিও','Videos found','الفيديوهات المتاحة')),
                              const SizedBox(width: 10),
                              _VideoHeroMetric(value: banglaVideoFeedSourceCount.toString(), label: appText('বাংলা channel','Bangla channels','قنوات بنغالية')),
                              const SizedBox(width: 10),
                              _VideoHeroMetric(value: videoLibraryTarget.toString() + '+', label: appText('সংগ্রহের লক্ষ্য','Collection target','هدف المجموعة')),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              color: const Color(0xFFFFD166),
                            ),
                          ),
                          if (_refreshing)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: LinearProgressIndicator(backgroundColor: Colors.white24, color: Colors.white),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(appText('তোমার শেখার বিভাগ','Learning categories','أقسام التعلم'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    ),
                    Text(appText('এক ট্যাপে বেছে নাও','Choose with one tap','اختر بلمسة واحدة'), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 126,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _VideoCollectionShortcut(
                        icon: Icons.translate_rounded,
                        title: appText('বাংলা শেখা','Learn Bangla','تعلم البنغالية'),
                        subtitle: appText('বর্ণ, ছড়া ও শিশু পাঠ','Letters, rhymes and lessons','الحروف والأناشيد والدروس'),
                        count: _collectionCount(subject: 'বাংলা', language: 'বাংলা'),
                        accent: const Color(0xFF147D64),
                        onTap: () => _applyCollection(subject: 'বাংলা', language: 'বাংলা'),
                      ),
                      const SizedBox(width: 10),
                      _VideoCollectionShortcut(
                        icon: Icons.menu_book_rounded,
                        title: appText('বাংলা ইসলামিক','Islamic in Bangla','إسلامي باللغة البنغالية'),
                        subtitle: appText('কুরআন, গল্প ও আদব','Quran, stories and manners','القرآن والقصص والآداب'),
                        count: _collectionCount(subject: 'ইসলাম শিক্ষা', language: 'বাংলা'),
                        accent: const Color(0xFF4467B1),
                        onTap: () => _applyCollection(subject: 'ইসলাম শিক্ষা', language: 'বাংলা'),
                      ),
                      const SizedBox(width: 10),
                      _VideoCollectionShortcut(
                        icon: Icons.auto_awesome_rounded,
                        title: appText('ইসলামিক কার্টুন','Islamic cartoons','رسوم إسلامية'),
                        subtitle: appText('শিক্ষামূলক animation','Educational animation','رسوم متحركة تعليمية'),
                        count: _collectionCount(format: 'ইসলামিক কার্টুন'),
                        accent: const Color(0xFF8B5CB7),
                        onTap: () => _applyCollection(format: 'ইসলামিক কার্টুন'),
                      ),
                      const SizedBox(width: 10),
                      _VideoCollectionShortcut(
                        icon: Icons.video_library_rounded,
                        title: appText('সব ভিডিও','All videos','كل الفيديوهات'),
                        subtitle: appText('সম্পূর্ণ collection','Full collection','المجموعة كاملة'),
                        count: all.length,
                        accent: const Color(0xFFB7791F),
                        onTap: () => _applyCollection(),
                      ),
                      const SizedBox(width: 2),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value.trim().toLowerCase();
                    _displayLimit = 30;
                  }),
                  decoration: InputDecoration(
                    hintText: appText('বাংলা / English ভিডিও, বিষয় বা channel খুঁজুন','Search Bangla / English videos, topics or channels','ابحث عن فيديوهات أو مواضيع أو قنوات'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: appText('সার্চ মুছুন', 'Clear search', 'مسح البحث'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _displayLimit = 30;
                              });
                            },
                            icon: const Icon(Icons.clear_rounded),
                          ),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: scheme.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: Icon(Icons.tune_rounded, color: scheme.primary),
                  title: Text(appText('আরও filter','More filters','المزيد من عوامل التصفية'), style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    appText('ভাষা: ${localizedVideoFilterLabel(_language)} • বিষয়: ${localizedVideoFilterLabel(_subject)} • ধরন: ${localizedVideoFilterLabel(_format)}', 'Language: ${localizedVideoFilterLabel(_language)} • Subject: ${localizedVideoFilterLabel(_subject)} • Format: ${localizedVideoFilterLabel(_format)}', 'اللغة: ${localizedVideoFilterLabel(_language)} • المادة: ${localizedVideoFilterLabel(_subject)} • النوع: ${localizedVideoFilterLabel(_format)}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  children: [
                    _VideoFilterGroup(
                      title: appText('ভাষা','Language','اللغة'),
                      values: _languages,
                      selected: _language,
                      onSelected: (value) => _applyCollection(subject: _subject, language: value, format: _format),
                    ),
                    _VideoFilterGroup(
                      title: appText('বিষয়','Subject','الموضوع'),
                      values: _subjects,
                      selected: _subject,
                      onSelected: (value) => _applyCollection(subject: value, language: _language, format: _format),
                    ),
                    _VideoFilterGroup(
                      title: appText('ভিডিওর ধরন','Video type','نوع الفيديو'),
                      values: _formats,
                      selected: _format,
                      onSelected: (value) => _applyCollection(subject: _subject, language: _language, format: value),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(appText('ভিডিও লাইব্রেরি','Video library','مكتبة الفيديو'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(30)),
                      child: Text(_videoCountLabel(visible.length),
                        style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (visible.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Icon(Icons.video_library_outlined, size: 46, color: scheme.primary),
                          const SizedBox(height: 10),
                          Text(appText('এই বিভাগে এখনো ভিডিও পাওয়া যায়নি।','No videos found in this category yet.','لا توجد فيديوهات في هذا القسم حتى الآن.'), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                              _applyCollection();
                            },
                            icon: const Icon(Icons.filter_alt_off_rounded),
                            label: Text(appText('সব ভিডিও দেখাও','Show all videos','عرض كل الفيديوهات')),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1120
                          ? 3
                          : (constraints.maxWidth >= 680 ? 2 : 1);
                      final cards = displayed
                          .map((item) => _VideoCard(video: item, onOpen: () => _openVideo(item)))
                          .toList(growable: false);
                      if (columns == 1) {
                        return Column(
                          children: [
                            for (final card in cards) ...[card, const SizedBox(height: 12)],
                          ],
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cards.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: columns == 3 ? 0.88 : 0.95,
                        ),
                        itemBuilder: (context, index) => cards[index],
                      );
                    },
                  ),
                if (visible.length > _displayLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _displayLimit += 30),
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text(appText('আরও ৩০টি ভিডিও দেখুন (${_videoDigits(visible.length - _displayLimit)}টি বাকি)', 'Show 30 more videos (${_videoDigits(visible.length - _displayLimit)} remaining)', 'عرض ٣٠ فيديو إضافيًا (المتبقي ${_videoDigits(visible.length - _displayLimit)})')),
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: scheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            appText(
              '${videoFeedSourceCount}টি নির্দিষ্ট channel/feed থেকে সর্বশেষ ভিডিও আনা হয়; প্রতিটি feed থেকে সর্বোচ্চ ১৫টি এন্ট্রি নেওয়া হয়। বাংলা ভাষার জন্য ${banglaVideoFeedSourceCount}টি channel যুক্ত আছে। Feed কম ভিডিও দিলে বা বন্ধ থাকলে প্রকৃত সংখ্যা কম হতে পারে। ভিডিওর দৃশ্য, শব্দ, ধর্মীয় নির্ভুলতা বা বিজ্ঞাপন আলাদাভাবে স্বয়ংক্রিয়ভাবে যাচাই করা হয় না।',
              'Recent videos are collected from ${_videoDigits(videoFeedSourceCount)} selected channel feeds, with up to 15 entries per feed. ${_videoDigits(banglaVideoFeedSourceCount)} feeds are listed as Bangla. The actual count may be lower if a feed returns fewer videos or is unavailable. Video imagery, audio, religious accuracy and advertisements are not automatically reviewed individually.',
              'تُجمع أحدث الفيديوهات من ${_videoDigits(videoFeedSourceCount)} خلاصات قنوات محددة، بحد أقصى ١٥ إدخالًا لكل خلاصة. توجد ${_videoDigits(banglaVideoFeedSourceCount)} خلاصات باللغة البنغالية. قد يكون العدد الفعلي أقل إذا أعادت الخلاصة عددًا أقل أو لم تكن متاحة. لا تتم مراجعة مشاهد الفيديو أو صوته أو دقته الدينية أو إعلاناته تلقائيًا لكل مقطع.',
            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _VideoHeroMetric extends StatelessWidget {
  const _VideoHeroMetric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _VideoCollectionShortcut extends StatelessWidget {
  const _VideoCollectionShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: BorderSide(color: accent.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.035)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: accent.withValues(alpha: 0.15),
                      foregroundColor: accent,
                      child: Icon(icon, size: 19),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
                  ],
                ),
                const Spacer(),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text('$subtitle • $count', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoFilterGroup extends StatelessWidget {
  const _VideoFilterGroup({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
  });
  final String title;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Wrap(
            spacing: 7,
            runSpacing: 5,
            children: values.map((value) => ChoiceChip(
              label: Text(localizedVideoFilterLabel(value)),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
            )).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onOpen});
  final LearningVideo video;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://img.youtube.com/vi/${video.id}/hqdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.video_library_rounded, color: scheme.primary, size: 46),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.24),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.26),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.black.withValues(alpha: 0.67),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 37),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      localizedVideoFilterLabel(video.format),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, height: 1.2)),
                const SizedBox(height: 6),
                Text('${localizedVideoFilterLabel(video.subject)} • ${localizedVideoFilterLabel(video.language)}', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 4),
                Text(localizedVideoSummary(video.summary), maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(video.channel, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(appText('দেখো','Watch','شاهد')),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
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
    final selectedLanguage = AppLanguageController.selected.value;
    final playerLanguage = selectedLanguage == 'বাংলা' ? 'bn' : selectedLanguage == 'العربية' ? 'ar' : 'en';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.id,
      autoPlay: false,
      params: YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        privacyEnhancedMode: true,
        strictRelatedVideos: true,
        enableCaption: true,
        captionLanguage: playerLanguage,
        interfaceLanguage: playerLanguage,
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
                              appText('ভিডিও শেষ হয়েছে', 'Video finished', 'انتهى الفيديو'),
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
                    label: Text(playing ? appText('বিরতি','Pause','إيقاف مؤقت') : appText('ভিডিও চালু করো','Play video','تشغيل الفيديو')),
                  );
                },
              )
            else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    appText('ভিডিও শেষ হয়েছে। পরের ভিডিওটি নিজে বেছে নাও।', 'This video has finished. Choose the next video yourself.', 'انتهى الفيديو. اختر الفيديو التالي بنفسك.'),
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(appText('সম্পন্ন','Done','تم')),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              localizedVideoSummary(widget.video.summary),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              appText('বিষয়: ${localizedVideoFilterLabel(widget.video.subject)} • ভাষা: ${localizedVideoFilterLabel(widget.video.language)}', 'Subject: ${localizedVideoFilterLabel(widget.video.subject)} • Language: ${localizedVideoFilterLabel(widget.video.language)}', 'المادة: ${localizedVideoFilterLabel(widget.video.subject)} • اللغة: ${localizedVideoFilterLabel(widget.video.language)}'),
            ),
            const SizedBox(height: 10),
            const Text(
              appText('এই player সাধারণ YouTube search/feed দেখায় না এবং নিজে থেকে পরের ভিডিও চালায় না। YouTube-এর বিজ্ঞাপন বা platform overlay অ্যাপ সম্পূর্ণ নিয়ন্ত্রণ করতে পারে না।', 'This player does not show general YouTube search or feeds and does not autoplay the next video. The app cannot fully control YouTube ads or platform overlays.', 'لا يعرض هذا المشغّل البحث أو الخلاصات العامة في YouTube، ولا يشغّل الفيديو التالي تلقائيًا. لا يستطيع التطبيق التحكم بالكامل في إعلانات YouTube أو واجهات المنصة.'),
              style: TextStyle(fontSize: 12, height: 1.45),
            ),
          ],
        ),
      );
}
