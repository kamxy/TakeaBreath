import Foundation

struct Meditation: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let duration: TimeInterval
    let category: MeditationCategory
    let audioURL: String
    let imageURL: String
    var isPremium: Bool
    
    init(id: UUID = UUID(), title: String, description: String, duration: TimeInterval, 
         category: MeditationCategory, audioURL: String, imageURL: String, isPremium: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.category = category
        self.audioURL = audioURL
        self.imageURL = imageURL
        self.isPremium = isPremium
    }
}

enum MeditationCategory: String, Codable, CaseIterable {
    case stress = "Stress Relief"
    case sleep = "Better Sleep"
    case focus = "Focus"
    case anxiety = "Anxiety"
    case mindfulness = "Mindfulness"
    
    var systemImage: String {
        switch self {
        case .stress: return "wind"
        case .sleep: return "moon.stars"
        case .focus: return "brain.head.profile"
        case .anxiety: return "heart.circle"
        case .mindfulness: return "leaf"
        }
    }
} 