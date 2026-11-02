package com.gyanbari.desktop

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

private val levels = listOf("Playgroup", "Nursery", "KG", "Class One")
private val subjects = listOf("বাংলা", "English", "গণিত", "Science", "পরিবেশ ও সমাজ", "আরবি")

fun main() = application {
    Window(onCloseRequest = ::exitApplication, title = "SHIKHONIX | SHIKHONIX") {
        var selectedLevel by remember { mutableStateOf(levels.first()) }
        var selectedSubject by remember { mutableStateOf(subjects.first()) }
        MaterialTheme {
            Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                Column(
                    modifier = Modifier.fillMaxSize().padding(28.dp),
                    verticalArrangement = Arrangement.spacedBy(18.dp)
                ) {
                    Text("SHIKHONIX", style = MaterialTheme.typography.headlineLarge)
                    Text("শিশুর আনন্দময় শেখার জগৎ", style = MaterialTheme.typography.titleMedium)
                    Text("শ্রেণি নির্বাচন", style = MaterialTheme.typography.titleLarge)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        levels.forEach { level ->
                            Button(onClick = { selectedLevel = level }) { Text(level) }
                        }
                    }
                    Card(modifier = Modifier.fillMaxWidth()) {
                        Column(modifier = Modifier.padding(18.dp)) {
                            Text("নির্বাচিত স্তর: $selectedLevel", style = MaterialTheme.typography.titleLarge)
                            Spacer(Modifier.height(8.dp))
                            Text("বিষয় নির্বাচন", style = MaterialTheme.typography.titleMedium)
                            Spacer(Modifier.height(8.dp))
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                subjects.take(3).forEach { subject ->
                                    Button(onClick = { selectedSubject = subject }) { Text(subject) }
                                }
                            }
                            Spacer(Modifier.height(8.dp))
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                subjects.drop(3).forEach { subject ->
                                    Button(onClick = { selectedSubject = subject }) { Text(subject) }
                                }
                            }
                            Spacer(Modifier.height(12.dp))
                            Text("নির্বাচিত বিষয়: $selectedSubject")
                            Spacer(Modifier.height(8.dp))
                            Text("পাঠ, ছবি, উচ্চারণ, কুইজ ও শেখার অগ্রগতি—পরবর্তী ধাপে Android-এর মূল কনটেন্টের সঙ্গে যুক্ত হবে।")
                        }
                    }
                    Spacer(Modifier.weight(1f))
                    Text("SHIKHONIX Desktop • প্রাথমিক cross-platform shell")
                }
            }
        }
    }
}
