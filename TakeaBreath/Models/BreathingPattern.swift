import Foundation
import SwiftUI

struct BreathingPattern: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let inhaleSeconds: Int
    let holdInhaleSeconds: Int
    let exhaleSeconds: Int
    let holdExhaleSeconds: Int
    let systemImage: String
    let color: Color
    
    init(id: UUID = UUID(), name: String, description: String, inhaleSeconds: Int,
         holdInhaleSeconds: Int = 0, exhaleSeconds: Int, holdExhaleSeconds: Int = 0,
         systemImage: String, color: Color)
    {
        self.id = id
        self.name = name
        self.description = description
        self.inhaleSeconds = inhaleSeconds
        self.holdInhaleSeconds = holdInhaleSeconds
        self.exhaleSeconds = exhaleSeconds
        self.holdExhaleSeconds = holdExhaleSeconds
        self.systemImage = systemImage
        self.color = color
    }
    
    var totalCycleDuration: Int {
        inhaleSeconds + holdInhaleSeconds + exhaleSeconds + holdExhaleSeconds
    }
    
    static let presets: [BreathingPattern] = [
        BreathingPattern(
            name: "Box Breathing",
            description: "Equal parts inhale, hold, exhale, and hold for deep relaxation",
            inhaleSeconds: 4,
            holdInhaleSeconds: 4,
            exhaleSeconds: 4,
            holdExhaleSeconds: 4,
            systemImage: "square",
            color: .blue
        ),
        BreathingPattern(
            name: "Relaxation Breath",
            description: "Longer exhale promotes relaxation and stress relief",
            inhaleSeconds: 4,
            holdInhaleSeconds: 7,
            exhaleSeconds: 8,
            systemImage: "leaf",
            color: .green
        ),
        BreathingPattern(
            name: "Energy Boost",
            description: "Quick, energizing breaths to increase alertness",
            inhaleSeconds: 2,
            exhaleSeconds: 2,
            systemImage: "bolt",
            color: .orange
        ),
        BreathingPattern(
            name: "Calm Breath",
            description: "Gentle, balanced breathing for everyday mindfulness",
            inhaleSeconds: 5,
            exhaleSeconds: 5,
            systemImage: "wind",
            color: .purple
        )
    ]
}

struct BreathingSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let patternId: UUID
    let durationSeconds: Int
    let completedCycles: Int
    
    init(id: UUID = UUID(), date: Date = Date(), patternId: UUID,
         durationSeconds: Int, completedCycles: Int)
    {
        self.id = id
        self.date = date
        self.patternId = patternId
        self.durationSeconds = durationSeconds
        self.completedCycles = completedCycles
    }
}

enum BreathingPhase: String {
    case inhale = "Inhale"
    case holdInhale = "Hold"
    case exhale = "Exhale"
    case holdExhale = "Rest"
    
    var instruction: String {
        switch self {
        case .inhale: return "Breathe in slowly"
        case .holdInhale: return "Hold your breath"
        case .exhale: return "Release slowly"
        case .holdExhale: return "Rest and prepare"
        }
    }
}

struct BreathingReminder: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var days: Set<Int> // 1 = Sunday, 7 = Saturday
    
    init(id: UUID = UUID(), time: Date = Date(), isEnabled: Bool = true, days: Set<Int> = Set(1 ... 7)) {
        self.id = id
        self.time = time
        self.isEnabled = isEnabled
        self.days = days
    }
}
