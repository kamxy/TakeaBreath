import SwiftUI
import AVFoundation

class MeditationViewModel: ObservableObject {
    @Published var meditations: [Meditation] = []
    @Published var selectedMeditation: Meditation?
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0
    @Published var currentTime: TimeInterval = 0
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    init() {
        loadMeditations()
    }
    
    private func loadMeditations() {
        // In a real app, this would load from a backend service
        meditations = [
            Meditation(title: "Morning Mindfulness",
                      description: "Start your day with clarity and purpose",
                      duration: 600,
                      category: .mindfulness,
                      audioURL: "meditation1",
                      imageURL: "morning"),
            Meditation(title: "Stress Relief",
                      description: "Release tension and find calm",
                      duration: 900,
                      category: .stress,
                      audioURL: "meditation2",
                      imageURL: "stress"),
            // Add more meditations as needed
        ]
    }
    
    func play(_ meditation: Meditation) {
        selectedMeditation = meditation
        guard let url = Bundle.main.url(forResource: meditation.audioURL, withExtension: "mp3") else { return }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Add time observer
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.progress = time.seconds / meditation.duration
        }
        
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        progress = 0
        currentTime = 0
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
} 