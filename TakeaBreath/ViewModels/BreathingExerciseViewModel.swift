import SwiftUI
import UserNotifications

class BreathingExerciseViewModel: ObservableObject {
    @Published var selectedPattern: BreathingPattern
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var timeRemaining: Int = 0
    @Published var isActive: Bool = false
    @Published var completedCycles: Int = 0
    @Published var totalDuration: Int = 300 // 5 minutes default
    @Published var progress: Double = 0
    @Published var showingReminders = false
    @Published var reminders: [BreathingReminder] = []
    @Published var sessions: [BreathingSession] = []
    
    private var timer: Timer?
    private var phaseStartTime: Date?
    
    init() {
        selectedPattern = BreathingPattern.presets[0]
        loadReminders()
        loadSessions()
    }
    
    func startExercise() {
        isActive = true
        currentPhase = .inhale
        timeRemaining = selectedPattern.inhaleSeconds
        completedCycles = 0
        progress = 0
        phaseStartTime = Date()
        
        startTimer()
    }
    
    func pauseExercise() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }
    
    func resumeExercise() {
        isActive = true
        startTimer()
    }
    
    func stopExercise() {
        timer?.invalidate()
        timer = nil
        isActive = false
        
        // Save session
        let session = BreathingSession(
            patternId: selectedPattern.id,
            durationSeconds: Int(Date().timeIntervalSince(phaseStartTime ?? Date())),
            completedCycles: completedCycles
        )
        sessions.append(session)
        saveSessions()
        currentPhase = .inhale
        timeRemaining = selectedPattern.inhaleSeconds
        completedCycles = 0
        progress = 0
        phaseStartTime = Date()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            moveToNextPhase()
            return
        }
        
        timeRemaining -= 1
        updateProgress()
    }
    
    private func moveToNextPhase() {
        switch currentPhase {
        case .inhale:
            if selectedPattern.holdInhaleSeconds > 0 {
                currentPhase = .holdInhale
                timeRemaining = selectedPattern.holdInhaleSeconds
            } else {
                currentPhase = .exhale
                timeRemaining = selectedPattern.exhaleSeconds
            }
        case .holdInhale:
            currentPhase = .exhale
            timeRemaining = selectedPattern.exhaleSeconds
        case .exhale:
            if selectedPattern.holdExhaleSeconds > 0 {
                currentPhase = .holdExhale
                timeRemaining = selectedPattern.holdExhaleSeconds
            } else {
                completeCycle()
            }
        case .holdExhale:
            completeCycle()
        }
        
        updateProgress()
    }
    
    private func completeCycle() {
        completedCycles += 1
        if Double(completedCycles * selectedPattern.totalCycleDuration) >= Double(totalDuration) {
            stopExercise()
        } else {
            currentPhase = .inhale
            timeRemaining = selectedPattern.inhaleSeconds
        }
    }
    
    private func updateProgress() {
        let elapsedTime = Date().timeIntervalSince(phaseStartTime ?? Date())
        progress = min(1.0, elapsedTime / Double(totalDuration))
    }
    
    // MARK: - Reminders Management
    
    func addReminder(_ reminder: BreathingReminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func toggleReminder(_ reminder: BreathingReminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isEnabled.toggle()
            saveReminders()
            
            if reminders[index].isEnabled {
                scheduleNotification(for: reminders[index])
            } else {
                cancelNotification(for: reminder)
            }
        }
    }
    
    func deleteReminder(_ reminder: BreathingReminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        cancelNotification(for: reminder)
    }
    
    private func scheduleNotification(for reminder: BreathingReminder) {
        let content = UNMutableNotificationContent()
        content.title = "Time for Breathing Exercise"
        content.body = "Take a moment to breathe and relax"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)
        
        for day in reminder.days {
            var triggerComponents = DateComponents()
            triggerComponents.hour = components.hour
            triggerComponents.minute = components.minute
            triggerComponents.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "\(reminder.id)-\(day)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func cancelNotification(for reminder: BreathingReminder) {
        let identifiers = reminder.days.map { "\(reminder.id)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Persistence
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: "breathingReminders"),
           let decoded = try? JSONDecoder().decode([BreathingReminder].self, from: data)
        {
            reminders = decoded
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "breathingReminders")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "breathingSessions"),
           let decoded = try? JSONDecoder().decode([BreathingSession].self, from: data)
        {
            sessions = decoded
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "breathingSessions")
        }
    }
    
    // MARK: - Statistics
    
    var totalSessionsCount: Int {
        sessions.count
    }
    
    var totalBreathingMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }
    
    var averageSessionDuration: Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.durationSeconds } / sessions.count
    }
    
    var dailySessionMinutes: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaySessions = sessions.filter {
            calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: today)
        }
        
        return todaySessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let sessionsForDay = sessions.filter {
                calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: currentDate)
            }
            
            if sessionsForDay.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
            
            // Check if there's a gap in the streak
            let nextDaySessions = sessions.filter {
                calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: currentDate)
            }
            
            if nextDaySessions.isEmpty {
                break
            }
        }
        
        return streak
    }
}
