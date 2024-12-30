import Charts
import SwiftUI

struct MoodTrackingView: View {
    @StateObject private var viewModel = MoodTrackingViewModel()
    @State private var showingMoodInput = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Mood Button
                    Button(action: { showingMoodInput = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log Your Mood")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Time Frame Picker
                    Picker("Time Frame", selection: $viewModel.selectedTimeFrame) {
                        Text("Week").tag(MoodTrackingViewModel.TimeFrame.week)
                        Text("Month").tag(MoodTrackingViewModel.TimeFrame.month)
                        Text("Year").tag(MoodTrackingViewModel.TimeFrame.year)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Mood Distribution Chart
                    VStack(alignment: .leading) {
                        Text("Mood Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(viewModel.moodDistribution(), id: \.emotion) { item in
                                BarMark(
                                    x: .value("Emotion", item.emotion.rawValue),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(Color(item.emotion.color))
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Activity Impact
                    VStack(alignment: .leading) {
                        Text("Activity Impact")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(viewModel.activityCorrelation(), id: \.activity) { item in
                                BarMark(
                                    x: .value("Activity", item.activity.rawValue),
                                    y: .value("Average Mood", item.averageMood)
                                )
                                .foregroundStyle(Color.green)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // AI Insights
                    if !viewModel.insights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Insights")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.insights) { insight in
                                InsightCard(insight: insight)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Mood Tracking")
            .sheet(isPresented: $showingMoodInput) {
                MoodInputView(viewModel: viewModel)
            }
        }
    }
}

struct MoodInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MoodTrackingViewModel
    @State private var selectedEmotion: Emotion = .happy
    @State private var intensity: Double = 3
    @State private var note: String = ""
    @State private var selectedActivities: Set<Activity> = []
    
    var body: some View {
        NavigationView {
            Form {
                // Emotion Selection
                Section("How are you feeling?") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(Emotion.allCases, id: \.self) { emotion in
                                EmotionButton(
                                    emotion: emotion,
                                    isSelected: selectedEmotion == emotion,
                                    action: { selectedEmotion = emotion }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Intensity
                Section("Intensity") {
                    VStack {
                        Slider(value: $intensity, in: 1 ... 5, step: 1)
                        HStack {
                            Text("Mild")
                            Spacer()
                            Text("Strong")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                // Activities
                Section("What have you been doing?") {
                    ForEach(Activity.allCases, id: \.self) { activity in
                        HStack {
                            Image(systemName: activity.systemImage)
                            Text(activity.rawValue)
                            Spacer()
                            if selectedActivities.contains(activity) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedActivities.contains(activity) {
                                selectedActivities.remove(activity)
                            } else {
                                selectedActivities.insert(activity)
                            }
                        }
                    }
                }
                
                // Notes
                Section("Notes (Optional)") {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Mood")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let mood = Mood(
                        emotion: selectedEmotion,
                        intensity: Int(intensity),
                        note: note.isEmpty ? nil : note,
                        activities: Array(selectedActivities)
                    )
                    viewModel.addMood(mood)
                    dismiss()
                }
            )
        }
    }
}

struct EmotionButton: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: emotion.systemImage)
                    .font(.title2)
                Text(emotion.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color(emotion.color) : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct InsightCard: View {
    let insight: MoodInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                Text(insight.title)
                    .font(.headline)
            }
            
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(insight.recommendation)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var iconName: String {
        switch insight.type {
        case .positive: return "checkmark.circle.fill"
        case .neutral: return "info.circle.fill"
        case .needsAttention: return "exclamationmark.triangle.fill"
        }
    }
    
    private var color: Color {
        switch insight.type {
        case .positive: return .green
        case .neutral: return .blue
        case .needsAttention: return .orange
        }
    }
}

#Preview {
    MoodTrackingView()
}
