import Foundation
import UIKit
import MediaPlayer

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var nowPlayingInfo: [String: Any] = [:]
    
    private init() {
        setupNowPlaying()
        setupRemoteCommandCenter()
    }
    
    func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func setupNowPlaying() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Clear all commands
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.stopCommand.isEnabled = false
        commandCenter.togglePlayPauseCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        // Enable only what we need
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.stopCommand.isEnabled = true
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .timerPlayPauseToggled, object: nil)
            return .success
        }
        
        commandCenter.stopCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .timerStopped, object: nil)
            return .success
        }
    }
    
    func updateNowPlayingInfo(title: String, timeRemaining: TimeInterval, isPlaying: Bool) {
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeRemaining
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension Notification.Name {
    static let timerPlayPauseToggled = Notification.Name("timerPlayPauseToggled")
    static let timerStopped = Notification.Name("timerStopped")
} 