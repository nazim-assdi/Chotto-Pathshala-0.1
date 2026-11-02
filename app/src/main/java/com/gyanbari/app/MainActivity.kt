package com.gyanbari.app

import android.os.Bundle
import android.content.Intent
import android.widget.Toast
import android.speech.tts.TextToSpeech
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.Image
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.json.JSONObject
import java.util.Locale

private data class LessonData(
    val day: Int, val level: String, val subject: String, val title: String,
    val objective: String, val story: String, val examples: List<String>,
    val activity: String, val practice: String, val answers: String, val parentTip: String
)
private data class QuizData(
    val id: String, val level: String, val subject: String, val question: String,
    val options: List<Pair<String, String>>, val answer: String, val explanation: String
)
private data class ThemePack(val name: String, val primary: Color, val secondary: Color, val background: Color, val card: Color)
private val themes = listOf(
    ThemePack("আকাশ", Color(0xFF2878B8), Color(0xFF53A7C8), Color(0xFFF0F9FF), Color.White),
    ThemePack("পিচ", Color(0xFFB85C70), Color(0xFFF0A58E), Color(0xFFFFF4F0), Color.White),
    ThemePack("বন", Color(0xFF397A54), Color(0xFF8ABF76), Color(0xFFF2F9EF), Color.White),
    ThemePack("ল্যাভেন্ডার", Color(0xFF7454A6), Color(0xFFB39DDB), Color(0xFFF7F2FF), Color.White),
    ThemePack("সূর্যমুখী", Color(0xFF9A6815), Color(0xFFE6B84E), Color(0xFFFFFAE9), Color.White)
)
private val levelNames = linkedMapOf(
    "playgroup" to "প্লেগ্রুপ", "nursery" to "নার্সারি",
    "kg" to "কেজি", "class-one" to "প্রথম শ্রেণি"
)
private val levelEmoji = mapOf("playgroup" to "🧸", "nursery" to "🐥", "kg" to "🚀", "class-one" to "🦕")
private fun normLevel(value: String) = value.lowercase().replace('_', '-').trim()
private fun localeForSpeech(text: String): Locale = when {
    text.any { it in '\u0600'..'\u06FF' } -> Locale("ar", "SA")
    text.any { it in '\u0980'..'\u09FF' } -> Locale("bn", "BD")
    else -> Locale.US
}
private fun speechSegments(text: String, fallback: Locale): List<Pair<String, Locale>> {
    val segments = mutableListOf<Pair<String, Locale>>()
    val current = StringBuilder()
    var currentLocale = fallback
    fun flush() {
        if (current.isNotEmpty()) {
            segments += current.toString() to currentLocale
            current.setLength(0)
        }
    }
    text.forEach { ch ->
        val detected = when (Character.UnicodeScript.of(ch.code)) {
            Character.UnicodeScript.BENGALI -> Locale("bn", "BD")
            Character.UnicodeScript.ARABIC -> Locale("ar", "SA")
            Character.UnicodeScript.LATIN -> Locale.US
            else -> null
        }
        if (detected != null && detected != currentLocale && current.isNotEmpty()) flush()
        if (detected != null) currentLocale = detected
        current.append(ch)
    }
    flush()
    return segments
}
private fun pictureKeyFor(text: String): String {
    val s = text.lowercase()
    return when {
        listOf("apple","আপেল").any { s.contains(it) } -> "apple"
        listOf("ball","বল").any { s.contains(it) } -> "ball"
        listOf("cat","বিড়াল","বিড়াল").any { s.contains(it) } -> "cat"
        listOf("dog","কুকুর").any { s.contains(it) } -> "dog"
        listOf("bird","পাখি").any { s.contains(it) } -> "bird"
        listOf("fish","মাছ").any { s.contains(it) } -> "fish"
        listOf("sun","সূর্য").any { s.contains(it) } -> "sun"
        listOf("moon","চাঁদ").any { s.contains(it) } -> "moon"
        listOf("flower","ফুল").any { s.contains(it) } -> "flower"
        listOf("tree","গাছ").any { s.contains(it) } -> "tree"
        listOf("mango","আম").any { s.contains(it) } -> "mango"
        listOf("banana","কলা").any { s.contains(it) } -> "banana"
        listOf("book","বই").any { s.contains(it) } -> "book"
        listOf("car","গাড়ি","গাড়ি").any { s.contains(it) } -> "car"
        listOf("home","house","বাড়ি","বাড়ি").any { s.contains(it) } -> "house"
        listOf("water","পানি","জল").any { s.contains(it) } -> "water"
        listOf("school","বিদ্যালয়","বিদ্যালয়").any { s.contains(it) } -> "school"
        listOf("পেন্সিল","pencil").any { s.contains(it) } -> "pencil"
        listOf("হাত","hand").any { s.contains(it) } -> "hand"
        listOf("চোখ","eye").any { s.contains(it) } -> "eye"
        listOf("হাতি","elephant").any { s.contains(it) } -> "elephant"
        listOf("সিংহ","lion").any { s.contains(it) } -> "lion"
        listOf("প্রজাপতি","butterfly").any { s.contains(it) } -> "butterfly"
        listOf("গরু","cow").any { s.contains(it) } -> "cow"
        listOf("কমলা","orange").any { s.contains(it) } -> "orange"
        listOf("ঘুড়ি","kite").any { s.contains(it) } -> "kite"
        listOf("ছাগল","goat").any { s.contains(it) } -> "goat"
        listOf("মুরগি","hen").any { s.contains(it) } -> "hen"
        listOf("টিয়া","parrot").any { s.contains(it) } -> "parrot"
        listOf("খরগোশ","rabbit").any { s.contains(it) } -> "rabbit"
        listOf("বাঘ","tiger").any { s.contains(it) } -> "tiger"
        listOf("ছাতা","umbrella").any { s.contains(it) } -> "umbrella"
        listOf("ভ্যান","van").any { s.contains(it) } -> "van"
        listOf("ঘড়ি","watch").any { s.contains(it) } -> "watch"
        listOf("জেব্রা","zebra").any { s.contains(it) } -> "zebra"
        listOf("ice cream","আইসক্রিম").any { s.contains(it) } -> "icecream"
        listOf("juice","জুস").any { s.contains(it) } -> "juice"
        listOf("nest","বাসা").any { s.contains(it) } -> "nest"
        listOf("queen","রানি").any { s.contains(it) } -> "queen"
        listOf("mosque","মসজিদ","ইসলাম").any { s.contains(it) } -> "mosque"
        listOf("globe","পৃথিবী","বিশ্ব").any { s.contains(it) } -> "globe"
        listOf("সংখ্যা","number","গণিত","math").any { s.contains(it) } -> "number"
        listOf("letter","বর্ণ","অক্ষর","english","ইংরেজি","বাংলা").any { s.contains(it) } -> "letter"
        else -> "book"
    }
}
@Composable
private fun SubjectIllustration(subject: String, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val key = subjectPictureKey(subject)
    val id = remember(key) { context.resources.getIdentifier(key, "drawable", context.packageName) }
    Image(painter = painterResource(id = if (id != 0) id else R.drawable.book),
        contentDescription = subject, modifier = modifier)
}
@Composable
private fun PictureIllustration(
    text: String,
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null
) {
    val context = LocalContext.current
    val key = pictureKeyFor(text)
    val id = remember(key) { context.resources.getIdentifier(key, "drawable", context.packageName) }
    Image(
        painter = painterResource(id = if (id != 0) id else R.drawable.book),
        contentDescription = "$text — উচ্চারণ শুনতে ট্যাপ করো",
        modifier = if (onClick != null) modifier.clickable(onClick = onClick) else modifier
    )
}
private fun subjectPictureKey(subject: String): String {
    val s = subject.lowercase()
    return when {
        s.contains("বাংলা") -> "letter"
        s.contains("english") || s.contains("ইংরেজি") -> "letter"
        s.contains("গণ") || s.contains("math") -> "number"
        s.contains("পরিবেশ") || s.contains("বিজ্ঞান") -> "butterfly"
        s.contains("আরবি") || s.contains("islam") -> "mosque"
        s.contains("রং") -> "flower"
        s.contains("আকার") -> "number"
        s.contains("পরিবার") -> "house"
        s.contains("স্বাস্থ্য") || s.contains("শরীর") -> "hand"
        s.contains("নিরাপত্তা") -> "school"
        else -> "globe"
    }
}
private data class WordCard(val letter: String, val word: String, val pronunciation: String, val meaning: String, val pictureKey: String)
private val alphabet = listOf(
    WordCard("A","Apple","অ্যাপল","আপেল","apple"), WordCard("B","Ball","বল","বল","ball"),
    WordCard("C","Cat","ক্যাট","বিড়াল","cat"), WordCard("D","Dog","ডগ","কুকুর","dog"),
    WordCard("E","Elephant","এলিফ্যান্ট","হাতি","elephant"), WordCard("F","Fish","ফিশ","মাছ","fish"),
    WordCard("G","Goat","গোট","ছাগল","goat"), WordCard("H","Hen","হেন","মুরগি","hen"),
    WordCard("I","Ice cream","আইসক্রিম","আইসক্রিম","icecream"), WordCard("J","Juice","জুস","ফলের রস","juice"),
    WordCard("K","Kite","কাইট","ঘুড়ি","kite"), WordCard("L","Lion","লায়ন","সিংহ","lion"),
    WordCard("M","Mango","ম্যাঙ্গো","আম","mango"), WordCard("N","Nest","নেস্ট","পাখির বাসা","nest"),
    WordCard("O","Orange","অরেঞ্জ","কমলা","orange"), WordCard("P","Parrot","প্যারট","টিয়া পাখি","parrot"),
    WordCard("Q","Queen","কুইন","রানি","queen"), WordCard("R","Rabbit","র‍্যাবিট","খরগোশ","rabbit"),
    WordCard("S","Sun","সান","সূর্য","sun"), WordCard("T","Tiger","টাইগার","বাঘ","tiger"),
    WordCard("U","Umbrella","আমব্রেলা","ছাতা","umbrella"), WordCard("V","Van","ভ্যান","ভ্যান গাড়ি","van"),
    WordCard("W","Watch","ওয়াচ","ঘড়ি","watch"), WordCard("X","Xylophone","জাইলোফোন","এক ধরনের বাদ্যযন্ত্র","number"),
    WordCard("Y","Yo-yo","ইয়ো-ইয়ো","খেলনা","ball"), WordCard("Z","Zebra","জেব্রা","জেব্রা","zebra")
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { GyanbariApp() }
    }
}

private fun loadLearningData(context: android.content.Context): Pair<List<LessonData>, List<QuizData>> {
    val lessons = mutableListOf<LessonData>()
    val quizzes = mutableListOf<QuizData>()
    context.assets.list("content/lessons").orEmpty().filter { it.endsWith(".json") }.forEach { file ->
        runCatching {
            val root = JSONObject(context.assets.open("content/lessons/$file").bufferedReader().use { it.readText() })
            val arr = root.optJSONArray("lessons") ?: return@runCatching
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                val ex = o.optJSONArray("examples")
                val examples = (0 until (ex?.length() ?: 0)).map { ex!!.optString(it) }
                lessons += LessonData(o.optInt("day"), o.optString("level", root.optString("level")), o.optString("subject"),
                    o.optString("title"), o.optString("objective"), o.optString("story"), examples,
                    o.optString("activity"), o.optString("practice"), o.optString("answers"), o.optString("parent_tip"))
            }
        }
    }
    context.assets.list("content/quizzes").orEmpty().filter { it.endsWith(".json") }.forEach { file ->
        runCatching {
            val root = JSONObject(context.assets.open("content/quizzes/$file").bufferedReader().use { it.readText() })
            val arr = root.optJSONArray("questions") ?: return@runCatching
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                val opts = o.optJSONObject("options") ?: JSONObject()
                val options = listOf("A", "B", "C", "D").filter { opts.has(it) }.map { it to opts.optString(it) }
                quizzes += QuizData(o.optString("id"), o.optString("level", root.optString("level")), o.optString("subject"),
                    o.optString("question"), options, o.optString("answer"), o.optString("explanation"))
            }
        }
    }
    return lessons.sortedBy { it.day } to quizzes
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GyanbariApp() {
    val context = LocalContext.current
    val prefs = remember { context.getSharedPreferences("gyanbari_settings", 0) }
    val data = remember { loadLearningData(context) }
    val allLessons = data.first
    val allQuizzes = data.second
    var level by remember { mutableStateOf<String?>(null) }
    var subject by remember { mutableStateOf<String?>(null) }
    var page by remember { mutableStateOf("levels") }
    var selectedLesson by remember { mutableStateOf<LessonData?>(null) }
    var quizList by remember { mutableStateOf<List<QuizData>>(emptyList()) }
    var quizIndex by remember { mutableIntStateOf(0) }
    var chosen by remember { mutableStateOf<String?>(null) }
    var checked by remember { mutableStateOf(false) }
    var score by remember { mutableIntStateOf(0) }
    var themeIndex by remember { mutableIntStateOf(prefs.getInt("theme", 0).coerceIn(0, 4)) }
    var eyeComfort by remember { mutableStateOf(prefs.getBoolean("eye", false)) }
    var speechRate by remember { mutableFloatStateOf(prefs.getFloat("speech_rate", 1.0f).coerceIn(0.7f, 1.3f)) }
    var wordIndex by remember { mutableIntStateOf(0) }
    var gameIndex by remember { mutableIntStateOf(0) }
    var gameChoice by remember { mutableStateOf<String?>(null) }
    var gameChecked by remember { mutableStateOf(false) }
    var gameScore by remember { mutableIntStateOf(0) }
    var tts by remember { mutableStateOf<TextToSpeech?>(null) }
    var ttsReady by remember { mutableStateOf(false) }
    DisposableEffect(Unit) {
        val engine = TextToSpeech(context) { status ->
            ttsReady = status == TextToSpeech.SUCCESS
            if (status == TextToSpeech.SUCCESS) tts?.language = Locale.US
        }
        tts = engine
        onDispose { engine.stop(); engine.shutdown(); tts = null; ttsReady = false }
    }
    val chosenTheme = themes[themeIndex]
    val bg = if (eyeComfort) Color(0xFFF1EBDD) else chosenTheme.background
    val card = if (eyeComfort) Color(0xFFFFF8E8) else chosenTheme.card
    val primary = if (eyeComfort) Color(0xFF725D3B) else chosenTheme.primary
    val palette = lightColorScheme(primary = primary, secondary = chosenTheme.secondary, background = bg, surface = card)
    fun requestVoiceData() {
        try {
            context.startActivity(Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            Toast.makeText(context, "আপনার ফোনের Text-to-Speech স্ক্রিনে প্রয়োজনীয় ভাষার ভয়েস ইনস্টল করুন।", Toast.LENGTH_LONG).show()
        } catch (_: Exception) {
            try {
                context.startActivity(Intent("com.android.settings.TTS_SETTINGS").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            } catch (_: Exception) {
                Toast.makeText(context, "ফোনের Settings > Text-to-Speech থেকে ভয়েস ডাউনলোড করুন।", Toast.LENGTH_LONG).show()
            }
        }
    }
    fun voiceStatus(language: Locale): String {
        val engine = tts
        if (!ttsReady || engine == null) return "চেক হচ্ছে…"
        return if (engine.isLanguageAvailable(language) >= TextToSpeech.LANG_AVAILABLE) "ভয়েস প্রস্তুত" else "ডাউনলোড প্রয়োজন"
    }
    fun speak(text: String, language: Locale = Locale.US) {
        val engine = tts
        if (!ttsReady || engine == null) {
            Toast.makeText(context, "ভয়েস ইঞ্জিন চালু হচ্ছে, একটু পরে আবার চাপুন।", Toast.LENGTH_SHORT).show()
            return
        }
        if (engine.isLanguageAvailable(language) < TextToSpeech.LANG_AVAILABLE) {
            Toast.makeText(context, "এই ভাষার ভয়েস নেই। এখন ভয়েস ডাউনলোডের স্ক্রিন খুলছে।", Toast.LENGTH_LONG).show()
            requestVoiceData()
            return
        }
        val segments = speechSegments(text, language)
        var queueMode = TextToSpeech.QUEUE_FLUSH
        segments.forEachIndexed { index, (segment, detectedLanguage) ->
            val selectedLanguage = if (engine.isLanguageAvailable(detectedLanguage) >= TextToSpeech.LANG_AVAILABLE) {
                detectedLanguage
            } else if (engine.isLanguageAvailable(language) >= TextToSpeech.LANG_AVAILABLE) {
                language
            } else {
                Locale.US
            }
            if (engine.isLanguageAvailable(selectedLanguage) >= TextToSpeech.LANG_AVAILABLE) {
                engine.language = selectedLanguage
                engine.setSpeechRate(speechRate)
                engine.speak(segment, queueMode, null, "gyanbari_speech_$index")
                queueMode = TextToSpeech.QUEUE_ADD
            }
        }
    }
    fun startQuiz(items: List<QuizData>) {
        quizList = items; quizIndex = 0; chosen = null; checked = false; score = 0; page = "quiz"
    }
    fun goBack() {
        when (page) {
            "lesson" -> page = "lessons"
            "quiz" -> page = "subjects"
            "game" -> page = "subjects"
            "words" -> page = "subjects"
            "settings" -> page = if (level == null) "levels" else "subjects"
            "lessons" -> page = "subjects"
            "subjects" -> { page = "levels"; level = null; subject = null }
            else -> { level = null; subject = null; page = "levels" }
        }
    }
    BackHandler(enabled = page != "levels") { goBack() }

    MaterialTheme(colorScheme = palette) {
        Scaffold(
            containerColor = bg,
            topBar = {
                TopAppBar(
                    title = { Text("🐻 জ্ঞানবাড়ি", color = Color.White, fontWeight = FontWeight.Bold) },
                    navigationIcon = {
                        if (page != "levels") IconButton(onClick = { goBack() }) {
                            Text("‹", color = Color.White, fontSize = 32.sp)
                        }
                    },
                    actions = {
                        IconButton(onClick = { page = "settings" }) { Text("⚙️", fontSize = 22.sp) }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = primary)
                )
            }
        ) { padding ->
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 14.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(top = 14.dp, bottom = 28.dp)
            ) {
                when (page) {
                    "levels" -> {
                        item {
                            Card(colors = CardDefaults.cardColors(containerColor = chosenTheme.secondary.copy(alpha = 0.22f)),
                                shape = RoundedCornerShape(26.dp)) {
                                Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    Text("🐼 🐰 🐸 🦊 🐻", fontSize = 30.sp)
                                    Text("খেলতে খেলতে শিখি!", style = MaterialTheme.typography.headlineSmall, color = primary, fontWeight = FontWeight.Bold)
                                    Text("ছবি দেখো • শব্দ শোনো • নিজে বলো • গেম খেলো")
                                    Text("${allLessons.size}টি পাঠ  •  ${allQuizzes.size}টি কুইজ", color = primary)
                                }
                            }
                            Text("🎒 তোমার শ্রেণি বেছে নাও", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                        }
                        items(levelNames.keys.toList()) { key ->
                            Card(onClick = { level = key; page = "subjects" },
                                colors = CardDefaults.cardColors(containerColor = when(key) {
                                    "playgroup" -> Color(0xFFFFE5E8); "nursery" -> Color(0xFFE1F4FF)
                                    "kg" -> Color(0xFFEDE5FF); else -> Color(0xFFE5F5DE)
                                }), shape = RoundedCornerShape(24.dp), modifier = Modifier.fillMaxWidth()) {
                                Row(Modifier.padding(18.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Text(levelEmoji[key] ?: "📚", fontSize = 38.sp)
                                    Spacer(Modifier.width(16.dp))
                                    Column(Modifier.weight(1f)) {
                                        Text(levelNames[key] ?: key, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                        Text("পাঠ, ছবি, শব্দ ও মজার খেলা")
                                    }
                                    Text("›", fontSize = 30.sp, color = primary)
                                }
                            }
                        }
                    }
                    "subjects" -> {
                        val lessonSubjects = allLessons.filter { normLevel(it.level) == level }.map { it.subject }.filter { it.isNotBlank() }.distinct()
                        val quizSubjects = allQuizzes.filter { normLevel(it.level) == level }.map { it.subject }.filter { it.isNotBlank() }.distinct()
                        val subjects = (lessonSubjects + quizSubjects).distinct()
                        item {
                            Text("${levelNames[level] ?: ""} • শেখার বিষয়", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                            Text("বিষয়গুলো পাশে সরিয়ে দেখো 👇")
                            LazyRow(horizontalArrangement = Arrangement.spacedBy(9.dp), contentPadding = PaddingValues(vertical = 8.dp)) {
                                items(subjects) { name ->
                                    AssistChip(onClick = { subject = name; page = "lessons" },
                                        label = { Row(verticalAlignment = Alignment.CenterVertically) { SubjectIllustration(name, Modifier.size(24.dp)); Spacer(Modifier.width(6.dp)); Text(name) } })
                                }
                            }
                        }
                        items(subjects) { name ->
                            Card(onClick = { subject = name; page = "lessons" },
                                colors = CardDefaults.cardColors(containerColor = card),
                                shape = RoundedCornerShape(20.dp), modifier = Modifier.fillMaxWidth()) {
                                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                    SubjectIllustration(name, Modifier.size(52.dp))
                                    Spacer(Modifier.width(12.dp))
                                    Column(Modifier.weight(1f)) {
                                        Text(name, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                        Text("${allLessons.count { normLevel(it.level) == level && it.subject == name }}টি পাঠ • ${allQuizzes.count { normLevel(it.level) == level && it.subject == name }}টি কুইজ")
                                    }
                                    Text("খুলো  →", color = primary)
                                }
                            }
                        }
                        item {
                            Card(colors = CardDefaults.cardColors(containerColor = chosenTheme.secondary.copy(alpha = 0.20f))) {
                                Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    Text("🅰️ ইংরেজি অক্ষর ও শব্দ", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
                                    Text("A–Z, ছবি, উচ্চারণ ও বাংলা অর্থ")
                                    Button(onClick = { wordIndex = 0; page = "words" }, modifier = Modifier.fillMaxWidth()) { Text("শিখতে শুরু করি") }
                                }
                            }
                            Button(onClick = { startQuiz(allQuizzes.filter { normLevel(it.level) == level }) },
                                modifier = Modifier.fillMaxWidth()) { Text("🧠 সব বিষয়ের কুইজ") }
                            OutlinedButton(onClick = {
                                gameIndex = 0; gameChoice = null; gameChecked = false; gameScore = 0; page = "game"
                            }, modifier = Modifier.fillMaxWidth()) { Text("🎮 ছবি দেখে শব্দ চেনার গেম") }
                        }
                    }
                    "lessons" -> {
                        val list = allLessons.filter { normLevel(it.level) == level && it.subject == subject }
                        item {
                            Row(verticalAlignment = Alignment.CenterVertically) { SubjectIllustration(subject.orEmpty(), Modifier.size(46.dp)); Spacer(Modifier.width(10.dp)); Text(subject ?: "", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold) }
                            Text("${list.size}টি পাঠ", color = Color.Gray)
                            Button(onClick = { startQuiz(allQuizzes.filter { normLevel(it.level) == level && it.subject == subject }) },
                                modifier = Modifier.fillMaxWidth()) { Text("🧠 এই বিষয়ের কুইজ") }
                        }
                        items(list) { lesson ->
                            Card(onClick = { selectedLesson = lesson; page = "lesson" },
                                colors = CardDefaults.cardColors(containerColor = card),
                                shape = RoundedCornerShape(20.dp), modifier = Modifier.fillMaxWidth()) {
                                Row(Modifier.padding(15.dp), verticalAlignment = Alignment.CenterVertically) {
                                    PictureIllustration(lesson.title + " " + lesson.examples.joinToString(" "), Modifier.size(58.dp))
                                    Spacer(Modifier.width(12.dp))
                                    Column(Modifier.weight(1f)) {
                                        Text("দিন ${lesson.day}", color = primary)
                                        Text(lesson.title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                        Text(lesson.objective, maxLines = 2)
                                    }
                                    Text("›", fontSize = 26.sp, color = primary)
                                }
                            }
                        }
                    }
                    "lesson" -> {
                        val l = selectedLesson
                        if (l != null) item {
                            Card(colors = CardDefaults.cardColors(containerColor = card), shape = RoundedCornerShape(24.dp)) {
                                Column(Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                    PictureIllustration(l.title + " " + l.examples.joinToString(" "), Modifier.size(150.dp))
                                    Text("দিন ${l.day} • ${l.subject}", color = primary)
                                    Text(l.title, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                                    Text("🎯 আজকের লক্ষ্য", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                    Text(l.objective, style = MaterialTheme.typography.bodyLarge)
                                    Button(onClick = { speak(listOf(l.title, l.objective, l.story, l.examples.joinToString(". "), l.activity, l.practice, l.answers, l.parentTip).filter { it.isNotBlank() }.joinToString(". "), Locale("bn", "BD")) }, modifier = Modifier.fillMaxWidth()) { Text("🔊 সম্পূর্ণ পাঠ শুনি") }
                                    Text("📖 গল্প ও শেখা", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                    Text(l.story, style = MaterialTheme.typography.bodyLarge)
                                    if (l.examples.isNotEmpty()) {
                                        Text("🖼️ উদাহরণ দেখে শিখি", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                        l.examples.forEach { example ->
                                            Row(Modifier.fillMaxWidth().padding(vertical = 3.dp), verticalAlignment = Alignment.CenterVertically) {
                                                PictureIllustration(example, Modifier.size(58.dp), onClick = { speak(example, localeForSpeech(example)) })
                                                Spacer(Modifier.width(10.dp))
                                                Text(example, modifier = Modifier.weight(1f))
                                                IconButton(onClick = { speak(example, Locale("bn", "BD")) }) { Text("🔊") }
                                            }
                                        }
                                    }
                                    Text("✏️ কাজ", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                    Text(l.activity)
                                    Text("নিজে চেষ্টা করো", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                    Text(l.practice)
                                    var showAnswer by remember(l.day) { mutableStateOf(false) }
                                    OutlinedButton(onClick = { showAnswer = !showAnswer }) { Text(if (showAnswer) "উত্তর লুকাও" else "উত্তর দেখাও") }
                                    if (showAnswer) Text(l.answers, color = Color(0xFF287A45), style = MaterialTheme.typography.bodyLarge)
                                    if (l.parentTip.isNotBlank()) Text("👨‍👩‍👧 অভিভাবকের জন্য: ${l.parentTip}", color = Color.Gray)
                                }
                            }
                        }
                    }
                    "words" -> {
                        val w = alphabet[wordIndex]
                        item {
                            Text("🅰️ ইংরেজি A–Z", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                            Text("অক্ষর দেখো, শব্দ শোনো, ছবি দেখে অর্থ শেখো।")
                            Card(colors = CardDefaults.cardColors(containerColor = card), shape = RoundedCornerShape(26.dp)) {
                                Column(Modifier.fillMaxWidth().padding(22.dp), horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                    PictureIllustration(w.word, Modifier.size(150.dp), onClick = { speak(w.word, Locale.US) })
                                    Text(w.letter, fontSize = 72.sp, color = primary, fontWeight = FontWeight.ExtraBold)
                                    Text("${w.letter} for ${w.word}", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                                    Text("উচ্চারণ: ${w.pronunciation}", style = MaterialTheme.typography.titleMedium)
                                    Text("অর্থ: ${w.meaning}", style = MaterialTheme.typography.titleLarge)
                                    Button(onClick = { speak(w.word, Locale.US) }, modifier = Modifier.fillMaxWidth()) { Text("🔊 ইংরেজি উচ্চারণ শুনি") }
                                    OutlinedButton(onClick = { speak(w.meaning, Locale("bn", "BD")) }, modifier = Modifier.fillMaxWidth()) { Text("বাংলা অর্থ শুনি") }
                                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                        OutlinedButton(onClick = { wordIndex = (wordIndex - 1).coerceAtLeast(0) }, enabled = wordIndex > 0) { Text("← আগের") }
                                        Button(onClick = { wordIndex = (wordIndex + 1).coerceAtMost(25) }, enabled = wordIndex < 25) { Text("পরের →") }
                                    }
                                }
                            }
                            LazyRow(horizontalArrangement = Arrangement.spacedBy(7.dp)) {
                                items(alphabet) { item ->
                                    FilterChip(selected = alphabet.indexOf(item) == wordIndex,
                                        onClick = { wordIndex = alphabet.indexOf(item) }, label = { Text(item.letter) })
                                }
                            }
                        }
                    }
                    "game" -> {
                        val gameWords = listOf(
                            WordCard("A","Apple","অ্যাপল","আপেল","apple"),
                            WordCard("B","Ball","বল","বল","ball"),
                            WordCard("C","Cat","ক্যাট","বিড়াল","cat"),
                            WordCard("D","Dog","ডগ","কুকুর","dog"),
                            WordCard("E","Elephant","এলিফ্যান্ট","হাতি","elephant"),
                            WordCard("F","Fish","ফিশ","মাছ","fish"),
                            WordCard("G","Mango","ম্যাঙ্গো","আম","mango"),
                            WordCard("H","Sun","সান","সূর্য","sun")
                        )
                        if (gameIndex >= gameWords.size) {
                            item {
                                Text("🎉 খেলা শেষ!", style = MaterialTheme.typography.headlineSmall)
                                Text("তোমার পয়েন্ট: $gameScore / ${gameWords.size}", style = MaterialTheme.typography.titleLarge)
                                Button(onClick = { gameIndex = 0; gameScore = 0; gameChoice = null; gameChecked = false }) { Text("আবার খেলি") }
                            }
                        } else {
                            val target = gameWords[gameIndex]
                            val choices = listOf(target.word, gameWords[(gameIndex + 1) % gameWords.size].word, gameWords[(gameIndex + 3) % gameWords.size].word).shuffled()
                            item {
                                Text("🎮 ছবি দেখে শব্দ চেনো", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                                Text("প্রশ্ন ${gameIndex + 1} / ${gameWords.size}   ⭐ পয়েন্ট: $gameScore")
                                Card(colors = CardDefaults.cardColors(containerColor = card), shape = RoundedCornerShape(24.dp)) {
                                    Column(Modifier.fillMaxWidth().padding(22.dp), horizontalAlignment = Alignment.CenterHorizontally,
                                        verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                        PictureIllustration(target.word, Modifier.size(170.dp), onClick = { speak(target.word, Locale.US) })
                                        Text("ছবিটির ইংরেজি নাম কী?", style = MaterialTheme.typography.titleLarge)
                                        choices.forEach { option ->
                                            OutlinedButton(onClick = { if (!gameChecked) gameChoice = option },
                                                modifier = Modifier.fillMaxWidth(),
                                                colors = ButtonDefaults.outlinedButtonColors(containerColor = if (gameChoice == option) chosenTheme.secondary.copy(alpha = .3f) else card)) {
                                                Text(option, fontSize = 19.sp)
                                            }
                                        }
                                        Button(onClick = {
                                            if (gameChoice != null && !gameChecked) {
                                                gameChecked = true
                                                if (gameChoice == target.word) gameScore++
                                            }
                                        }, enabled = gameChoice != null && !gameChecked, modifier = Modifier.fillMaxWidth()) { Text("উত্তর মিলিয়ে দেখি") }
                                        if (gameChecked) {
                                            Text(if (gameChoice == target.word) "🌟 বাহ! ঠিক হয়েছে!" else "চেষ্টা ভালো! সঠিক উত্তর: ${target.word}")
                                            Button(onClick = { gameIndex++; gameChoice = null; gameChecked = false }, modifier = Modifier.fillMaxWidth()) { Text("পরের ছবি →") }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    "settings" -> {
                        item {
                            Text("⚙️ সেটিংস", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                            Text("শিশুর চোখ ও পছন্দ অনুযায়ী অ্যাপ সাজাও।")
                            Card(colors = CardDefaults.cardColors(containerColor = card), shape = RoundedCornerShape(22.dp)) {
                                Column(Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                    Text("🎨 থিম বেছে নাও", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                    themes.forEachIndexed { index, theme ->
                                        Row(Modifier.fillMaxWidth().clickable {
                                            themeIndex = index; prefs.edit().putInt("theme", index).apply()
                                        }.padding(vertical = 7.dp), verticalAlignment = Alignment.CenterVertically) {
                                            Box(Modifier.size(30.dp).background(theme.primary, CircleShape))
                                            Spacer(Modifier.width(12.dp))
                                            Text(theme.name, modifier = Modifier.weight(1f))
                                            RadioButton(selected = themeIndex == index, onClick = {
                                                themeIndex = index; prefs.edit().putInt("theme", index).apply()
                                            })
                                        }
                                    }
                                    Divider()
                                    Text("🔊 কথার গতি", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                    Text(when { speechRate < 0.9f -> "ধীর গতি"; speechRate > 1.1f -> "দ্রুত গতি"; else -> "স্বাভাবিক গতি" })
                                    Slider(value = speechRate, onValueChange = { speechRate = it }, onValueChangeFinished = { prefs.edit().putFloat("speech_rate", speechRate).apply() }, valueRange = 0.7f..1.3f, steps = 5)
                                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) { Text("ধীর"); Text("স্বাভাবিক"); Text("দ্রুত") }
                                    Divider()
                                    Text("⬇️ ভয়েস ডাউনলোড সিস্টেম", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                                    Text("প্রথমবার কোনো ছবিতে চাপ দিলে প্রয়োজনীয় ভাষার ভয়েস না থাকলে ফোনের ভয়েস-ডাউনলোড স্ক্রিন খুলবে। ইনস্টল হলে ইন্টারনেট ছাড়াই উচ্চারণ শোনা যাবে (ফোনের TTS ইঞ্জিন সমর্থন করলে)।")
                                    val voiceOptions = listOf(
                                        "বাংলা" to Locale("bn", "BD"),
                                        "English" to Locale.US,
                                        "العربية" to Locale("ar", "SA")
                                    )
                                    voiceOptions.forEach { (label, locale) ->
                                        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                                            Column(Modifier.weight(1f)) {
                                                Text(label, fontWeight = FontWeight.SemiBold)
                                                Text(voiceStatus(locale), color = if (voiceStatus(locale) == "ভয়েস প্রস্তুত") Color(0xFF287A45) else Color.Gray, style = MaterialTheme.typography.bodySmall)
                                            }
                                            OutlinedButton(onClick = { requestVoiceData() }) { Text("ডাউনলোড / সেটআপ") }
                                        }
                                    }
                                    Text("গণিতের সংখ্যা ও চিহ্ন নির্বাচিত বাংলা বা English ভয়েসে পড়া হবে।", style = MaterialTheme.typography.bodySmall)
                                    OutlinedButton(onClick = {
                                        try { context.startActivity(Intent("com.android.settings.TTS_SETTINGS").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
                                        catch (_: Exception) { requestVoiceData() }
                                    }, modifier = Modifier.fillMaxWidth()) { Text("ফোনের Voice Settings খুলুন") }
                                    Divider()
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Column(Modifier.weight(1f)) {
                                            Text("🌙 Eye Comfort", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                                            Text("চোখের আরামের জন্য নরম উষ্ণ ব্যাকগ্রাউন্ড")
                                        }
                                        Switch(checked = eyeComfort, onCheckedChange = {
                                            eyeComfort = it; prefs.edit().putBoolean("eye", it).apply()
                                        })
                                    }
                                    Text("নির্বাচিত থিম: ${chosenTheme.name}")
                                }
                            }
                        }
                    }
                    "quiz" -> {
                        if (quizList.isEmpty()) item { Text("এই বিষয়ের কুইজ এখনো যোগ করা হয়নি।") }
                        else if (quizIndex >= quizList.size) {
                            item {
                                Card(colors = CardDefaults.cardColors(containerColor = chosenTheme.secondary.copy(alpha = .25f))) {
                                    Column(Modifier.padding(22.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                        Text("🎉 কুইজ শেষ!", style = MaterialTheme.typography.headlineSmall)
                                        Text("তোমার স্কোর: $score / ${quizList.size}", style = MaterialTheme.typography.titleLarge)
                                        Button(onClick = { quizIndex = 0; score = 0; chosen = null; checked = false }) { Text("আবার খেলো") }
                                    }
                                }
                            }
                        } else {
                            val q = quizList[quizIndex]
                            item {
                                Text("🧠 কুইজ ${quizIndex + 1} / ${quizList.size}", style = MaterialTheme.typography.titleLarge)
                                Text("⭐ স্কোর: $score", color = primary)
                                Card(colors = CardDefaults.cardColors(containerColor = card), shape = RoundedCornerShape(22.dp)) {
                                    Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                        Row(verticalAlignment = Alignment.CenterVertically) { SubjectIllustration(q.subject, Modifier.size(32.dp)); Spacer(Modifier.width(8.dp)); Text(q.subject, color = primary) }
                                        Text(q.question, style = MaterialTheme.typography.titleLarge)
                                        OutlinedButton(onClick = { speak(listOf(q.question, q.options.joinToString(". ") { "${it.first}. ${it.second}" }, q.explanation).filter { it.isNotBlank() }.joinToString(". "), Locale("bn", "BD")) }, modifier = Modifier.fillMaxWidth()) { Text("🔊 প্রশ্ন ও ব্যাখ্যা শুনি") }
                                        q.options.forEach { (key, value) ->
                                            val isChosen = chosen == key
                                            OutlinedButton(onClick = { if (!checked) chosen = key },
                                                modifier = Modifier.fillMaxWidth(),
                                                colors = ButtonDefaults.outlinedButtonColors(containerColor = if (isChosen) chosenTheme.secondary.copy(alpha = .3f) else card)) {
                                                Text("$key. $value")
                                            }
                                        }
                                        Button(onClick = {
                                            if (chosen != null && !checked) {
                                                checked = true
                                                if (chosen == q.answer) score++
                                            }
                                        }, enabled = chosen != null && !checked, modifier = Modifier.fillMaxWidth()) { Text("উত্তর যাচাই") }
                                        if (checked) {
                                            val right = chosen == q.answer
                                            Text(if (right) "🌟 দারুণ! সঠিক উত্তর।" else "আরও চেষ্টা করো। সঠিক উত্তর: ${q.options.firstOrNull { it.first == q.answer }?.second ?: q.answer}",
                                                color = if (right) Color(0xFF287A45) else Color(0xFFB34B37))
                                            if (q.explanation.isNotBlank()) Text(q.explanation)
                                            Button(onClick = { quizIndex++; chosen = null; checked = false },
                                                modifier = Modifier.fillMaxWidth()) { Text("পরের প্রশ্ন →") }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                item { Text("🐻 জ্ঞানবাড়ি • আনন্দে শিখি, খেলায় বেড়ে উঠি", color = Color.Gray, style = MaterialTheme.typography.bodySmall) }
            }
        }
    }
}

private fun subjectEmoji(subject: String): String {
    val s = subject.lowercase()
    return when {
        s.contains("বাংলা") -> "📖"
        s.contains("english") || s.contains("ইংরেজি") -> "🔤"
        s.contains("গণ") || s.contains("math") -> "🔢"
        s.contains("পরিবেশ") || s.contains("বিজ্ঞান") -> "🌱"
        s.contains("আরবি") || s.contains("islam") -> "🌙"
        s.contains("রং") -> "🎨"
        s.contains("আকার") -> "🧩"
        s.contains("পরিবার") -> "👨‍👩‍👧"
        s.contains("স্বাস্থ্য") -> "🪥"
        s.contains("শরীর") -> "🧒"
        s.contains("নিরাপত্তা") -> "🛟"
        s.contains("গণনা") -> "🔢"
        else -> "🦊"
    }
}
