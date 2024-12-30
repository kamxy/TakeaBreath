import Foundation
import SwiftUI

struct Mood: Identifiable, Codable {
    let id: UUID
    let date: Date
    let emotion: Emotion
    let intensity: Int // 1-5 scale
    let note: String?
    let activities: [Activity]

    init(id: UUID = UUID(), date: Date = Date(), emotion: Emotion, intensity: Int, note: String? = nil, activities: [Activity] = []) {
        self.id = id
        self.date = date
        self.emotion = emotion
        self.intensity = max(1, min(5, intensity))
        self.note = note
        self.activities = activities
    }
}

enum Emotion: String, Codable, CaseIterable {
    case happy = "Happy"
    case calm = "Calm"
    case energetic = "Energetic"
    case tired = "Tired"
    case stressed = "Stressed"
    case anxious = "Anxious"
    case sad = "Sad"

    var systemImage: String {
        switch self {
        case .happy: return "face.smiling"
        case .calm: return "leaf"
        case .energetic: return "bolt"
        case .tired: return "zzz"
        case .stressed: return "exclamationmark.triangle"
        case .anxious: return "waveform.path.ecg"
        case .sad: return "cloud.rain"
        }
    }

    var color: Color {
        switch self {
        case .happy: return .yellow
        case .calm: return .mint
        case .energetic: return .orange
        case .tired: return .gray
        case .stressed: return .red
        case .anxious: return .purple
        case .sad: return .blue
        }
    }
}

enum Activity: String, Codable, CaseIterable {
    case meditation = "Meditation"
    case exercise = "Exercise"
    case work = "Work"
    case socializing = "Socializing"
    case reading = "Reading"
    case nature = "Nature"
    case sleep = "Sleep"

    var systemImage: String {
        switch self {
        case .meditation: return "sparkles"
        case .exercise: return "figure.walk"
        case .work: return "briefcase"
        case .socializing: return "person.2"
        case .reading: return "book"
        case .nature: return "leaf"
        case .sleep: return "moon"
        }
    }
}

struct MoodInsight: Identifiable {
    let id: UUID = .init()
    let title: String
    let description: String
    let recommendation: String
    let type: InsightType

    enum InsightType {
        case positive
        case neutral
        case needsAttention
    }
}
