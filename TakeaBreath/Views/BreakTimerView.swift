import SwiftUI

struct BreakTimerView: View {
    @StateObject private var viewModel = BreakTimerViewModel()
    @State private var showingTimerSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Timer Display
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 20)
                        .frame(width: 300, height: 300)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 8) {
                        Text(viewModel.state.description)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(viewModel.timeRemaining))
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                        
                        if viewModel.state != .idle {
                            Text("Round \(viewModel.currentRound)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                
                // Controls
                HStack(spacing: 40) {
                    // Reset Button
                    Button(action: {
                        viewModel.stopTimer()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .opacity(viewModel.state != .idle ? 1 : 0)
                    
                    // Play/Pause Button
                    Button(action: {
                        if viewModel.state == .idle {
                            showingTimerSettings = true
                        } else if viewModel.state == .paused {
                            viewModel.resumeTimer()
                        } else {
                            viewModel.pauseTimer()
                        }
                    }) {
                        Image(systemName: playPauseIcon)
                            .font(.system(size: 64))
                            .foregroundColor(.purple)
                    }
                    
                    // Settings Button
                    Button(action: {
                        showingTimerSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .opacity(viewModel.state == .idle ? 1 : 0)
                }
                
                Spacer()
            }
            .navigationTitle(NSLocalizedString("Break Timer", comment: "Navigation title"))
            .sheet(isPresented: $showingTimerSettings) {
                TimerSettingsView(viewModel: viewModel)
            }
        }
    }
    
    private var playPauseIcon: String {
        switch viewModel.state {
        case .idle:
            return "play.circle.fill"
        case .paused:
            return "play.circle.fill"
        default:
            return "pause.circle.fill"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BreakTimerViewModel
    @State private var workDuration: Double = 25
    @State private var breakDuration: Double = 5
    @State private var rounds: Double = 4
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("Work Session", comment: "Work session settings section"))) {
                    VStack {
                        Slider(value: $workDuration, in: 1...60, step: 1)
                        Text("\(Int(workDuration)) \(NSLocalizedString("minutes", comment: "Time unit"))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text(NSLocalizedString("Break Duration", comment: "Break duration settings section"))) {
                    VStack {
                        Slider(value: $breakDuration, in: 1...30, step: 1)
                        Text("\(Int(breakDuration)) \(NSLocalizedString("minutes", comment: "Time unit"))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text(NSLocalizedString("Number of Rounds", comment: "Rounds settings section"))) {
                    VStack {
                        Slider(value: $rounds, in: 1...10, step: 1)
                        Text("\(Int(rounds)) \(NSLocalizedString("rounds", comment: "Round count unit"))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Timer Settings", comment: "Settings view title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("Cancel", comment: "Cancel button")) {
                    dismiss()
                },
                trailing: Button(NSLocalizedString("Start", comment: "Start button")) {
                    let timer = BreakTimer(
                        title: NSLocalizedString("Focus Session", comment: "Default timer title"),
                        workDuration: workDuration * 60,
                        breakDuration: breakDuration * 60,
                        rounds: Int(rounds)
                    )
                    viewModel.startTimer(timer)
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    BreakTimerView()
} 