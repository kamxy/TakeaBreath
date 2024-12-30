import Foundation

struct BreakTimer: Identifiable, Codable {
    let id: UUID
    var title: String
    var workDuration: TimeInterval
    var breakDuration: TimeInterval
    var rounds: Int
    var isPomodoro: Bool
    
    init(id: UUID = UUID(), title: String, workDuration: TimeInterval = 25 * 60,
         breakDuration: TimeInterval = 5 * 60, rounds: Int = 4, isPomodoro: Bool = true) {
        self.id = id
        self.title = title
        self.workDuration = workDuration
        self.breakDuration = breakDuration
        self.rounds = rounds
        self.isPomodoro = isPomodoro
    }
}

enum TimerState {
    case idle
    case working
    case onBreak
    case paused
    case completed
    
    var description: String {
        switch self {
        case .idle: return NSLocalizedString("Ready to Start", comment: "Timer state when ready to start")
        case .working: return NSLocalizedString("Focus Time", comment: "Timer state during work session")
        case .onBreak: return NSLocalizedString("Break Time", comment: "Timer state during break")
        case .paused: return NSLocalizedString("Paused", comment: "Timer state when paused")
        case .completed: return NSLocalizedString("Completed", comment: "Timer state when completed")
        }
    }
} 