package com.gyanbari.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import org.json.JSONObject

private data class LessonData(
    val day: Int, val level: String, val subject: String, val title: String,
    val objective: String, val story: String, val examples: List<String>,
    val activity: String, val practice: String, val answers: String, val parentTip: String
)
private data class QuizData(
    val id: String, val level: String, val subject: String, val question: String,
    val options: List<Pair<String, String>>, val answer: String, val explanation: String
)
private val levelNames = linkedMapOf(
    "playgroup" to "প্লেগ্রুপ", "nursery" to "নার্সারি",
    "kg" to "কেজি", "class-one" to "প্রথম শ্রেণি"
)
private val levelEmoji = mapOf("playgroup" to "🧸", "nursery" to "🐣", "kg" to "🚀", "class-one" to "🎓")

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
                lessons += LessonData(o.optInt("day"), o.optString("level"), o.optString("subject"),
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
                quizzes += QuizData(o.optString("id"), o.optString("level"), o.optString("subject"),
                    o.optString("question"), options, o.optString("answer"), o.optString("explanation"))
            }
        }
    }
    return lessons.sortedBy { it.day } to quizzes
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GyanbariApp() {
    val context = androidx.compose.ui.platform.LocalContext.current
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

    val palette = lightColorScheme(
        primary = Color(0xFF7046C7), secondary = Color(0xFFE875A6),
        tertiary = Color(0xFFFFB84D), background = Color(0xFFFFF8EC), surface = Color.White
    )
    fun goBack() {
        when (page) {
            "lesson" -> page = "lessons"
            "quiz" -> page = "subjects"
            "lessons" -> page = "subjects"
            "subjects" -> { page = "levels"; level = null; subject = null }
            else -> { level = null; subject = null; page = "levels" }
        }
    }
    BackHandler(enabled = page != "levels") { goBack() }

    MaterialTheme(colorScheme = palette) {
        Scaffold(
            containerColor = Color(0xFFFFF8EC),
            topBar = {
                TopAppBar(
                    title = { Text("🌈 জ্ঞানবাড়ি", color = Color.White) },
                    navigationIcon = {
                        if (page != "levels") IconButton(onClick = { goBack() }) {
                            Text("‹", color = Color.White, style = MaterialTheme.typography.headlineMedium)
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF7046C7))
                )
            }
        ) { padding ->
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(top = 16.dp, bottom = 28.dp)
            ) {
                when (page) {
                    "levels" -> {
                        item {
                            Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFFFE8A8)),
                                shape = RoundedCornerShape(24.dp)) {
                                Column(Modifier.padding(20.dp)) {
                                    Text("⭐ ছোট্ট শিক্ষার্থীদের শেখার জগৎ", color = Color(0xFF704600))
                                    Text("আজ কী শিখবে তুমি?", style = MaterialTheme.typography.headlineSmall, color = Color(0xFF6842B5))
                                    Text("নিজের শ্রেণি বেছে নাও। প্রতিদিন নতুন পাঠ, উদাহরণ ও মজার কুইজ অপেক্ষা করছে!")
                                }
                            }
                            Text("🎒 শ্রেণি বেছে নাও", style = MaterialTheme.typography.titleLarge)
                            Text("${allLessons.size}টি পাঠ • ${allQuizzes.size}টি কুইজ", color = Color.Gray)
                        }
                        items(levelNames.keys.toList()) { key ->
                            Card(onClick = { level = key; page = "subjects" },
                                colors = CardDefaults.cardColors(containerColor = when(key) {
                                    "playgroup" -> Color(0xFFFFE0E5); "nursery" -> Color(0xFFDFF3FF)
                                    "kg" -> Color(0xFFE9E1FF); else -> Color(0xFFDFF6DF)
                                }), shape = RoundedCornerShape(22.dp), modifier = Modifier.fillMaxWidth()) {
                                Column(Modifier.padding(20.dp)) {
                                    Text(levelEmoji[key] ?: "📚", style = MaterialTheme.typography.headlineMedium)
                                    Text(levelNames[key] ?: key, style = MaterialTheme.typography.titleLarge)
                                    Text("এই শ্রেণির পাঠ ও কুইজ দেখতে চাপ দাও")
                                }
                            }
                        }
                    }
                    "subjects" -> {
                        val lessonSubjects = allLessons.filter { it.level == level }.map { it.subject }.distinct()
                        val quizSubjects = allQuizzes.filter { it.level == level }.map { it.subject }.distinct()
                        item {
                            Text("${levelNames[level] ?: ""} • বিষয় নির্বাচন", style = MaterialTheme.typography.headlineSmall)
                            Text("যে বিষয়ে শিখতে চাও, সেটি বেছে নাও।")
                        }
                        items(lessonSubjects) { name ->
                            Card(onClick = { subject = name; page = "lessons" },
                                colors = CardDefaults.cardColors(containerColor = Color(0xFFE8E0FF)),
                                shape = RoundedCornerShape(18.dp), modifier = Modifier.fillMaxWidth()) {
                                Row(Modifier.padding(18.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                                    Column(Modifier.weight(1f)) {
                                        Text("📘 $name", style = MaterialTheme.typography.titleLarge)
                                        Text("${allLessons.count { it.level == level && it.subject == name }}টি পাঠ")
                                    }
                                    Text("খুলো  →", color = Color(0xFF7046C7))
                                }
                            }
                        }
                        item {
                            Button(onClick = {
                                subject = null
                                quizList = allQuizzes.filter { it.level == level }
                                quizIndex = 0; chosen = null; checked = false; score = 0; page = "quiz"
                            }, modifier = Modifier.fillMaxWidth()) { Text("🧠 সব বিষয়ের মিশ্র কুইজ") }
                        }
                        if (quizSubjects.isEmpty()) item { Text("এই শ্রেণির কুইজ এখনো যোগ করা হয়নি।") }
                    }
                    "lessons" -> {
                        val list = allLessons.filter { it.level == level && it.subject == subject }
                        item {
                            Text("📚 $subject", style = MaterialTheme.typography.headlineSmall)
                            Text("${list.size}টি পাঠ", color = Color.Gray)
                            Button(onClick = {
                                quizList = allQuizzes.filter { it.level == level && it.subject == subject }
                                quizIndex = 0; chosen = null; checked = false; score = 0; page = "quiz"
                            }, modifier = Modifier.fillMaxWidth()) { Text("🧠 এই বিষয়ের কুইজ") }
                        }
                        items(list) { lesson ->
                            Card(onClick = { selectedLesson = lesson; page = "lesson" },
                                colors = CardDefaults.cardColors(containerColor = Color.White),
                                shape = RoundedCornerShape(18.dp), modifier = Modifier.fillMaxWidth()) {
                                Column(Modifier.padding(17.dp)) {
                                    Text("দিন ${lesson.day}", color = Color(0xFF7046C7))
                                    Text(lesson.title, style = MaterialTheme.typography.titleLarge)
                                    Text(lesson.objective, maxLines = 2)
                                    Text("পাঠ পড়ো  →", color = Color(0xFF7046C7))
                                }
                            }
                        }
                    }
                    "lesson" -> {
                        val l = selectedLesson
                        if (l != null) item {
                            Card(colors = CardDefaults.cardColors(containerColor = Color.White),
                                shape = RoundedCornerShape(22.dp)) {
                                Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                    Text("দিন ${l.day} • ${l.subject}", color = Color(0xFF7046C7))
                                    Text(l.title, style = MaterialTheme.typography.headlineSmall)
                                    Text("🎯 আজকের লক্ষ্য", style = MaterialTheme.typography.titleMedium)
                                    Text(l.objective, style = MaterialTheme.typography.bodyLarge)
                                    Text("📖 গল্প ও শেখা", style = MaterialTheme.typography.titleMedium)
                                    Text(l.story, style = MaterialTheme.typography.bodyLarge)
                                    if (l.examples.isNotEmpty()) {
                                        Text("উদাহরণ", style = MaterialTheme.typography.titleMedium)
                                        l.examples.forEach { Text("• $it") }
                                    }
                                    Text("✏️ কাজ", style = MaterialTheme.typography.titleMedium)
                                    Text(l.activity)
                                    Text("নিজে চেষ্টা করো", style = MaterialTheme.typography.titleMedium)
                                    Text(l.practice)
                                    var showAnswer by remember(l.day) { mutableStateOf(false) }
                                    OutlinedButton(onClick = { showAnswer = !showAnswer }) {
                                        Text(if (showAnswer) "উত্তর লুকাও" else "উত্তর দেখাও")
                                    }
                                    if (showAnswer) Text(l.answers, color = Color(0xFF287A45), style = MaterialTheme.typography.bodyLarge)
                                    if (l.parentTip.isNotBlank()) Text("অভিভাবকের জন্য: ${l.parentTip}", color = Color.Gray)
                                }
                            }
                        }
                    }
                    "quiz" -> {
                        if (quizList.isEmpty()) {
                            item { Text("এই বিষয়ের কুইজ এখনো যোগ করা হয়নি।") }
                        } else if (quizIndex >= quizList.size) {
                            item {
                                Card(colors = CardDefaults.cardColors(containerColor = Color(0xFFFFE8A8))) {
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
                                Text("স্কোর: $score", color = Color(0xFF7046C7))
                                Card(colors = CardDefaults.cardColors(containerColor = Color.White),
                                    shape = RoundedCornerShape(22.dp)) {
                                    Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                                        Text(q.subject, color = Color(0xFF7046C7))
                                        Text(q.question, style = MaterialTheme.typography.titleLarge)
                                        q.options.forEach { (key, value) ->
                                            val isChosen = chosen == key
                                            OutlinedButton(onClick = { if (!checked) chosen = key },
                                                modifier = Modifier.fillMaxWidth(),
                                                colors = ButtonDefaults.outlinedButtonColors(
                                                    containerColor = if (isChosen) Color(0xFFE9E1FF) else Color.White
                                                )) { Text("$key. $value") }
                                        }
                                        Button(onClick = {
                                            if (chosen != null && !checked) {
                                                checked = true
                                                if (chosen == q.answer) score++
                                            }
                                        }, enabled = chosen != null && !checked, modifier = Modifier.fillMaxWidth()) {
                                            Text("উত্তর যাচাই")
                                        }
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
                item { Text("জ্ঞানবাড়ি • শেখার আনন্দময় সঙ্গী", color = Color.Gray, style = MaterialTheme.typography.bodySmall) }
            }
        }
    }
}
