import SwiftUI
import MediaPlayer
import WidgetKit

class BreakTimerViewModel: ObservableObject {
    @Published var currentTimer: BreakTimer?
    @Published var state: TimerState = .idle
    @Published var currentRound: Int = 1
    @Published var timeRemaining: TimeInterval = 0
    @Published var progress: Double = 0
    
    private var timer: Timer?
    private let timerManager = TimerManager.shared
    private let defaults = UserDefaults(suiteName: "group.com.kamay.TakeaBreath")
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayPauseToggle),
            name: .timerPlayPauseToggled,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStop),
            name: .timerStopped,
            object: nil
        )
    }
    
    @objc private func handlePlayPauseToggle() {
        if state == .paused {
            resumeTimer()
        } else if state == .working || state == .onBreak {
            pauseTimer()
        }
    }
    
    @objc private func handleStop() {
        stopTimer()
    }
    
    func startTimer(_ breakTimer: BreakTimer) {
        currentTimer = breakTimer
        currentRound = 1
        state = .working
        timeRemaining = breakTimer.workDuration
        timerManager.beginBackgroundTask()
        startCountdown()
        updateNowPlayingInfo()
        updateWidgetInfo(isRunning: true)
    }
    
    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateTimer() {
        guard let currentTimer = currentTimer else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            updateProgress()
            updateNowPlayingInfo()
            updateWidgetInfo(isRunning: true)
        } else {
            switch state {
            case .working:
                if currentRound < currentTimer.rounds {
                    state = .onBreak
                    timeRemaining = currentTimer.breakDuration
                    updateProgress()
                    updateNowPlayingInfo()
                    updateWidgetInfo(isRunning: true)
                } else {
                    completeSession()
                }
            case .onBreak:
                currentRound += 1
                state = .working
                timeRemaining = currentTimer.workDuration
                updateProgress()
                updateNowPlayingInfo()
                updateWidgetInfo(isRunning: true)
            default:
                break
            }
        }
    }
    
    private func updateProgress() {
        guard let currentTimer = currentTimer else { return }
        let totalDuration = state == .working ? currentTimer.workDuration : currentTimer.breakDuration
        progress = 1 - (timeRemaining / totalDuration)
    }
    
    private func updateNowPlayingInfo() {
        let title = "\(state.description) - Round \(currentRound)"
        timerManager.updateNowPlayingInfo(
            title: title,
            timeRemaining: timeRemaining,
            isPlaying: state == .working || state == .onBreak
        )
    }
    
    private func updateWidgetInfo(isRunning: Bool) {
        defaults?.set(timeRemaining, forKey: "timeRemaining")
        defaults?.set(isRunning, forKey: "isRunning")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func pauseTimer() {
        timer?.invalidate()
        state = .paused
        updateNowPlayingInfo()
        updateWidgetInfo(isRunning: false)
    }
    
    func resumeTimer() {
        state = timeRemaining == currentTimer?.workDuration ? .working : .onBreak
        startCountdown()
        updateNowPlayingInfo()
        updateWidgetInfo(isRunning: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timerManager.endBackgroundTask()
        state = .idle
        timeRemaining = 0
        progress = 0
        currentRound = 1
        updateNowPlayingInfo()
        updateWidgetInfo(isRunning: false)
    }
    
    private func completeSession() {
        timer?.invalidate()
        timerManager.endBackgroundTask()
        state = .completed
        progress = 1
        updateNowPlayingInfo()
        updateWidgetInfo(isRunning: false)
    }
    
    deinit {
        timer?.invalidate()
        timerManager.endBackgroundTask()
        NotificationCenter.default.removeObserver(self)
    }
} 