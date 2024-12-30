import SwiftUI

class MoodTrackingViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var insights: [MoodInsight] = []
    @Published var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame {
        case week
        case month
        case year
    }
    
    init() {
        loadMoods()
        generateInsights()
    }
    
    func addMood(_ mood: Mood) {
        moods.append(mood)
        saveMoods()
        generateInsights()
    }
    
    private func loadMoods() {
        // In a real app, this would load from persistent storage
        if let data = UserDefaults.standard.data(forKey: "moods"),
           let decodedMoods = try? JSONDecoder().decode([Mood].self, from: data) {
            moods = decodedMoods
        }
    }
    
    private func saveMoods() {
        if let encoded = try? JSONEncoder().encode(moods) {
            UserDefaults.standard.set(encoded, forKey: "moods")
        }
    }
    
    func moodsForTimeFrame() -> [Mood] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .week:
            let startOfWeek = calendar.date(byAdding: .day, value: -7, to: now)!
            return moods.filter { $0.date >= startOfWeek }
        case .month:
            let startOfMonth = calendar.date(byAdding: .month, value: -1, to: now)!
            return moods.filter { $0.date >= startOfMonth }
        case .year:
            let startOfYear = calendar.date(byAdding: .year, value: -1, to: now)!
            return moods.filter { $0.date >= startOfYear }
        }
    }
    
    func generateInsights() {
        var newInsights: [MoodInsight] = []
        let recentMoods = moodsForTimeFrame()
        
        // Analyze stress patterns
        let stressedMoods = recentMoods.filter { $0.emotion == .stressed }
        if stressedMoods.count > recentMoods.count / 3 {
            newInsights.append(MoodInsight(
                title: "High Stress Levels",
                description: "You've been feeling stressed more often lately.",
                recommendation: "Consider increasing meditation sessions and trying stress-relief exercises.",
                type: .needsAttention
            ))
        }
        
        // Analyze meditation impact
        let meditationDays = Set(recentMoods.filter { $0.activities.contains(.meditation) }.map { calendar.startOfDay(for: $0.date) })
        let nonMeditationDays = Set(recentMoods.filter { !$0.activities.contains(.meditation) }.map { calendar.startOfDay(for: $0.date) })
        
        let meditationMoodAverage = calculateAverageMoodIntensity(for: meditationDays)
        let nonMeditationMoodAverage = calculateAverageMoodIntensity(for: nonMeditationDays)
        
        if meditationMoodAverage > nonMeditationMoodAverage {
            newInsights.append(MoodInsight(
                title: "Meditation Benefits",
                description: "Your mood tends to be better on days when you meditate.",
                recommendation: "Keep up your meditation practice for better emotional well-being.",
                type: .positive
            ))
        }
        
        insights = newInsights
    }
    
    private func calculateAverageMoodIntensity(for days: Set<Date>) -> Double {
        let relevantMoods = moods.filter { days.contains(calendar.startOfDay(for: $0.date)) }
        let totalIntensity = relevantMoods.reduce(0) { $0 + $1.intensity }
        return Double(totalIntensity) / Double(max(1, relevantMoods.count))
    }
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    // Helper function to get mood distribution
    func moodDistribution() -> [(emotion: Emotion, count: Int)] {
        let timeFrameMoods = moodsForTimeFrame()
        return Emotion.allCases.map { emotion in
            let count = timeFrameMoods.filter { $0.emotion == emotion }.count
            return (emotion, count)
        }.sorted { $0.count > $1.count }
    }
    
    // Helper function to get activity correlation
    func activityCorrelation() -> [(activity: Activity, averageMood: Double)] {
        let timeFrameMoods = moodsForTimeFrame()
        return Activity.allCases.map { activity in
            let moodsWithActivity = timeFrameMoods.filter { $0.activities.contains(activity) }
            let averageIntensity = moodsWithActivity.reduce(0.0) { $0 + Double($1.intensity) }
            return (activity, averageIntensity / Double(max(1, moodsWithActivity.count)))
        }.sorted { $0.averageMood > $1.averageMood }
    }
} 