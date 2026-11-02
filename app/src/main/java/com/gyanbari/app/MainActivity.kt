package com.gyanbari.app

import android.os.Bundle
import androidx.activity.ComponentActivity
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

private data class LearningCard(val title: String, val detail: String, val emoji: String)
private data class Lesson(val title: String, val body: String, val question: String, val answer: String)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { GyanbariApp() }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun GyanbariApp() {
    val subjects = listOf(
        LearningCard("বাংলা", "গল্প, বর্ণ ও শব্দ শেখা", "📖"),
        LearningCard("English", "Letters, words and reading", "🔤"),
        LearningCard("আরবি", "হরফ ও সহজ শব্দ", "🌙"),
        LearningCard("গণিত", "সংখ্যা ও মজার অঙ্ক", "🧮"),
        LearningCard("বিজ্ঞান", "প্রকৃতি ও আবিষ্কার", "🔬"),
        LearningCard("সাধারণ জ্ঞান", "দেশ ও পৃথিবী", "🌍")
    )
    val lessons = mapOf(
        "বাংলা" to Lesson("পাঠ ১: স্বরবর্ণ", "বাংলা ভাষায় ১১টি স্বরবর্ণ আছে। যেমন: অ, আ, ই, ঈ, উ। আমরা কথা বলি, পড়ি ও লিখি বাংলা ভাষায়।", "বাংলা ভাষার প্রথম স্বরবর্ণ কোনটি?", "অ — বাংলা স্বরবর্ণের প্রথমটি হলো অ।"),
        "English" to Lesson("Lesson 1: Vowels", "There are five main vowels in English: A, E, I, O, U. The word apple begins with A.", "Which letter begins the word Apple?", "A — Apple starts with the letter A."),
        "আরবি" to Lesson("পাঠ ১: আলিফ", "আরবি বর্ণমালার প্রথম হরফ হলো ا (আলিফ)। আরবি ডান দিক থেকে বাম দিকে লেখা হয়।", "আরবি বর্ণমালার প্রথম হরফ কোনটি?", "ا — এর নাম আলিফ।"),
        "গণিত" to Lesson("পাঠ ১: যোগ", "দুটি সংখ্যা একসঙ্গে করলে তাকে যোগ বলে। যেমন: ২টি আমের সঙ্গে ৩টি আম যোগ করলে মোট ৫টি আম হয়।", "৪ + ৩ = কত?", "৭ — কারণ ৪টির সঙ্গে আরও ৩টি যোগ করলে ৭টি হয়।"),
        "বিজ্ঞান" to Lesson("পাঠ ১: গাছের উপকারিতা", "গাছ আমাদের অক্সিজেন দেয়, ছায়া দেয় এবং ফল দেয়। গাছ পরিবেশ সুন্দর রাখে।", "গাছ আমাদের শ্বাস নেওয়ার জন্য কোন গ্যাস দেয়?", "অক্সিজেন।"),
        "সাধারণ জ্ঞান" to Lesson("পাঠ ১: বাংলাদেশ", "বাংলাদেশ দক্ষিণ এশিয়ার একটি দেশ। আমাদের দেশের রাজধানীর নাম ঢাকা। জাতীয় ফুল শাপলা এবং জাতীয় ফল কাঁঠাল।", "বাংলাদেশের রাজধানীর নাম কী?", "ঢাকা — ঢাকাই বাংলাদেশের রাজধানী।")
    )

    var selected by remember { mutableStateOf<String?>(null) }
    var answerVisible by remember { mutableStateOf(false) }
    val colors = lightColorScheme(
        primary = Color(0xFF7046C7),
        secondary = Color(0xFFE875A6),
        tertiary = Color(0xFFFFB84D),
        background = Color(0xFFFFF8EC),
        surface = Color(0xFFFFFFFF)
    )

    MaterialTheme(colorScheme = colors) {
        Scaffold(
            containerColor = Color(0xFFFFF8EC),
            topBar = {
                TopAppBar(
                    title = { Text("🌈 জ্ঞানবাড়ি", color = Color.White) },
                    colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF7046C7))
                )
            }
        ) { padding ->
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding).padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(13.dp),
                contentPadding = PaddingValues(top = 18.dp, bottom = 28.dp)
            ) {
                if (selected == null) {
                    item {
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color(0xFFFFE8A8)),
                            shape = RoundedCornerShape(24.dp)
                        ) {
                            Column(Modifier.padding(20.dp)) {
                                Text("⭐ ছোট্ট শিক্ষার্থীদের শেখার জগৎ", color = Color(0xFF704600))
                                Text("আজ কী শিখবে তুমি?", style = MaterialTheme.typography.headlineSmall, color = Color(0xFF6842B5))
                                Text("তোমার পছন্দের বিষয়ে চাপ দাও। নতুন পাঠ পড়ো, উদাহরণ দেখো আর নিজে অনুশীলন করো।")
                            }
                        }
                        Text("🎒 বিষয় বেছে নাও", style = MaterialTheme.typography.titleLarge, modifier = Modifier.padding(top = 8.dp))
                    }
                    items(subjects) { subject ->
                        Card(
                            onClick = { selected = subject.title; answerVisible = false },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(20.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = when (subject.title) {
                                    "বাংলা" -> Color(0xFFFFE0E5)
                                    "English" -> Color(0xFFDFF3FF)
                                    "আরবি" -> Color(0xFFE9E1FF)
                                    "গণিত" -> Color(0xFFFFF0BD)
                                    "বিজ্ঞান" -> Color(0xFFDFF6DF)
                                    else -> Color(0xFFFFE6CE)
                                }
                            )
                        ) {
                            Column(Modifier.padding(19.dp)) {
                                Text(subject.emoji, style = MaterialTheme.typography.headlineMedium)
                                Text(subject.title, style = MaterialTheme.typography.titleLarge)
                                Text(subject.detail)
                                Text("পাঠে প্রবেশ করো  →", color = Color(0xFF7046C7), style = MaterialTheme.typography.labelLarge)
                            }
                        }
                    }
                } else {
                    val lesson = lessons[selected]!!
                    item {
                        OutlinedButton(onClick = { selected = null; answerVisible = false }) {
                            Text("← বিষয় তালিকায় ফিরে যাও")
                        }
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            shape = RoundedCornerShape(22.dp)
                        ) {
                            Column(Modifier.padding(20.dp)) {
                                Text(selected!!, style = MaterialTheme.typography.titleMedium, color = Color(0xFF7046C7))
                                Text(lesson.title, style = MaterialTheme.typography.headlineSmall)
                                Spacer(Modifier.height(12.dp))
                                Text(lesson.body, style = MaterialTheme.typography.bodyLarge)
                                Spacer(Modifier.height(20.dp))
                                Text("✏️ এবার তুমি চেষ্টা করো", style = MaterialTheme.typography.titleMedium)
                                Text(lesson.question, modifier = Modifier.padding(top = 8.dp))
                                Button(onClick = { answerVisible = true }, modifier = Modifier.padding(top = 12.dp)) {
                                    Text("উত্তর দেখাও")
                                }
                                if (answerVisible) {
                                    Text(lesson.answer, color = Color(0xFF287A45), style = MaterialTheme.typography.bodyLarge)
                                }
                            }
                        }
                    }
                }
                item {
                    Text("জ্ঞানবাড়ি • শিশুদের শেখার আনন্দময় সঙ্গী", color = Color.Gray, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
