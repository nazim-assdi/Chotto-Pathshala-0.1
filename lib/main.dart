import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'learning_data.dart';
import 'speech_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.load();
  runApp(const ChottoPathshalaApp());
}

class AppStore {
  static final skin = ValueNotifier<String>('sage');
  static final completed = ValueNotifier<Set<String>>(<String>{});
  static final stars = ValueNotifier<int>(0);
  static final sound = ValueNotifier<bool>(true);
  static bool soundEnabled = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    skin.value = prefs.getString('theme') ?? 'sage';
    completed.value = (prefs.getStringList('completed_items') ?? <String>[]).toSet();
    stars.value = prefs.getInt('stars') ?? 0;
    soundEnabled = prefs.getBool('sound_enabled') ?? true;
    sound.value = soundEnabled;
    SpeechService.enabled = soundEnabled;
  }

  static Future<void> setSkin(String value) async {
    skin.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
  }

  static Future<void> mark(String id) async {
    final next = {...completed.value, id};
    completed.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_items', next.toList());
  }

  static Future<void> addStars(int amount) async {
    stars.value += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stars', stars.value);
  }

  static Future<void> setSound(bool value) async {
    soundEnabled = value;
    sound.value = value;
    SpeechService.enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
  }
}

class AppSkin {
  const AppSkin({
    required this.id, required this.name, required this.description,
    required this.primary, required this.secondary, required this.background,
    required this.surface, required this.ink, required this.muted,
    required this.line, required this.accent, required this.radius,
    required this.layout, this.dark = false,
  });
  final String id, name, description;
  final Color primary, secondary, background, surface, ink, muted, line, accent;
  final double radius;
  final int layout;
  final bool dark;
}

const appSkins = <AppSkin>[
  AppSkin(id:'sage',name:'Sage Garden',description:'শান্ত সবুজ • চোখের আরাম',primary:Color(0xFF527B68),secondary:Color(0xFFA8C8B4),background:Color(0xFFF0F4EE),surface:Color(0xFFFAFCF8),ink:Color(0xFF263B32),muted:Color(0xFF718278),line:Color(0xFFDCE6DC),accent:Color(0xFFE8D8AE),radius:25,layout:0),
  AppSkin(id:'sky',name:'Soft Sky',description:'হালকা নীল • খোলা আকাশের মতো',primary:Color(0xFF547C9C),secondary:Color(0xFFB7D2E2),background:Color(0xFFF0F5F8),surface:Color(0xFFFBFDFE),ink:Color(0xFF273C4B),muted:Color(0xFF748A98),line:Color(0xFFDCE7EC),accent:Color(0xFFE9DDB8),radius:18,layout:1),
  AppSkin(id:'lavender',name:'Lavender Mist',description:'নরম বেগুনি • কোমল পাতা',primary:Color(0xFF81749B),secondary:Color(0xFFC7BDDA),background:Color(0xFFF4F1F7),surface:Color(0xFFFFFDFF),ink:Color(0xFF39344A),muted:Color(0xFF817A8D),line:Color(0xFFE4DDEA),accent:Color(0xFFEAD8D2),radius:31,layout:2),
  AppSkin(id:'paper',name:'Warm Paper',description:'কাগজের রং • বইয়ের পাতার অনুভূতি',primary:Color(0xFF896F53),secondary:Color(0xFFD8C6A9),background:Color(0xFFF5F0E6),surface:Color(0xFFFFFCF5),ink:Color(0xFF40382D),muted:Color(0xFF857A6B),line:Color(0xFFE6DCCB),accent:Color(0xFFE9D8A6),radius:13,layout:3),
  AppSkin(id:'night',name:'Night Reader',description:'নরম রাতের নীল • কম আলো',primary:Color(0xFF9BBCC4),secondary:Color(0xFF536B79),background:Color(0xFF202D36),surface:Color(0xFF293943),ink:Color(0xFFE7EEF0),muted:Color(0xFFB2C0C5),line:Color(0xFF40545E),accent:Color(0xFF786B4F),radius:22,layout:4,dark:true),
];

AppSkin get currentSkin => appSkins.firstWhere((s) => s.id == AppStore.skin.value, orElse: () => appSkins.first);

ThemeData buildTheme(AppSkin skin) {
  final scheme = ColorScheme.fromSeed(seedColor: skin.primary, brightness: skin.dark ? Brightness.dark : Brightness.light)
      .copyWith(primary: skin.primary, secondary: skin.secondary, surface: skin.surface, onSurface: skin.ink);
  return ThemeData(
    useMaterial3: true,
    brightness: skin.dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: skin.background,
    canvasColor: skin.background,
    cardColor: skin.surface,
    dividerColor: skin.line,
    appBarTheme: AppBarTheme(backgroundColor: skin.background, foregroundColor: skin.ink, elevation: 0, centerTitle: false, titleTextStyle: TextStyle(color: skin.ink,fontSize:19,fontWeight:FontWeight.w800)),
    cardTheme: CardThemeData(color: skin.surface, elevation: skin.dark ? 1 : 1.5, shadowColor: skin.primary.withOpacity(.08), margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(skin.radius), side: BorderSide(color: skin.line))),
    textTheme: ThemeData(brightness: skin.dark ? Brightness.dark : Brightness.light).textTheme.apply(bodyColor:skin.ink,displayColor:skin.ink),
    navigationBarTheme: NavigationBarThemeData(backgroundColor:skin.surface,indicatorColor:skin.secondary.withOpacity(.28),labelTextStyle:WidgetStateProperty.all(TextStyle(color:skin.ink,fontSize:11,fontWeight:FontWeight.w700))),
    inputDecorationTheme: InputDecorationTheme(filled:true,fillColor:skin.surface,border:OutlineInputBorder(borderRadius:BorderRadius.circular(skin.radius),borderSide:BorderSide(color:skin.line)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(skin.radius),borderSide:BorderSide(color:skin.line))),
    filledButtonTheme: FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:skin.primary,foregroundColor:skin.dark?const Color(0xFF17242B):Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(skin.radius)))),
  );
}

class ChottoPathshalaApp extends StatelessWidget {
  const ChottoPathshalaApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable:AppStore.skin,
    builder:(context,_,__) => MaterialApp(
      title:'ছোট্ট পাঠশালা',
      debugShowCheckedModeBanner:false,
      theme:buildTheme(currentSkin),
      home:const MainShell(),
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState()=>_MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index=0;
  void _openSettings()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SettingsPage()));
  void _openPlan()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const YearPlanPage()));
  void _openParents()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const ParentPage()));

  @override
  Widget build(BuildContext context) {
    final pages=<Widget>[
      TodayPage(onBooks:()=>setState(()=>index=1),onGame:()=>setState(()=>index=2),onPlan:_openPlan,onParents:_openParents),
      const BookShelfPage(),
      const GamePage(),
      const ProgressPage(),
    ];
    return Scaffold(
      appBar:AppBar(
        leading:Padding(padding:const EdgeInsets.all(7),child:ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.asset('assets/icon/app_icon.png',fit:BoxFit.cover))),
        title:const Text('ছোট্ট পাঠশালা'),
        actions:[IconButton(tooltip:'এক বছরের পাঠপরিকল্পনা',onPressed:_openPlan,icon:const Icon(Icons.calendar_month_outlined)),IconButton(tooltip:'সেটিংস ও থিম',onPressed:_openSettings,icon:const Icon(Icons.tune_rounded))],
      ),
      body:IndexedStack(index:index,children:pages),
      bottomNavigationBar:NavigationBar(
        selectedIndex:index,
        onDestinationSelected:(v)=>setState(()=>index=v),
        destinations:const[
          NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home_rounded),label:'আজ'),
          NavigationDestination(icon:Icon(Icons.menu_book_outlined),selectedIcon:Icon(Icons.menu_book_rounded),label:'আমার বই'),
          NavigationDestination(icon:Icon(Icons.toys_outlined),selectedIcon:Icon(Icons.toys_rounded),label:'খেলা'),
          NavigationDestination(icon:Icon(Icons.emoji_events_outlined),selectedIcon:Icon(Icons.emoji_events),label:'অগ্রগতি'),
        ],
      ),
    );
  }
}

class BookInfo {
  const BookInfo(this.id,this.title,this.subtitle,this.emoji,this.count,this.tint);
  final String id,title,subtitle,emoji;
  final int count;
  final Color tint;
}
const books=<BookInfo>[
  BookInfo('bangla','বাংলা বর্ণমালা','স্বরবর্ণ, ব্যঞ্জনবর্ণ ও শব্দ','অ',50,Color(0xFFDCEBDD)),
  BookInfo('english','English A–Z','২৬টি letter, sound ও picture word','Aa',26,Color(0xFFDCEAF3)),
  BookInfo('arabic','আরবি আলিফ–ইয়া','২৮টি হরফ ও সহজ আরবি শব্দ','ا',28,Color(0xFFE9E2F1)),
  BookInfo('math','গণিত ১–১০','সংখ্যা, গোনা ও পরিমাণ','🔢',10,Color(0xFFF1E7D2)),
  BookInfo('world','আমার পৃথিবী','রং, আকার, ফল, প্রাণী ও চারপাশ','🌍',56,Color(0xFFF2E3E4)),
];

class TodayPage extends StatelessWidget {
  const TodayPage({super.key,required this.onBooks,required this.onGame,required this.onPlan,required this.onParents});
  final VoidCallback onBooks,onGame,onPlan,onParents;

  @override
  Widget build(BuildContext context) {
    final skin=currentSkin;
    return ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:[
      _WelcomeBanner(skin:skin,onTap:onBooks),
      const SizedBox(height:16),
      Row(children:[
        Expanded(child:_MiniStat(icon:'📚',value:'৪টি',label:'মূল বিষয়')),
        const SizedBox(width:8),
        Expanded(child:_MiniStat(icon:'🗓️',value:'৫২',label:'সাপ্তাহিক পাঠ')),
        const SizedBox(width:8),
        Expanded(child:_MiniStat(icon:'⭐',value:'${AppStore.stars.value}',label:'তারকা')),
      ]),
      const SizedBox(height:23),
      Row(children:[Expanded(child:Text('তোমার বইয়ের তাক',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900))),TextButton(onPressed:onBooks,child:const Text('সব বই দেখো'))]),
      _HomeBookPreview(onTap:onBooks),
      const SizedBox(height:20),
      _ActionTile(emoji:'🎲',title:'খেলতে খেলতে শিখি',subtitle:'ছবি দেখে শব্দ বেছে নাও, সঠিক উত্তরে তারকা পাও',onTap:onGame),
      const SizedBox(height:10),
      _ActionTile(emoji:'🗓️',title:'এক বছরের শেখার পরিকল্পনা',subtitle:'৪টি টার্ম • ৫২ সপ্তাহ • ধাপে ধাপে শেখা',onTap:onPlan),
      const SizedBox(height:10),
      _ActionTile(emoji:'👨‍👩‍👧',title:'অভিভাবক কর্নার',subtitle:'খেলার মাধ্যমে শেখাতে ছোট ছোট পরামর্শ',onTap:onParents),
      const SizedBox(height:20),
      const _DailyNote(),
    ]);
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.skin,required this.onTap});
  final AppSkin skin;final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final paper=skin.layout==3;
    return InkWell(
      borderRadius:BorderRadius.circular(skin.radius),
      onTap:onTap,
      child:Container(
        padding:const EdgeInsets.all(20),
        decoration:BoxDecoration(
          color:paper?skin.surface:null,
          gradient:paper?null:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[skin.primary,skin.primary.withOpacity(.78),skin.secondary]),
          borderRadius:BorderRadius.circular(skin.radius),
          border:paper?Border.all(color:skin.line,width:2):null,
        ),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Expanded(child:Text('আজ একটু শিখি, হেসে হেসে বড় হই!',style:TextStyle(color:paper?skin.ink:Colors.white,fontSize:24,fontWeight:FontWeight.w900,height:1.25))),
            const SizedBox(width:10),
            const Text('🌈',style:TextStyle(fontSize:53)),
          ]),
          const SizedBox(height:8),
          Text('ছবি • শব্দ • উচ্চারণ • খেলা',style:TextStyle(color:paper?skin.muted:Colors.white.withOpacity(.92),fontWeight:FontWeight.w600)),
          const SizedBox(height:15),
          Row(children:[
            Icon(Icons.auto_stories_rounded,size:17,color:paper?skin.primary:Colors.white),
            const SizedBox(width:7),
            Text('আমার প্রথম শেখার বই খুলে দেখি',style:TextStyle(color:paper?skin.primary:Colors.white,fontWeight:FontWeight.w800)),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded,color:paper?skin.primary:Colors.white),
          ]),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon,required this.value,required this.label});
  final String icon,value,label;
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.symmetric(vertical:12,horizontal:5),child:Column(children:[Text(icon,style:const TextStyle(fontSize:23)),const SizedBox(height:4),Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),Text(label,style:TextStyle(fontSize:11,color:currentSkin.muted))])));
}

class _HomeBookPreview extends StatelessWidget {
  const _HomeBookPreview({required this.onTap});
  final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    final skin=currentSkin;
    final first=books.take(4).toList();
    if(skin.layout==2) {
      return SizedBox(height:145,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:first.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(context,i)=>SizedBox(width:185,child:_BookCard(book:first[i],onTap:onTap,compact:true))));
    }
    return GridView.builder(
      itemCount:first.length,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
      gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:skin.layout==3?2:2,childAspectRatio:skin.layout==3?2.55:1.38,crossAxisSpacing:10,mainAxisSpacing:10),
      itemBuilder:(context,i)=>_BookCard(book:first[i],onTap:onTap,compact:skin.layout==3),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book,required this.onTap,this.compact=false});
  final BookInfo book;final VoidCallback onTap;final bool compact;
  @override Widget build(BuildContext context)=>Card(color:currentSkin.surface,child:InkWell(borderRadius:BorderRadius.circular(currentSkin.radius),onTap:onTap,child:Padding(padding:EdgeInsets.all(compact?10:14),child:Row(children:[
    Container(width:compact?40:48,height:compact?40:48,alignment:Alignment.center,decoration:BoxDecoration(color:book.tint,borderRadius:BorderRadius.circular(15)),child:Text(book.emoji,style:TextStyle(fontSize:compact?22:27))),
    const SizedBox(width:10),
    Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(book.title,style:TextStyle(fontWeight:FontWeight.w900,fontSize:compact?13:14),maxLines:1,overflow:TextOverflow.ellipsis),
      Text('${book.count}টি কার্ড',style:TextStyle(color:currentSkin.muted,fontSize:11)),
    ])),
  ]))));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.emoji,required this.title,required this.subtitle,required this.onTap});
  final String emoji,title,subtitle;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Card(child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:7),leading:CircleAvatar(radius:25,backgroundColor:currentSkin.secondary.withOpacity(.22),child:Text(emoji,style:const TextStyle(fontSize:24))),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(subtitle,style:TextStyle(color:currentSkin.muted,fontSize:12)),trailing:const Icon(Icons.chevron_right),onTap:onTap));
}

class _DailyNote extends StatelessWidget {
  const _DailyNote();
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('💚',style:TextStyle(fontSize:26)),const SizedBox(width:12),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('একটু একটু করেই শেখা',style:TextStyle(fontWeight:FontWeight.w900)),
      const SizedBox(height:4),
      Text('প্রতিদিন ১৫–২০ মিনিট যথেষ্ট। শিশুকে চাপ নয়, উৎসাহ দাও; চেষ্টা করলেই প্রশংসা করো।',style:TextStyle(color:currentSkin.muted,height:1.45)),
    ])),
  ])));
}

class BookShelfPage extends StatelessWidget {
  const BookShelfPage({super.key});
  void _open(BuildContext context,BookInfo book)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BookPage(book:book)));
  @override
  Widget build(BuildContext context) {
    final skin=currentSkin;
    return ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:[
      Text('একটি বই বেছে নাও',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),
      const SizedBox(height:5),
      Text('প্রতিটি বইয়ের পাতায় বড় বর্ণ, ছবি, শব্দ ও উচ্চারণ আছে।',style:TextStyle(color:skin.muted)),
      const SizedBox(height:18),
      if(skin.layout==1 || skin.layout==4)
        ...books.map((b)=>Padding(padding:const EdgeInsets.only(bottom:11),child:_ShelfRow(book:b,onTap:()=>_open(context,b))))
      else if(skin.layout==2)
        SizedBox(height:215,child:PageView.builder(itemCount:books.length,controller:PageController(viewportFraction:.88),itemBuilder:(context,i)=>Padding(padding:const EdgeInsets.only(right:10),child:_LargeBook(book:books[i],onTap:()=>_open(context,books[i])))))
      else
        GridView.builder(itemCount:books.length,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:1.12,crossAxisSpacing:12,mainAxisSpacing:12),itemBuilder:(context,i)=>_LargeBook(book:books[i],onTap:()=>_open(context,books[i]))),
      const SizedBox(height:20),
      Card(child:ListTile(leading:const Text('🗓️',style:TextStyle(fontSize:27)),title:const Text('এক বছরের পাঠপরিকল্পনা',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:const Text('৫২ সপ্তাহে কী কী শিখবে দেখো'),trailing:const Icon(Icons.arrow_forward),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const YearPlanPage())))),
    ]);
  }
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({required this.book,required this.onTap});
  final BookInfo book;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(currentSkin.radius),child:Padding(padding:const EdgeInsets.all(15),child:Row(children:[
    Container(width:68,height:68,alignment:Alignment.center,decoration:BoxDecoration(color:book.tint,borderRadius:BorderRadius.circular(17)),child:Text(book.emoji,style:const TextStyle(fontSize:33))),
    const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(book.title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)),Text(book.subtitle,style:TextStyle(color:currentSkin.muted,fontSize:12)),Text('${book.count}টি শেখার কার্ড',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w800,fontSize:12))])),const Icon(Icons.chevron_right),
  ]))));
}

class _LargeBook extends StatelessWidget {
  const _LargeBook({required this.book,required this.onTap});
  final BookInfo book;final VoidCallback onTap;
  @override Widget build(BuildContext context)=>Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(currentSkin.radius),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:Container(width:double.infinity,decoration:BoxDecoration(color:book.tint,borderRadius:BorderRadius.circular(currentSkin.radius)),alignment:Alignment.center,child:Text(book.emoji,style:const TextStyle(fontSize:48)))),
    const SizedBox(height:10),Text(book.title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:15)),Text('${book.count}টি ছবি ও শব্দ',style:TextStyle(color:currentSkin.muted,fontSize:12)),
  ]))));
}

class BookPage extends StatefulWidget {
  const BookPage({super.key,required this.book});
  final BookInfo book;
  @override State<BookPage> createState()=>_BookPageState();
}
class _BookPageState extends State<BookPage> {
  String category='সব';
  @override Widget build(BuildContext context) {
    final all=itemsForBook(widget.book.id);
    final cats=all.map((e)=>e.category).toSet().toList();
    final items=category=='সব'?all:all.where((e)=>e.category==category).toList();
    return Scaffold(
      appBar:AppBar(title:Text(widget.book.title)),
      body:Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(15,4,15,8),child:Row(children:[Expanded(child:Text(widget.book.subtitle,style:TextStyle(color:currentSkin.muted))),Text('${items.length}টি কার্ড',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900))])),
        if(cats.length>1) SizedBox(height:44,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),children:[
          Padding(padding:const EdgeInsets.only(right:6),child:ChoiceChip(label:const Text('সব'),selected:category=='সব',onSelected:(_)=>setState(()=>category='সব'))),
          ...cats.map((c)=>Padding(padding:const EdgeInsets.only(right:6),child:ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>setState(()=>category=c)))),
        ])),
        Expanded(child:GridView.builder(
          padding:const EdgeInsets.fromLTRB(14,8,14,24),itemCount:items.length,
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:.95,crossAxisSpacing:11,mainAxisSpacing:11),
          itemBuilder:(context,i)=>LearningCard(item:items[i],onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ItemPage(item:items[i])))),
        )),
      ]),
    );
  }
}

class LearningCard extends StatelessWidget {
  const LearningCard({super.key,required this.item,required this.onTap});
  final LearningItem item;final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    final done=AppStore.completed.value.contains(item.id);
    return Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(currentSkin.radius),child:Padding(padding:const EdgeInsets.all(11),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Row(children:[Expanded(child:Text(item.glyph,style:TextStyle(fontSize:item.language=='ar'?30:27,fontWeight:FontWeight.w900),textAlign:TextAlign.center)),if(done)Icon(Icons.check_circle,color:currentSkin.primary,size:17)]),
      const SizedBox(height:4),Text(item.emoji,style:const TextStyle(fontSize:37)),
      const SizedBox(height:4),Text(item.word,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w900),maxLines:1,overflow:TextOverflow.ellipsis),
      Text(item.meaning,style:TextStyle(color:currentSkin.muted,fontSize:12),maxLines:1,overflow:TextOverflow.ellipsis),
      const SizedBox(height:4),Icon(Icons.volume_up_rounded,size:17,color:currentSkin.primary),
    ]))));
  }
}

class ItemPage extends StatelessWidget {
  const ItemPage({super.key,required this.item});
  final LearningItem item;
  @override
  Widget build(BuildContext context) {
    final arabic=item.language=='ar';
    final english=item.language=='en';
    return Scaffold(
      appBar:AppBar(title:Text(item.category)),
      body:ListView(padding:const EdgeInsets.all(18),children:[
        Card(child:Padding(padding:const EdgeInsets.fromLTRB(18,24,18,22),child:Column(children:[
          Text(item.glyph,textAlign:TextAlign.center,style:TextStyle(fontSize:arabic?88:76,fontWeight:FontWeight.w900,color:currentSkin.primary,height:1.25)),
          const SizedBox(height:7),Text(item.emoji,style:const TextStyle(fontSize:80)),
          const SizedBox(height:8),Text(item.word,textAlign:TextAlign.center,style:TextStyle(fontSize:28,fontWeight:FontWeight.w900,color:currentSkin.ink)),
          const SizedBox(height:5),Text(item.meaning,style:TextStyle(fontSize:18,color:currentSkin.muted)),
          if(item.reading.isNotEmpty) Padding(padding:const EdgeInsets.only(top:5),child:Text(item.reading,style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w700))),
        ]))),
        const SizedBox(height:14),
        FilledButton.icon(onPressed:()=>SpeechService.speak(item),icon:const Icon(Icons.volume_up_rounded),label:Text(english?'শব্দের উচ্চারণ শুনি':arabic?'আরবি উচ্চারণ শুনি':'শব্দটি শুনি')),
        const SizedBox(height:9),
        OutlinedButton.icon(onPressed:()=>SpeechService.speak(item,letterOnly:true),icon:const Icon(Icons.record_voice_over_outlined),label:const Text('বর্ণ / অক্ষরের নাম শুনি')),
        const SizedBox(height:18),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('✍️  এবার নিজে লিখে দেখি',style:TextStyle(fontWeight:FontWeight.w900,fontSize:17)),
          const SizedBox(height:12),
          Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:18),decoration:BoxDecoration(color:currentSkin.background,borderRadius:BorderRadius.circular(currentSkin.radius),border:Border.all(color:currentSkin.line)),child:Column(children:[
            Text(item.glyph,style:TextStyle(fontSize:55,color:currentSkin.primary.withOpacity(.22),fontWeight:FontWeight.w900)),
            const SizedBox(height:4),Text('উপরে দেখে খাতায় ৩ বার লেখো',style:TextStyle(color:currentSkin.muted,fontSize:12)),
          ])),
          const SizedBox(height:12),
          Text('দেখো • বলো • শোনো • লেখো',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w800)),
        ]))),
        const SizedBox(height:14),
        FilledButton(onPressed:()async{await AppStore.mark(item.id);await AppStore.addStars(1);if(context.mounted)showDialog(context:context,builder:(_)=>const CelebrationDialog(title:'পাঠটি শেষ!',subtitle:'তুমি একটি নতুন শব্দ শিখেছো।',emoji:'🌟'));},child:const Text('আমি শিখেছি!  ⭐')),
        const SizedBox(height:15),
        Card(child:Padding(padding:const EdgeInsets.all(14),child:Text('অভিভাবকের টিপ: শিশুকে আগে ছবিটি দেখতে দিন, তারপর শব্দটি শুনিয়ে ধীরে ধীরে বলতে উৎসাহ দিন। ভুল হলে বকবেন না।',style:TextStyle(color:currentSkin.muted,height:1.5)))),
      ]),
    );
  }
}

class YearPlanPage extends StatelessWidget {
  const YearPlanPage({super.key});
  @override
  Widget build(BuildContext context) {
    final terms=['Term 1 • Getting Ready','Term 2 • Words & Discovery','Term 3 • Growing Skills','Term 4 • Confident Learner'];
    return Scaffold(
      appBar:AppBar(title:const Text('এক বছরের আন্তর্জাতিক কারিকুলাম')),
      body:ListView(padding:const EdgeInsets.fromLTRB(14,8,14,28),children:[
        Card(child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('🎓  ১২ মাসের শেখার যাত্রা',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
          const SizedBox(height:6),Text('৪টি টার্ম • ৫২ সপ্তাহ • প্রতিদিন ১৫–২০ মিনিটের ছোট পাঠ',style:TextStyle(color:currentSkin.muted)),
          const SizedBox(height:12),const Text('খেলা, গল্প, ভাষা, সংখ্যা, সৃজনশীলতা, সামাজিক দক্ষতা ও নিজের যত্ন—সব একসঙ্গে।'),
        ]))),
        for(var term=0;term<4;term++) ...[
          Padding(padding:const EdgeInsets.fromLTRB(4,18,4,8),child:Text(terms[term],style:TextStyle(color:currentSkin.primary,fontSize:17,fontWeight:FontWeight.w900))),
          ...yearPlan.where((w)=>(w.week-1)~/13==term).map((w)=>_WeekCard(plan:w)),
        ],
      ]),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.plan});
  final WeekPlan plan;
  @override
  Widget build(BuildContext context) {
    final done=AppStore.completed.value.contains('week-${plan.week}');
    return Card(child:ExpansionTile(
      leading:CircleAvatar(backgroundColor:currentSkin.secondary.withOpacity(.25),child:Text('${plan.week}',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900))),
      title:Text(plan.title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:14)),
      subtitle:Text('সপ্তাহ ${plan.week}',style:TextStyle(color:currentSkin.muted,fontSize:11)),
      trailing:done?Icon(Icons.check_circle,color:currentSkin.primary):null,
      childrenPadding:const EdgeInsets.fromLTRB(16,0,16,14),
      children:[
        Align(alignment:Alignment.centerLeft,child:Text('এই সপ্তাহে শিখবে',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900))),
        const SizedBox(height:5),Align(alignment:Alignment.centerLeft,child:Text(plan.focus,style:TextStyle(color:currentSkin.ink,height:1.45))),
        const SizedBox(height:10),Align(alignment:Alignment.centerLeft,child:Text('বাড়িতে মজার কাজ',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900))),
        const SizedBox(height:5),Align(alignment:Alignment.centerLeft,child:Text(plan.homeActivity,style:TextStyle(color:currentSkin.muted,height:1.4))),
        const SizedBox(height:10),Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:()=>AppStore.mark('week-${plan.week}'),icon:Icon(done?Icons.check_circle:Icons.task_alt),label:Text(done?'সম্পন্ন':'সপ্তাহটি সম্পন্ন করো'))),
      ],
    ));
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override State<GamePage> createState()=>_GamePageState();
}
class _GamePageState extends State<GamePage> {
  final _random=math.Random();
  late List<LearningItem> questions;
  late List<List<LearningItem>> choices;
  int index=0,score=0;
  String? selected;
  bool answered=false;

  @override void initState(){super.initState();_prepare();}
  void _prepare(){
    final pool=allLearningItems.toList()..shuffle(_random);
    questions=pool.take(10).toList();
    choices=questions.map((q){
      final others=pool.where((e)=>e.id!=q.id).toList()..shuffle(_random);
      return ([q,...others.take(3)]..shuffle(_random));
    }).toList();
    index=0;score=0;selected=null;answered=false;
  }
  void _choose(LearningItem item){
    if(answered)return;
    final correct=item.id==questions[index].id;
    setState(() { selected=item.id; answered=true; if(correct) score++; });
    if(correct){
      SystemSound.play(SystemSoundType.alert);
      SpeechService.sayBangla('দারুণ! একদম সঠিক উত্তর!');
      AppStore.addStars(1);
    }else{
      SystemSound.play(SystemSoundType.click);
      SpeechService.sayBangla('আবার চেষ্টা করো, তুমি পারবে!');
    }
  }
  Future<void> _next()async{
    if(index<questions.length-1){setState(() { index++; selected=null; answered=false; });return;}
    await AppStore.mark('game-round');
    if(!mounted)return;
    await showDialog<void>(context:context,builder:(_)=>CelebrationDialog(title:'তোমার খেলার ফল',subtitle:'১০টির মধ্যে $scoreটি সঠিক উত্তর! আবার খেলবে?',emoji:score>=8?'🏆':'🎉'));
    if(mounted)setState(_prepare);
  }
  @override
  Widget build(BuildContext context){
    final q=questions[index];
    return ListView(padding:const EdgeInsets.fromLTRB(16,10,16,28),children:[
      Card(child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[const Expanded(child:Text('ছবি দেখে উত্তর দাও',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900))),Text('⭐ $score',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900))]),
        const SizedBox(height:10),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:(index+1)/questions.length,minHeight:8,backgroundColor:currentSkin.line,color:currentSkin.primary)),
        const SizedBox(height:7),Text('প্রশ্ন ${index+1} / ${questions.length}',style:TextStyle(color:currentSkin.muted,fontSize:12)),
      ]))),
      const SizedBox(height:14),
      Card(child:Padding(padding:const EdgeInsets.symmetric(vertical:25,horizontal:15),child:Column(children:[
        const Text('এই ছবির শব্দটি কোনটি?',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
        const SizedBox(height:12),Text(q.emoji,style:const TextStyle(fontSize:74)),
        Text(q.glyph,style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:currentSkin.primary)),
      ]))),
      const SizedBox(height:13),
      ...choices[index].map((option){
        final isCorrect=option.id==q.id;
        final isSelected=option.id==selected;
        Color? color;
        if(answered&&isCorrect)color=const Color(0xFFDAEEDC);
        else if(answered&&isSelected)color=const Color(0xFFF3DEDC);
        return Padding(padding:const EdgeInsets.only(bottom:8),child:Card(color:color,child:ListTile(
          title:Text(option.word,style:const TextStyle(fontWeight:FontWeight.w800)),
          subtitle:Text(option.meaning),
          trailing:answered&&isCorrect?const Icon(Icons.check_circle,color:Colors.green):null,
          onTap:()=>_choose(option),
        )));
      }),
      if(answered)Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(selected==q.id?'🌟 বাহ! তুমি ঠিক উত্তর দিয়েছো।':'💛 সঠিক উত্তর: ${q.word} • ${q.meaning}',textAlign:TextAlign.center,style:TextStyle(fontWeight:FontWeight.w800,color:currentSkin.primary))),
      FilledButton.icon(onPressed:answered?_next:null,icon:const Icon(Icons.arrow_forward),label:Text(index==questions.length-1?'ফলাফল দেখো':'পরের প্রশ্ন')),
      const SizedBox(height:10),Center(child:TextButton.icon(onPressed:()=>setState(_prepare),icon:const Icon(Icons.refresh),label:const Text('নতুন করে শুরু করি'))),
    ]);
  }
}

int completedForBook(Set<String> done, String bookId) {
  if (bookId == 'world') {
    return done.where((id) => discoveryWords.any((item) => item.id == id)).length;
  }
  final prefix = switch (bookId) {
    'bangla' => 'bn-',
    'english' => 'en-',
    'arabic' => 'ar-',
    'math' => 'num-',
    _ => '',
  };
  return done.where((id) => prefix.isNotEmpty && id.startsWith(prefix)).length;
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override Widget build(BuildContext context)=>ValueListenableBuilder<Set<String>>(
    valueListenable:AppStore.completed,
    builder:(context,done,_)=>ValueListenableBuilder<int>(
      valueListenable:AppStore.stars,
      builder:(context,stars,__) {
        final letters=done.where((id)=>id.startsWith('bn-')||id.startsWith('en-')||id.startsWith('ar-')||id.startsWith('num-')).length;
        final weeks=done.where((id)=>id.startsWith('week-')).length;
        return ListView(padding:const EdgeInsets.fromLTRB(16,10,16,30),children:[
          Card(child:Padding(padding:const EdgeInsets.all(21),child:Column(children:[
            const Text('🌟',style:TextStyle(fontSize:48)),const SizedBox(height:6),
            const Text('তুমি দারুণ এগিয়ে যাচ্ছো!',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
            const SizedBox(height:5),Text('তোমার অর্জিত তারকা',style:TextStyle(color:currentSkin.muted)),
            Text('$stars',style:TextStyle(fontSize:42,fontWeight:FontWeight.w900,color:currentSkin.primary)),
          ]))),
          const SizedBox(height:14),
          Row(children:[
            Expanded(child:_ProgressTile(emoji:'🔤',value:'$letters',label:'শেখা কার্ড')),
            const SizedBox(width:9),Expanded(child:_ProgressTile(emoji:'🗓️',value:'$weeks / 52',label:'সম্পন্ন সপ্তাহ')),
          ]),
          const SizedBox(height:14),
          Card(child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('শেখার বইগুলো',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),
            const SizedBox(height:12),
            for(final book in books)
              Padding(padding:const EdgeInsets.only(bottom:9),child:Row(children:[
                Text(book.emoji,style:const TextStyle(fontSize:23)),const SizedBox(width:10),Expanded(child:Text(book.title,style:const TextStyle(fontWeight:FontWeight.w700))),
                Text('${completedForBook(done, book.id)} / ${book.count}',style:TextStyle(color:currentSkin.primary,fontWeight:FontWeight.w900)),
              ])),
          ]))),
          const SizedBox(height:10),
          Card(child:ListTile(leading:const Icon(Icons.calendar_month_outlined),title:const Text('পাঠপরিকল্পনা দেখো'),subtitle:const Text('বাকি সপ্তাহগুলো শেষ করো'),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const YearPlanPage())))),
        ]);
      },
    ),
  );
}

class _ProgressTile extends StatelessWidget{
  const _ProgressTile({required this.emoji,required this.value,required this.label});
  final String emoji,value,label;
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(children:[Text(emoji,style:const TextStyle(fontSize:27)),Text(value,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text(label,style:TextStyle(color:currentSkin.muted,fontSize:11))])));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('সেটিংস ও চোখের আরাম')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      const Text('পছন্দের রং ও বইয়ের সাজ',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
      const SizedBox(height:6),Text('থিম বদলালে শুধু রং নয়—বইয়ের তাক, কার্ড, পেজের আকৃতি ও হোম স্ক্রিনের বিন্যাসও বদলাবে।',style:TextStyle(color:currentSkin.muted,height:1.45)),
      const SizedBox(height:14),
      ...appSkins.map((s)=>ValueListenableBuilder<String>(
        valueListenable:AppStore.skin,
        builder:(context,active,_)=>Card(color:s.surface,child:ListTile(
          contentPadding:const EdgeInsets.symmetric(horizontal:15,vertical:6),
          leading:Container(width:42,height:42,decoration:BoxDecoration(color:s.background,borderRadius:BorderRadius.circular(12),border:Border.all(color:s.line)),child:Center(child:Icon(s.dark?Icons.nightlight_round:Icons.palette_outlined,color:s.primary))),
          title:Text(s.name,style:TextStyle(color:s.ink,fontWeight:FontWeight.w900)),
          subtitle:Text(s.description,style:TextStyle(color:s.muted,fontSize:11)),
          trailing:active==s.id?Icon(Icons.check_circle,color:s.primary):null,
          onTap:()=>AppStore.setSkin(s.id),
        )),
      )),
      const SizedBox(height:10),
      ValueListenableBuilder<bool>(
        valueListenable:AppStore.sound,
        builder:(context,_,__)=>Card(child:SwitchListTile(secondary:const Icon(Icons.volume_up_outlined),title:const Text('উচ্চারণ ও সাউন্ড'),subtitle:const Text('ভয়েস ও ছোট সাউন্ড চালু রাখো'),value:AppStore.soundEnabled,onChanged:(v)=>AppStore.setSound(v))),
      ),
      Card(child:ListTile(leading:const Icon(Icons.record_voice_over_outlined),title:const Text('উচ্চারণ কীভাবে কাজ করে?'),subtitle:const Text('English: free dictionary audio API; বাংলা ও আরবি: device TTS. ইন্টারনেট না থাকলে TTS fallback.'),isThreeLine:true)),
      Card(child:ListTile(leading:const Icon(Icons.privacy_tip_outlined),title:const Text('শিশুর গোপনীয়তা'),subtitle:const Text('কোনো অ্যাকাউন্ট বা শিশুর ব্যক্তিগত প্রোফাইল প্রয়োজন নেই। শেখার অগ্রগতি শুধু ডিভাইসে থাকে।'),isThreeLine:true)),
    ]),
  );
}

class ParentPage extends StatelessWidget {
  const ParentPage({super.key});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('অভিভাবক কর্নার')),body:ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('🤝  শেখার সঙ্গী হোন',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text('শিশুর বয়স ও মনোযোগ অনুযায়ী ছোট পাঠ দিন। পড়া, খেলা ও বিশ্রামের মধ্যে ভারসাম্য রাখুন।',style:TextStyle(color:currentSkin.muted,height:1.5))]))),
    const _ParentTip(emoji:'⏱️',title:'অল্প সময়, নিয়মিত অনুশীলন',body:'প্রতিদিন ১৫–২০ মিনিট দিয়ে শুরু করুন; শিশুর আগ্রহ থাকলে সময় বাড়ান।'),
    const _ParentTip(emoji:'🗣️',title:'শুনে বলার সুযোগ দিন',body:'একবার আপনি বলুন, তারপর শিশুকে শব্দটি বলতে উৎসাহ দিন।'),
    const _ParentTip(emoji:'🧸',title:'বাস্তব জিনিস ব্যবহার করুন',body:'বইয়ের ছবি দেখানোর পাশাপাশি ঘরের ফল, খেলনা ও রং দেখান।'),
    const _ParentTip(emoji:'💛',title:'ভুলকে শেখার অংশ ভাবুন',body:'ভুল করলে উত্তর বলে দেবেন না; ইঙ্গিত দিয়ে আবার চেষ্টা করতে দিন।'),
    const _ParentTip(emoji:'🌳',title:'স্ক্রিনের বাইরে শেখা',body:'গোনা, আঁকা, দৌড়, গান, গল্প ও প্রকৃতি দেখার কাজও রাখুন।'),
  ]));
}

class _ParentTip extends StatelessWidget {
  const _ParentTip({required this.emoji,required this.title,required this.body});
  final String emoji,title,body;
  @override Widget build(BuildContext context)=>Card(child:ListTile(leading:Text(emoji,style:const TextStyle(fontSize:28)),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),subtitle:Text(body,style:TextStyle(color:currentSkin.muted,height:1.4))));
}

class CelebrationDialog extends StatelessWidget {
  const CelebrationDialog({super.key,required this.title,required this.subtitle,required this.emoji});
  final String title,subtitle,emoji;
  @override Widget build(BuildContext context)=>Dialog(
    backgroundColor:currentSkin.surface,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(28)),
    child:Padding(padding:const EdgeInsets.all(23),child:Column(mainAxisSize:MainAxisSize.min,children:[
      TweenAnimationBuilder<double>(tween:Tween(begin:.5,end:1),duration:const Duration(milliseconds:650),curve:Curves.elasticOut,builder:(context,value,child)=>Transform.scale(scale:value,child:child),child:Text(emoji,style:const TextStyle(fontSize:75))),
      const SizedBox(height:8),Text(title,textAlign:TextAlign.center,style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:currentSkin.primary)),
      const SizedBox(height:8),Text(subtitle,textAlign:TextAlign.center,style:TextStyle(color:currentSkin.muted,height:1.4)),
      const SizedBox(height:18),FilledButton.icon(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.celebration),label:const Text('ইয়েই!')),
    ])),
  );
}
