class LearningItem {
  const LearningItem({
    required this.id,
    required this.glyph,
    required this.word,
    required this.meaning,
    required this.emoji,
    required this.language,
    required this.category,
    required this.reading,
    this.isSign = false,
  });

  final String id, glyph, word, meaning, emoji, language, category, reading;
  final bool isSign;
}

const banglaLetters = <LearningItem>[
  LearningItem(id:'bn-01',glyph:'অ',word:'অজগর',meaning:'এক ধরনের বড় সাপ',emoji:'🐍',language:'bn',category:'স্বরবর্ণ',reading:'অ'),
  LearningItem(id:'bn-02',glyph:'আ',word:'আম',meaning:'মিষ্টি ফল',emoji:'🥭',language:'bn',category:'স্বরবর্ণ',reading:'আ'),
  LearningItem(id:'bn-03',glyph:'ই',word:'ইলিশ',meaning:'একটি সুস্বাদু মাছ',emoji:'🐟',language:'bn',category:'স্বরবর্ণ',reading:'ই'),
  LearningItem(id:'bn-04',glyph:'ঈ',word:'ঈগল',meaning:'বড় শিকারি পাখি',emoji:'🦅',language:'bn',category:'স্বরবর্ণ',reading:'ঈ'),
  LearningItem(id:'bn-05',glyph:'উ',word:'উট',meaning:'মরুভূমির প্রাণী',emoji:'🐪',language:'bn',category:'স্বরবর্ণ',reading:'উ'),
  LearningItem(id:'bn-06',glyph:'ঊ',word:'ঊষা',meaning:'ভোরের প্রথম আলো',emoji:'🌅',language:'bn',category:'স্বরবর্ণ',reading:'ঊ'),
  LearningItem(id:'bn-07',glyph:'ঋ',word:'ঋষি',meaning:'জ্ঞানী সাধক',emoji:'🧘',language:'bn',category:'স্বরবর্ণ',reading:'ঋ'),
  LearningItem(id:'bn-08',glyph:'এ',word:'একতারা',meaning:'এক তারের বাদ্যযন্ত্র',emoji:'🎸',language:'bn',category:'স্বরবর্ণ',reading:'এ'),
  LearningItem(id:'bn-09',glyph:'ঐ',word:'ঐক্য',meaning:'একসঙ্গে থাকা',emoji:'🤝',language:'bn',category:'স্বরবর্ণ',reading:'ঐ'),
  LearningItem(id:'bn-10',glyph:'ও',word:'ওল',meaning:'এক ধরনের সবজি',emoji:'🥔',language:'bn',category:'স্বরবর্ণ',reading:'ও'),
  LearningItem(id:'bn-11',glyph:'ঔ',word:'ঔষধ',meaning:'অসুস্থ হলে চিকিৎসায় লাগে',emoji:'💊',language:'bn',category:'স্বরবর্ণ',reading:'ঔ'),
  LearningItem(id:'bn-12',glyph:'ক',word:'কলম',meaning:'লেখার জিনিস',emoji:'🖊️',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ক'),
  LearningItem(id:'bn-13',glyph:'খ',word:'খরগোশ',meaning:'লম্বা কানওয়ালা প্রাণী',emoji:'🐇',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'খ'),
  LearningItem(id:'bn-14',glyph:'গ',word:'গরু',meaning:'গৃহপালিত প্রাণী',emoji:'🐄',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'গ'),
  LearningItem(id:'bn-15',glyph:'ঘ',word:'ঘড়ি',meaning:'সময় দেখার যন্ত্র',emoji:'⏰',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঘ'),
  LearningItem(id:'bn-16',glyph:'ঙ',word:'ব্যাঙ',meaning:'লাফিয়ে চলে এমন প্রাণী',emoji:'🐸',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঙ'),
  LearningItem(id:'bn-17',glyph:'চ',word:'চাঁদ',meaning:'রাতে আকাশে দেখা যায়',emoji:'🌙',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'চ'),
  LearningItem(id:'bn-18',glyph:'ছ',word:'ছাতা',meaning:'বৃষ্টি থেকে বাঁচায়',emoji:'☂️',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ছ'),
  LearningItem(id:'bn-19',glyph:'জ',word:'জাহাজ',meaning:'বড় নৌযান',emoji:'🚢',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'জ'),
  LearningItem(id:'bn-20',glyph:'ঝ',word:'ঝরনা',meaning:'পাহাড় থেকে নেমে আসা পানি',emoji:'💦',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঝ'),
  LearningItem(id:'bn-21',glyph:'ঞ',word:'যজ্ঞ',meaning:'ঞ-যুক্ত একটি শব্দ',emoji:'🪔',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঞ'),
  LearningItem(id:'bn-22',glyph:'ট',word:'টমেটো',meaning:'লাল রঙের সবজি',emoji:'🍅',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ট'),
  LearningItem(id:'bn-23',glyph:'ঠ',word:'ঠেলা',meaning:'ঠেলে নেওয়ার গাড়ি',emoji:'🛒',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঠ'),
  LearningItem(id:'bn-24',glyph:'ড',word:'ডাব',meaning:'কচি নারিকেল',emoji:'🥥',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ড'),
  LearningItem(id:'bn-25',glyph:'ঢ',word:'ঢোল',meaning:'এক ধরনের বাদ্যযন্ত্র',emoji:'🥁',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঢ'),
  LearningItem(id:'bn-26',glyph:'ণ',word:'হরিণ',meaning:'বনের সুন্দর প্রাণী',emoji:'🦌',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ণ'),
  LearningItem(id:'bn-27',glyph:'ত',word:'তরমুজ',meaning:'রসালো ফল',emoji:'🍉',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ত'),
  LearningItem(id:'bn-28',glyph:'থ',word:'থালা',meaning:'খাবার রাখার পাত্র',emoji:'🍽️',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'থ'),
  LearningItem(id:'bn-29',glyph:'দ',word:'দই',meaning:'দুধ দিয়ে তৈরি খাবার',emoji:'🥣',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'দ'),
  LearningItem(id:'bn-30',glyph:'ধ',word:'ধান',meaning:'চাল হয় যে শস্য থেকে',emoji:'🌾',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ধ'),
  LearningItem(id:'bn-31',glyph:'ন',word:'নৌকা',meaning:'পানিতে চলার বাহন',emoji:'🛶',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ন'),
  LearningItem(id:'bn-32',glyph:'প',word:'পাখি',meaning:'ডানা দিয়ে উড়ে',emoji:'🐦',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'প'),
  LearningItem(id:'bn-33',glyph:'ফ',word:'ফুল',meaning:'গাছে ফোটে',emoji:'🌸',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ফ'),
  LearningItem(id:'bn-34',glyph:'ব',word:'বল',meaning:'খেলার জিনিস',emoji:'⚽',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ব'),
  LearningItem(id:'bn-35',glyph:'ভ',word:'ভালুক',meaning:'বনের বড় প্রাণী',emoji:'🐻',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ভ'),
  LearningItem(id:'bn-36',glyph:'ম',word:'মাছ',meaning:'পানিতে থাকে',emoji:'🐠',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ম'),
  LearningItem(id:'bn-37',glyph:'য',word:'যমজ',meaning:'একসঙ্গে জন্মানো দুই শিশু',emoji:'👶👶',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'য'),
  LearningItem(id:'bn-38',glyph:'র',word:'রং',meaning:'ছবিকে সুন্দর করে',emoji:'🎨',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'র'),
  LearningItem(id:'bn-39',glyph:'ল',word:'লাটিম',meaning:'ঘুরিয়ে খেলা হয়',emoji:'🌀',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ল'),
  LearningItem(id:'bn-40',glyph:'শ',word:'শাপলা',meaning:'বাংলাদেশের জাতীয় ফুল',emoji:'🪷',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'শ'),
  LearningItem(id:'bn-41',glyph:'ষ',word:'ষাঁড়',meaning:'গরু পরিবারের প্রাণী',emoji:'🐂',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ষ'),
  LearningItem(id:'bn-42',glyph:'স',word:'সাপ',meaning:'সরীসৃপ প্রাণী',emoji:'🐍',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'স'),
  LearningItem(id:'bn-43',glyph:'হ',word:'হাতি',meaning:'বড় স্থলচর প্রাণী',emoji:'🐘',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'হ'),
  LearningItem(id:'bn-44',glyph:'ড়',word:'গাড়ি',meaning:'রাস্তায় চলে',emoji:'🚗',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ড়'),
  LearningItem(id:'bn-45',glyph:'ঢ়',word:'আষাঢ়',meaning:'বাংলা বর্ষার একটি মাস',emoji:'🌧️',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'ঢ়'),
  LearningItem(id:'bn-46',glyph:'য়',word:'সময়',meaning:'ঘড়িতে সময় দেখা যায়',emoji:'🕰️',language:'bn',category:'ব্যঞ্জনবর্ণ',reading:'য়'),
  LearningItem(id:'bn-47',glyph:'ৎ',word:'হঠাৎ',meaning:'অপ্রত্যাশিতভাবে',emoji:'⚡',language:'bn',category:'চিহ্ন',reading:'ৎ',isSign:true),
  LearningItem(id:'bn-48',glyph:'ং',word:'রং',meaning:'রঙের নাম',emoji:'🖍️',language:'bn',category:'চিহ্ন',reading:'ং',isSign:true),
  LearningItem(id:'bn-49',glyph:'ঃ',word:'দুঃখ',meaning:'মন খারাপের অনুভূতি',emoji:'😔',language:'bn',category:'চিহ্ন',reading:'ঃ',isSign:true),
  LearningItem(id:'bn-50',glyph:'ঁ',word:'চাঁদ',meaning:'চাঁদে চন্দ্রবিন্দু আছে',emoji:'🌙',language:'bn',category:'চিহ্ন',reading:'ঁ',isSign:true),
];

const englishLetters = <LearningItem>[
  LearningItem(id:'en-a',glyph:'A a',word:'Apple',meaning:'আপেল',emoji:'🍎',language:'en',category:'English A–Z',reading:'ay'),
  LearningItem(id:'en-b',glyph:'B b',word:'Ball',meaning:'বল',emoji:'⚽',language:'en',category:'English A–Z',reading:'bee'),
  LearningItem(id:'en-c',glyph:'C c',word:'Cat',meaning:'বিড়াল',emoji:'🐱',language:'en',category:'English A–Z',reading:'see'),
  LearningItem(id:'en-d',glyph:'D d',word:'Dog',meaning:'কুকুর',emoji:'🐶',language:'en',category:'English A–Z',reading:'dee'),
  LearningItem(id:'en-e',glyph:'E e',word:'Egg',meaning:'ডিম',emoji:'🥚',language:'en',category:'English A–Z',reading:'ee'),
  LearningItem(id:'en-f',glyph:'F f',word:'Fish',meaning:'মাছ',emoji:'🐟',language:'en',category:'English A–Z',reading:'ef'),
  LearningItem(id:'en-g',glyph:'G g',word:'Goat',meaning:'ছাগল',emoji:'🐐',language:'en',category:'English A–Z',reading:'jee'),
  LearningItem(id:'en-h',glyph:'H h',word:'Hat',meaning:'টুপি',emoji:'🎩',language:'en',category:'English A–Z',reading:'aych'),
  LearningItem(id:'en-i',glyph:'I i',word:'Ice cream',meaning:'আইসক্রিম',emoji:'🍦',language:'en',category:'English A–Z',reading:'eye'),
  LearningItem(id:'en-j',glyph:'J j',word:'Jug',meaning:'জগ',emoji:'🏺',language:'en',category:'English A–Z',reading:'jay'),
  LearningItem(id:'en-k',glyph:'K k',word:'Kite',meaning:'ঘুড়ি',emoji:'🪁',language:'en',category:'English A–Z',reading:'kay'),
  LearningItem(id:'en-l',glyph:'L l',word:'Lion',meaning:'সিংহ',emoji:'🦁',language:'en',category:'English A–Z',reading:'el'),
  LearningItem(id:'en-m',glyph:'M m',word:'Mango',meaning:'আম',emoji:'🥭',language:'en',category:'English A–Z',reading:'em'),
  LearningItem(id:'en-n',glyph:'N n',word:'Nest',meaning:'পাখির বাসা',emoji:'🪺',language:'en',category:'English A–Z',reading:'en'),
  LearningItem(id:'en-o',glyph:'O o',word:'Orange',meaning:'কমলা',emoji:'🍊',language:'en',category:'English A–Z',reading:'oh'),
  LearningItem(id:'en-p',glyph:'P p',word:'Parrot',meaning:'টিয়া পাখি',emoji:'🦜',language:'en',category:'English A–Z',reading:'pee'),
  LearningItem(id:'en-q',glyph:'Q q',word:'Queen',meaning:'রানি',emoji:'👑',language:'en',category:'English A–Z',reading:'cue'),
  LearningItem(id:'en-r',glyph:'R r',word:'Rabbit',meaning:'খরগোশ',emoji:'🐇',language:'en',category:'English A–Z',reading:'ar'),
  LearningItem(id:'en-s',glyph:'S s',word:'Sun',meaning:'সূর্য',emoji:'☀️',language:'en',category:'English A–Z',reading:'ess'),
  LearningItem(id:'en-t',glyph:'T t',word:'Tiger',meaning:'বাঘ',emoji:'🐅',language:'en',category:'English A–Z',reading:'tee'),
  LearningItem(id:'en-u',glyph:'U u',word:'Umbrella',meaning:'ছাতা',emoji:'☂️',language:'en',category:'English A–Z',reading:'you'),
  LearningItem(id:'en-v',glyph:'V v',word:'Van',meaning:'ছোট গাড়ি',emoji:'🚐',language:'en',category:'English A–Z',reading:'vee'),
  LearningItem(id:'en-w',glyph:'W w',word:'Watermelon',meaning:'তরমুজ',emoji:'🍉',language:'en',category:'English A–Z',reading:'double-you'),
  LearningItem(id:'en-x',glyph:'X x',word:'Xylophone',meaning:'এক ধরনের বাদ্যযন্ত্র',emoji:'🎼',language:'en',category:'English A–Z',reading:'ex'),
  LearningItem(id:'en-y',glyph:'Y y',word:'Yo-yo',meaning:'সুতা দিয়ে খেলার খেলনা',emoji:'🪀',language:'en',category:'English A–Z',reading:'why'),
  LearningItem(id:'en-z',glyph:'Z z',word:'Zebra',meaning:'ডোরাকাটা প্রাণী',emoji:'🦓',language:'en',category:'English A–Z',reading:'zee'),
];

const arabicLetters = <LearningItem>[
  LearningItem(id:'ar-01',glyph:'ا',word:'أَسَد',meaning:'সিংহ',emoji:'🦁',language:'ar',category:'Arabic Alif–Ya',reading:'Alif'),
  LearningItem(id:'ar-02',glyph:'ب',word:'بَيْت',meaning:'বাড়ি',emoji:'🏠',language:'ar',category:'Arabic Alif–Ya',reading:'Baa'),
  LearningItem(id:'ar-03',glyph:'ت',word:'تَاج',meaning:'মুকুট',emoji:'👑',language:'ar',category:'Arabic Alif–Ya',reading:'Taa'),
  LearningItem(id:'ar-04',glyph:'ث',word:'ثَوْب',meaning:'পোশাক',emoji:'👕',language:'ar',category:'Arabic Alif–Ya',reading:'Thaa'),
  LearningItem(id:'ar-05',glyph:'ج',word:'جَمَل',meaning:'উট',emoji:'🐪',language:'ar',category:'Arabic Alif–Ya',reading:'Jeem'),
  LearningItem(id:'ar-06',glyph:'ح',word:'حِصَان',meaning:'ঘোড়া',emoji:'🐎',language:'ar',category:'Arabic Alif–Ya',reading:'Haa'),
  LearningItem(id:'ar-07',glyph:'خ',word:'خُبْز',meaning:'রুটি',emoji:'🍞',language:'ar',category:'Arabic Alif–Ya',reading:'Khaa'),
  LearningItem(id:'ar-08',glyph:'د',word:'دَجَاج',meaning:'মুরগি',emoji:'🐔',language:'ar',category:'Arabic Alif–Ya',reading:'Daal'),
  LearningItem(id:'ar-09',glyph:'ذ',word:'ذَهَب',meaning:'সোনা',emoji:'🥇',language:'ar',category:'Arabic Alif–Ya',reading:'Dhaal'),
  LearningItem(id:'ar-10',glyph:'ر',word:'رُمَّان',meaning:'ডালিম',emoji:'🍎',language:'ar',category:'Arabic Alif–Ya',reading:'Raa'),
  LearningItem(id:'ar-11',glyph:'ز',word:'زَرَافَة',meaning:'জিরাফ',emoji:'🦒',language:'ar',category:'Arabic Alif–Ya',reading:'Zaay'),
  LearningItem(id:'ar-12',glyph:'س',word:'سَمَكَة',meaning:'মাছ',emoji:'🐠',language:'ar',category:'Arabic Alif–Ya',reading:'Seen'),
  LearningItem(id:'ar-13',glyph:'ش',word:'شَمْس',meaning:'সূর্য',emoji:'☀️',language:'ar',category:'Arabic Alif–Ya',reading:'Sheen'),
  LearningItem(id:'ar-14',glyph:'ص',word:'صَقْر',meaning:'বাজপাখি',emoji:'🦅',language:'ar',category:'Arabic Alif–Ya',reading:'Saad'),
  LearningItem(id:'ar-15',glyph:'ض',word:'ضِفْدَع',meaning:'ব্যাঙ',emoji:'🐸',language:'ar',category:'Arabic Alif–Ya',reading:'Daad'),
  LearningItem(id:'ar-16',glyph:'ط',word:'طَائِر',meaning:'পাখি',emoji:'🐦',language:'ar',category:'Arabic Alif–Ya',reading:'Taa'),
  LearningItem(id:'ar-17',glyph:'ظ',word:'ظَرْف',meaning:'খাম',emoji:'✉️',language:'ar',category:'Arabic Alif–Ya',reading:'Zaa'),
  LearningItem(id:'ar-18',glyph:'ع',word:'عَيْن',meaning:'চোখ',emoji:'👁️',language:'ar',category:'Arabic Alif–Ya',reading:'Ayn'),
  LearningItem(id:'ar-19',glyph:'غ',word:'غَيْم',meaning:'মেঘ',emoji:'☁️',language:'ar',category:'Arabic Alif–Ya',reading:'Ghayn'),
  LearningItem(id:'ar-20',glyph:'ف',word:'فِيل',meaning:'হাতি',emoji:'🐘',language:'ar',category:'Arabic Alif–Ya',reading:'Faa'),
  LearningItem(id:'ar-21',glyph:'ق',word:'قَمَر',meaning:'চাঁদ',emoji:'🌙',language:'ar',category:'Arabic Alif–Ya',reading:'Qaaf'),
  LearningItem(id:'ar-22',glyph:'ك',word:'كِتَاب',meaning:'বই',emoji:'📚',language:'ar',category:'Arabic Alif–Ya',reading:'Kaaf'),
  LearningItem(id:'ar-23',glyph:'ل',word:'لَبَن',meaning:'দুধ',emoji:'🥛',language:'ar',category:'Arabic Alif–Ya',reading:'Laam'),
  LearningItem(id:'ar-24',glyph:'م',word:'مَوْز',meaning:'কলা',emoji:'🍌',language:'ar',category:'Arabic Alif–Ya',reading:'Meem'),
  LearningItem(id:'ar-25',glyph:'ن',word:'نَجْم',meaning:'তারা',emoji:'⭐',language:'ar',category:'Arabic Alif–Ya',reading:'Noon'),
  LearningItem(id:'ar-26',glyph:'ه',word:'هِلَال',meaning:'চাঁদের বাঁকা অংশ',emoji:'🌙',language:'ar',category:'Arabic Alif–Ya',reading:'Haa'),
  LearningItem(id:'ar-27',glyph:'و',word:'وَرْدَة',meaning:'গোলাপ',emoji:'🌹',language:'ar',category:'Arabic Alif–Ya',reading:'Waaw'),
  LearningItem(id:'ar-28',glyph:'ي',word:'يَد',meaning:'হাত',emoji:'✋',language:'ar',category:'Arabic Alif–Ya',reading:'Yaa'),
];

const discoveryWords = <LearningItem>[
  LearningItem(id:'c-red',glyph:'●',word:'Red',meaning:'লাল',emoji:'🔴',language:'en',category:'রং',reading:'red'),
  LearningItem(id:'c-blue',glyph:'●',word:'Blue',meaning:'নীল',emoji:'🔵',language:'en',category:'রং',reading:'blue'),
  LearningItem(id:'c-yellow',glyph:'●',word:'Yellow',meaning:'হলুদ',emoji:'🟡',language:'en',category:'রং',reading:'yellow'),
  LearningItem(id:'c-green',glyph:'●',word:'Green',meaning:'সবুজ',emoji:'🟢',language:'en',category:'রং',reading:'green'),
  LearningItem(id:'c-orange',glyph:'●',word:'Orange',meaning:'কমলা',emoji:'🟠',language:'en',category:'রং',reading:'orange'),
  LearningItem(id:'c-purple',glyph:'●',word:'Purple',meaning:'বেগুনি',emoji:'🟣',language:'en',category:'রং',reading:'purple'),
  LearningItem(id:'s-circle',glyph:'○',word:'Circle',meaning:'বৃত্ত',emoji:'⚪',language:'en',category:'আকার',reading:'circle'),
  LearningItem(id:'s-square',glyph:'□',word:'Square',meaning:'বর্গ',emoji:'🟦',language:'en',category:'আকার',reading:'square'),
  LearningItem(id:'s-triangle',glyph:'△',word:'Triangle',meaning:'ত্রিভুজ',emoji:'🔺',language:'en',category:'আকার',reading:'triangle'),
  LearningItem(id:'s-rectangle',glyph:'▭',word:'Rectangle',meaning:'আয়তক্ষেত্র',emoji:'🟫',language:'en',category:'আকার',reading:'rectangle'),
  LearningItem(id:'s-star',glyph:'☆',word:'Star',meaning:'তারা',emoji:'⭐',language:'en',category:'আকার',reading:'star'),
  LearningItem(id:'s-heart',glyph:'♡',word:'Heart',meaning:'হৃদয়',emoji:'❤️',language:'en',category:'আকার',reading:'heart'),
  LearningItem(id:'f-mango',glyph:'🥭',word:'Mango',meaning:'আম',emoji:'🥭',language:'en',category:'ফল',reading:'mango'),
  LearningItem(id:'f-banana',glyph:'🍌',word:'Banana',meaning:'কলা',emoji:'🍌',language:'en',category:'ফল',reading:'banana'),
  LearningItem(id:'f-apple',glyph:'🍎',word:'Apple',meaning:'আপেল',emoji:'🍎',language:'en',category:'ফল',reading:'apple'),
  LearningItem(id:'f-orange',glyph:'🍊',word:'Orange',meaning:'কমলা',emoji:'🍊',language:'en',category:'ফল',reading:'orange'),
  LearningItem(id:'f-grapes',glyph:'🍇',word:'Grapes',meaning:'আঙুর',emoji:'🍇',language:'en',category:'ফল',reading:'grapes'),
  LearningItem(id:'f-watermelon',glyph:'🍉',word:'Watermelon',meaning:'তরমুজ',emoji:'🍉',language:'en',category:'ফল',reading:'watermelon'),
  LearningItem(id:'f-pineapple',glyph:'🍍',word:'Pineapple',meaning:'আনারস',emoji:'🍍',language:'en',category:'ফল',reading:'pineapple'),
  LearningItem(id:'f-coconut',glyph:'🥥',word:'Coconut',meaning:'নারিকেল',emoji:'🥥',language:'en',category:'ফল',reading:'coconut'),
  LearningItem(id:'v-potato',glyph:'🥔',word:'Potato',meaning:'আলু',emoji:'🥔',language:'en',category:'সবজি',reading:'potato'),
  LearningItem(id:'v-tomato',glyph:'🍅',word:'Tomato',meaning:'টমেটো',emoji:'🍅',language:'en',category:'সবজি',reading:'tomato'),
  LearningItem(id:'v-carrot',glyph:'🥕',word:'Carrot',meaning:'গাজর',emoji:'🥕',language:'en',category:'সবজি',reading:'carrot'),
  LearningItem(id:'v-eggplant',glyph:'🍆',word:'Eggplant',meaning:'বেগুন',emoji:'🍆',language:'en',category:'সবজি',reading:'eggplant'),
  LearningItem(id:'a-lion',glyph:'🦁',word:'Lion',meaning:'সিংহ',emoji:'🦁',language:'en',category:'প্রাণী',reading:'lion'),
  LearningItem(id:'a-elephant',glyph:'🐘',word:'Elephant',meaning:'হাতি',emoji:'🐘',language:'en',category:'প্রাণী',reading:'elephant'),
  LearningItem(id:'a-tiger',glyph:'🐅',word:'Tiger',meaning:'বাঘ',emoji:'🐅',language:'en',category:'প্রাণী',reading:'tiger'),
  LearningItem(id:'a-cow',glyph:'🐄',word:'Cow',meaning:'গরু',emoji:'🐄',language:'en',category:'প্রাণী',reading:'cow'),
  LearningItem(id:'a-goat',glyph:'🐐',word:'Goat',meaning:'ছাগল',emoji:'🐐',language:'en',category:'প্রাণী',reading:'goat'),
  LearningItem(id:'a-cat',glyph:'🐈',word:'Cat',meaning:'বিড়াল',emoji:'🐈',language:'en',category:'প্রাণী',reading:'cat'),
  LearningItem(id:'a-dog',glyph:'🐕',word:'Dog',meaning:'কুকুর',emoji:'🐕',language:'en',category:'প্রাণী',reading:'dog'),
  LearningItem(id:'a-rabbit',glyph:'🐇',word:'Rabbit',meaning:'খরগোশ',emoji:'🐇',language:'en',category:'প্রাণী',reading:'rabbit'),
  LearningItem(id:'b-bird',glyph:'🐦',word:'Bird',meaning:'পাখি',emoji:'🐦',language:'en',category:'পাখি',reading:'bird'),
  LearningItem(id:'b-duck',glyph:'🦆',word:'Duck',meaning:'হাঁস',emoji:'🦆',language:'en',category:'পাখি',reading:'duck'),
  LearningItem(id:'b-parrot',glyph:'🦜',word:'Parrot',meaning:'টিয়া',emoji:'🦜',language:'en',category:'পাখি',reading:'parrot'),
  LearningItem(id:'t-car',glyph:'🚗',word:'Car',meaning:'গাড়ি',emoji:'🚗',language:'en',category:'যানবাহন',reading:'car'),
  LearningItem(id:'t-bus',glyph:'🚌',word:'Bus',meaning:'বাস',emoji:'🚌',language:'en',category:'যানবাহন',reading:'bus'),
  LearningItem(id:'t-train',glyph:'🚆',word:'Train',meaning:'ট্রেন',emoji:'🚆',language:'en',category:'যানবাহন',reading:'train'),
  LearningItem(id:'t-plane',glyph:'✈️',word:'Plane',meaning:'বিমান',emoji:'✈️',language:'en',category:'যানবাহন',reading:'plane'),
  LearningItem(id:'t-boat',glyph:'🚤',word:'Boat',meaning:'নৌকা',emoji:'🚤',language:'en',category:'যানবাহন',reading:'boat'),
  LearningItem(id:'body-eye',glyph:'👁️',word:'Eye',meaning:'চোখ',emoji:'👁️',language:'en',category:'শরীর',reading:'eye'),
  LearningItem(id:'body-ear',glyph:'👂',word:'Ear',meaning:'কান',emoji:'👂',language:'en',category:'শরীর',reading:'ear'),
  LearningItem(id:'body-nose',glyph:'👃',word:'Nose',meaning:'নাক',emoji:'👃',language:'en',category:'শরীর',reading:'nose'),
  LearningItem(id:'body-hand',glyph:'✋',word:'Hand',meaning:'হাত',emoji:'✋',language:'en',category:'শরীর',reading:'hand'),
  LearningItem(id:'body-foot',glyph:'🦶',word:'Foot',meaning:'পা',emoji:'🦶',language:'en',category:'শরীর',reading:'foot'),
  LearningItem(id:'body-mouth',glyph:'👄',word:'Mouth',meaning:'মুখ',emoji:'👄',language:'en',category:'শরীর',reading:'mouth'),
  LearningItem(id:'family-mother',glyph:'👩',word:'Mother',meaning:'মা',emoji:'👩',language:'en',category:'পরিবার',reading:'mother'),
  LearningItem(id:'family-father',glyph:'👨',word:'Father',meaning:'বাবা',emoji:'👨',language:'en',category:'পরিবার',reading:'father'),
  LearningItem(id:'family-sister',glyph:'👧',word:'Sister',meaning:'বোন',emoji:'👧',language:'en',category:'পরিবার',reading:'sister'),
  LearningItem(id:'family-brother',glyph:'👦',word:'Brother',meaning:'ভাই',emoji:'👦',language:'en',category:'পরিবার',reading:'brother'),
  LearningItem(id:'nature-sun',glyph:'☀️',word:'Sun',meaning:'সূর্য',emoji:'☀️',language:'en',category:'প্রকৃতি',reading:'sun'),
  LearningItem(id:'nature-moon',glyph:'🌙',word:'Moon',meaning:'চাঁদ',emoji:'🌙',language:'en',category:'প্রকৃতি',reading:'moon'),
  LearningItem(id:'nature-cloud',glyph:'☁️',word:'Cloud',meaning:'মেঘ',emoji:'☁️',language:'en',category:'প্রকৃতি',reading:'cloud'),
  LearningItem(id:'nature-rain',glyph:'🌧️',word:'Rain',meaning:'বৃষ্টি',emoji:'🌧️',language:'en',category:'প্রকৃতি',reading:'rain'),
  LearningItem(id:'nature-tree',glyph:'🌳',word:'Tree',meaning:'গাছ',emoji:'🌳',language:'en',category:'প্রকৃতি',reading:'tree'),
  LearningItem(id:'nature-flower',glyph:'🌸',word:'Flower',meaning:'ফুল',emoji:'🌸',language:'en',category:'প্রকৃতি',reading:'flower'),
];

const _weekSeeds = <WeekSeed>[
  WeekSeed('স্বাগতম ছোট্ট শিক্ষার্থী','স্কুলের পরিবেশ, নিজের নাম, শুভেচ্ছা ও শ্রেণির নিয়ম','নিজের নাম বলো এবং বই-খাতা চিনে দেখাও'),
  WeekSeed('আমি কে?','নিজের পরিচয়, বয়স, পছন্দ ও অনুভূতি','আয়নার সামনে নিজের পরিচয় বলো'),
  WeekSeed('আমার শরীর','মাথা, চোখ, কান, নাক, হাত-পা ও ইন্দ্রিয়','নিজের শরীরের অঙ্গ দেখিয়ে নাম বলো'),
  WeekSeed('আমার পরিবার','মা, বাবা, ভাই-বোন ও পরিবারের সম্পর্ক','পরিবারের সদস্যদের ছবি দেখে পরিচয় দাও'),
  WeekSeed('আমার বাড়ি','ঘরের অংশ, আসবাব ও নিরাপদ আচরণ','বাড়ির তিনটি জিনিসের নাম বলো'),
  WeekSeed('আমার স্কুল','শ্রেণিকক্ষ, শিক্ষক, বন্ধু ও শিক্ষা-উপকরণ','ব্যাগ থেকে বই, খাতা ও পেন্সিল বের করো'),
  WeekSeed('রংধনুর রং','লাল, নীল, হলুদ, সবুজ, কমলা ও বেগুনি','ঘরে একই রঙের তিনটি বস্তু খুঁজে বের করো'),
  WeekSeed('আকারের জগৎ','বৃত্ত, বর্গ, ত্রিভুজ, আয়তক্ষেত্র ও তারকা','খেলনা দিয়ে আকার বানাও'),
  WeekSeed('রেখা ও হাতের নিয়ন্ত্রণ','সোজা, বাঁকা, ঢেউ, বিন্দু ও পেন্সিল ধরা','আঙুল দিয়ে বাতাসে রেখা আঁকো'),
  WeekSeed('গণিতের শুরু ১–৩','এক-এক করে গোনা, সংখ্যা চেনা ও পরিমাণ মেলানো','১, ২ ও ৩টি খেলনা গুনো'),
  WeekSeed('বাংলা স্বরবর্ণ','অ আ ই ঈ উ ঊ ঋ এ ঐ ও ঔ','স্বরবর্ণের কার্ড দেখে বলো'),
  WeekSeed('English A–C','A a, B b, C c এবং প্রথম ধ্বনি','Apple, Ball ও Cat-এর ছবি মিলাও'),
  WeekSeed('Arabic Alif–Taa','ا ب ت এবং সহজ শব্দ শোনা','আলিফ, বা, তা শুনে পুনরাবৃত্তি করো'),
  WeekSeed('বাংলা ব্যঞ্জনবর্ণ ১','ক খ গ ঘ ঙ এবং শব্দের শুরু','ক-খ-গ দিয়ে ছবি খুঁজে দেখাও'),
  WeekSeed('বাংলা ব্যঞ্জনবর্ণ ২','চ ছ জ ঝ ঞ এবং শব্দের শুরু','ছবি দেখে প্রথম বর্ণটি বলো'),
  WeekSeed('English D–H','D, E, F, G, H; letter names ও sounds','ছবি দেখে সঠিক অক্ষর বেছে নাও'),
  WeekSeed('Arabic Thaa–Khaa','ث ج ح خ এবং শব্দ শোনা','আরবি হরফের আকৃতি চেনো'),
  WeekSeed('ফল ও স্বাদ','আম, কলা, আপেল, কমলা, আঙুর ও তরমুজ','ফলগুলো রঙ ও আকার দিয়ে আলাদা করো'),
  WeekSeed('সবজি ও স্বাস্থ্যকর খাবার','আলু, টমেটো, গাজর, বেগুন ও খাবারের পরিচয়','খাবারের ছবি ফল না সবজি আলাদা করো'),
  WeekSeed('গৃহপালিত প্রাণী','গরু, ছাগল, বিড়াল, কুকুর ও খরগোশ','প্রাণীর ডাক ও ছবি মিলাও'),
  WeekSeed('বন্য প্রাণী ও পাখি','সিংহ, হাতি, বাঘ, পাখি, হাঁস ও টিয়া','কোন প্রাণী কোথায় থাকে বলো'),
  WeekSeed('গণিত ৪–৫','চার-পাঁচ গোনা, বেশি-কম ও সংখ্যা সাজানো','৪ ও ৫টি বস্তু পাশাপাশি গুনো'),
  WeekSeed('বিপরীত শব্দ','বড়-ছোট, লম্বা-খাটো, কাছে-দূরে, ভেতর-বাইরে','বস্তু সাজিয়ে বিপরীত বোঝাও'),
  WeekSeed('পুনরাবৃত্তি ও প্যাটার্ন','রং, আকার ও সংখ্যা দিয়ে সহজ প্যাটার্ন','লাল-নীল-লাল-নীল ধারাটি শেষ করো'),
  WeekSeed('বাংলা ব্যঞ্জনবর্ণ ৩','ট ঠ ড ঢ ণ ত থ দ ধ ন','বর্ণ দেখে শব্দ ও ছবি মিলাও'),
  WeekSeed('English I–N','I, J, K, L, M, N; বড়-ছোট হাতের অক্ষর','বর্ণের সঙ্গে সঠিক ছবি জোড়া লাগাও'),
  WeekSeed('Arabic Daal–Sheen','د ذ ر ز س ش এবং শব্দের পরিচয়','হরফের শব্দ শুনে চিনে নাও'),
  WeekSeed('গণিত ৬–৭','ছয়-সাত গোনা ও সংখ্যার ক্রম','৬ ও ৭টি ব্লক সাজাও'),
  WeekSeed('প্রকৃতি ও আবহাওয়া','সূর্য, চাঁদ, মেঘ, বৃষ্টি, গাছ ও ফুল','আজকের আকাশ দেখে আবহাওয়া বলো'),
  WeekSeed('পানি ও পরিচ্ছন্নতা','পানির ব্যবহার, হাত ধোয়া ও পরিষ্কার থাকা','সঠিকভাবে হাত ধোয়ার ধাপ সাজাও'),
  WeekSeed('গাছপালা ও জীবনের চক্র','বীজ, চারা, গাছ, ফুল ও ফল','একটি বীজ লাগিয়ে প্রতিদিন দেখো'),
  WeekSeed('স্বাস্থ্য ও নিরাপত্তা','শরীরের যত্ন, নিরাপদ-অনিরাপদ স্পর্শের ধারণা','বিশ্বস্ত বড়দের কাছে সাহায্য চাওয়ার অনুশীলন'),
  WeekSeed('ভদ্রতা ও ভালো অভ্যাস','ধন্যবাদ, দয়া করে, দুঃখিত, ভাগাভাগি','খেলার সময় পালা মেনে চলো'),
  WeekSeed('শব্দের ধ্বনি ও ছড়া','প্রথম ধ্বনি, ছন্দ, মিলযুক্ত শব্দ ও শোনা','ছোট ছড়া শুনে শেষ শব্দটি বলো'),
  WeekSeed('গণিত ৮–৯','আট-নয় গোনা, তুলনা ও সংখ্যা চেনা','৮ ও ৯টি বস্তু গুনে আলাদা করো'),
  WeekSeed('ত্রিমাত্রিক আকার','গোলক, ঘনক, বেলন ও চারপাশের বস্তু','বল, বাক্স ও কৌটার আকার দেখো'),
  WeekSeed('ছবি দেখে গল্প','শুরু-মাঝ-শেষ এবং নিজের ভাষায় বলা','তিনটি ছবি সাজিয়ে গল্প বলো'),
  WeekSeed('যানবাহন ও চলাচল','গাড়ি, বাস, ট্রেন, বিমান, নৌকা ও রাস্তার নিয়ম','যানবাহনের শব্দ ও ছবি মিলাও'),
  WeekSeed('বাংলা ব্যঞ্জনবর্ণ ৪','প ফ ব ভ ম য র ল শ ষ স হ','বর্ণ থেকে পরিচিত শব্দ বলো'),
  WeekSeed('English O–T','O, P, Q, R, S, T; sound recognition','ছবি থেকে শুরুর অক্ষর খুঁজে বের করো'),
  WeekSeed('Arabic Saad–Ayn','ص ض ط ظ ع এবং শব্দ শোনা','আরবি হরফের কার্ড সাজাও'),
  WeekSeed('গণিত ১০','দশ পর্যন্ত গোনা, ১০-এর পরিমাণ বোঝা','দশটি ছোট বস্তু গুনে একসঙ্গে রাখো'),
  WeekSeed('বাংলা শেষ বর্ণ ও চিহ্ন','ড় ঢ় য় ৎ ং ঃ ঁ এবং ব্যবহার পরিচিতি','শব্দে চিহ্ন খুঁজে দেখো'),
  WeekSeed('English U–Z','U, V, W, X, Y, Z; A–Z পুনরালোচনা','A থেকে Z কার্ড সঠিক ক্রমে সাজাও'),
  WeekSeed('Arabic Ghayn–Ya','غ ف ق ك ل م ن ه و ي','আলিফ থেকে ইয়া পর্যন্ত হরফ বলো'),
  WeekSeed('সহজ যোগ','বস্তু একত্র করে ১+১, ২+১ বোঝা','দুই দলে খেলনা যোগ করো'),
  WeekSeed('সহজ বিয়োগ','বস্তু সরিয়ে কমে যাওয়া বোঝা','তিনটি বস্তু থেকে একটি সরাও'),
  WeekSeed('সময়, দিন ও ঋতু','সকাল-দুপুর-রাত, সপ্তাহের দিন, ঋতু','আজ কী বার ও এখন কোন সময় বলো'),
  WeekSeed('শোনা, বলা ও সহযোগিতা','নির্দেশ অনুসরণ, পালা নেওয়া ও দলীয় কাজ','একটি সহজ নির্দেশ শুনে কাজ করো'),
  WeekSeed('সব বর্ণের বড় পুনরালোচনা','বাংলা ৫০, English ২৬ ও Arabic ২৮ বর্ণ','মিশ্র কার্ড থেকে পরিচিত বর্ণ বেছে নাও'),
  WeekSeed('আমার প্রথম শেখার প্রদর্শনী','১–১০, পরিচিত শব্দ, ছবি, আকার ও গল্প','পরিবারকে নিজের পছন্দের পাঠ শেখাও'),
  WeekSeed('আনন্দের মূল্যায়ন ও উদযাপন','শেখা দক্ষতার নমনীয় পুনরালোচনা ও পরবর্তী লক্ষ্য','প্রশংসা, স্টিকার ও সনদ দিয়ে উদযাপন করো'),
];

class WeekSeed {
  const WeekSeed(this.title, this.focus, this.homeActivity);
  final String title, focus, homeActivity;
}

class WeekPlan {
  const WeekPlan({required this.week, required this.term, required this.title, required this.focus, required this.homeActivity});
  final int week;
  final String term, title, focus, homeActivity;
}

final yearPlan = List<WeekPlan>.generate(_weekSeeds.length, (index) {
  final termIndex = index ~/ 13;
  const terms = ['Term 1 • Getting Ready', 'Term 2 • Words & Discovery', 'Term 3 • Growing Skills', 'Term 4 • Confident Learner'];
  return WeekPlan(
    week: index + 1,
    term: terms[termIndex],
    title: _weekSeeds[index].title,
    focus: _weekSeeds[index].focus,
    homeActivity: _weekSeeds[index].homeActivity,
  );
});

final mathNumbers = List<LearningItem>.generate(10, (index) {
  const english = ['One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten'];
  const bangla = ['এক','দুই','তিন','চার','পাঁচ','ছয়','সাত','আট','নয়','দশ'];
  const emoji = ['🍎','🍎🍎','🍎🍎🍎','⭐ ⭐ ⭐ ⭐','⚽ ⚽ ⚽ ⚽ ⚽','🌼 🌼 🌼 🌼 🌼 🌼','🐥 🐥 🐥 🐥 🐥 🐥 🐥','🟣 🟣 🟣 🟣 🟣 🟣 🟣 🟣','🍓 🍓 🍓 🍓 🍓 🍓 🍓 🍓 🍓','🌟 🌟 🌟 🌟 🌟 🌟 🌟 🌟 🌟 🌟'];
  final n = index + 1;
  return LearningItem(
    id: 'num-$n',
    glyph: '$n  •  ${['১','২','৩','৪','৫','৬','৭','৮','৯','১০'][index]}',
    word: english[index],
    meaning: bangla[index],
    emoji: emoji[index],
    language: 'en',
    category: 'গণিত ১–১০',
    reading: english[index].toLowerCase(),
  );
});

List<LearningItem> get allLearningItems => [
  ...banglaLetters, ...englishLetters, ...arabicLetters, ...mathNumbers, ...discoveryWords,
];

List<LearningItem> itemsForBook(String id) {
  switch (id) {
    case 'bangla': return banglaLetters;
    case 'english': return englishLetters;
    case 'arabic': return arabicLetters;
    case 'math': return mathNumbers;
    case 'world': return discoveryWords;
    default: return allLearningItems;
  }
}
