import SwiftUI

@main
struct ShikhonixApp: App {
    var body: some Scene {
        WindowGroup {
            LearningHomeView()
        }
    }
}

struct LearningHomeView: View {
    @State private var selectedLevel = "Playgroup"
    @State private var selectedSubject = "বাংলা"

    private let levels = ["Playgroup", "Nursery", "KG", "Class One"]
    private let subjects = ["বাংলা", "English", "গণিত", "Science", "পরিবেশ ও সমাজ", "আরবি"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SHIKHONIX")
                            .font(.largeTitle.bold())
                        Text("শিশুর আনন্দময় শেখার জগৎ")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    Text("শ্রেণি নির্বাচন")
                        .font(.title2.bold())
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(levels, id: \.self) { level in
                            Button {
                                selectedLevel = level
                            } label: {
                                Text(level)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedLevel == level ? Color.blue.opacity(0.16) : Color.gray.opacity(0.10))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("বিষয় নির্বাচন")
                        .font(.title2.bold())
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(subjects, id: \.self) { subject in
                            Button {
                                selectedSubject = subject
                            } label: {
                                Text(subject)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedSubject == subject ? Color.green.opacity(0.16) : Color.gray.opacity(0.10))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("নির্বাচিত: \(selectedLevel) • \(selectedSubject)")
                        .font(.headline)
                    Text("এটি iPhone ও iPad-এর প্রাথমিক অ্যাপ শেল। পরবর্তী ধাপে মূল পাঠ, কুইজ, ছবি, ভয়েস ও অগ্রগতির ডেটা যুক্ত হবে।")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("SHIKHONIX")
        }
    }
}
