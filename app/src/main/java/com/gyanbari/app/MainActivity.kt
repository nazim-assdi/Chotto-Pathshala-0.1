package com.gyanbari.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private data class LearningCard(val title: String, val detail: String)

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
        LearningCard("বাংলা", "পড়া, শব্দভান্ডার ও অনুশীলন"),
        LearningCard("English", "Vocabulary, reading and practice"),
        LearningCard("আরবি", "হরফ, শব্দ ও উচ্চারণ"),
        LearningCard("গণিত", "সংখ্যা, হিসাব ও সমস্যা সমাধান"),
        LearningCard("বিজ্ঞান", "প্রকৃতি, পরিবেশ ও আবিষ্কার"),
        LearningCard("সাধারণ জ্ঞান", "বাংলাদেশ ও বিশ্বপরিচয়")
    )
    var selected by remember { mutableStateOf("হোম") }
    MaterialTheme {
        Scaffold(topBar = { TopAppBar(title = { Text("জ্ঞানবাড়ি") }) }) { padding ->
            LazyColumn(modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                item {
                    Text("শিখি প্রতিদিন, এগিয়ে যাই", style = MaterialTheme.typography.headlineSmall)
                    Text("অফলাইন-প্রথম শিশুদের ডিজিটাল শিক্ষাগার")
                    Spacer(Modifier.height(12.dp))
                    Text("আজকের পাঠ", style = MaterialTheme.typography.titleLarge)
                    Card(Modifier.fillMaxWidth()) {
                        Column(Modifier.padding(16.dp)) {
                            Text("পাঠ ১: শেখার আনন্দ", style = MaterialTheme.typography.titleMedium)
                            Text("প্রতিদিন নতুন কিছু শেখা আমাদের জ্ঞান ও দক্ষতা বাড়ায়। মনোযোগ দিয়ে পড়ি, উদাহরণ বুঝি এবং নিজে অনুশীলন করি।")
                            Text("অনুশীলন: আজ তুমি নতুন কী শিখলে? নিজের ভাষায় দুটি বাক্য লেখো।")
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                    Text("বিষয় নির্বাচন", style = MaterialTheme.typography.titleLarge)
                }
                items(subjects) { subject ->
                    Card(onClick = { selected = subject.title }, modifier = Modifier.fillMaxWidth()) {
                        Column(Modifier.padding(16.dp)) {
                            Text(subject.title, style = MaterialTheme.typography.titleMedium)
                            Text(subject.detail)
                        }
                    }
                }
                item {
                    if (selected != "হোম") {
                        Text("নির্বাচিত বিষয়: $selected", style = MaterialTheme.typography.titleMedium)
                        Text("এই বিষয়ের পাঠ, কুইজ ও অডিও কনটেন্ট পরবর্তী ধাপে যুক্ত হবে।")
                    }
                    Spacer(Modifier.height(16.dp))
                    Text("সংস্করণ 0.1.0 • প্রাথমিক অফলাইন অ্যাপ কাঠামো", style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
