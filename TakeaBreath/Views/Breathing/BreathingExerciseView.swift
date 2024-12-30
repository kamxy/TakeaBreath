import SwiftUI

struct BreathingExerciseView: View {
    @StateObject private var viewModel = BreathingExerciseViewModel()
    @State private var showingPatternPicker = false
    @State private var showingReminders = false
    @State private var showingStats = false
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(viewModel.selectedPattern.color).opacity(0.3),
                        Color(viewModel.selectedPattern.color).opacity(0.1),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: horizontalSizeClass == .regular ? 40 : 30) {
                        // Header Section
                        VStack(spacing: 8) {
                            Text(viewModel.selectedPattern.name)
                                .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                                .fontWeight(.bold)
                            
                            Text(viewModel.selectedPattern.description)
                                .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                        
                        // Breathing Animation
                        ZStack {
                            // Progress ring
                            Circle()
                                .stroke(Color(.white), lineWidth: horizontalSizeClass == .regular ? 25 : 20)
                                .frame(width: horizontalSizeClass == .regular ? 350 : 250, 
                                       height: horizontalSizeClass == .regular ? 350 : 250)
                            
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(Color(viewModel.selectedPattern.color.opacity(0.5)), 
                                       style: StrokeStyle(lineWidth: horizontalSizeClass == .regular ? 25 : 20, 
                                                        lineCap: .round))
                                .frame(width: horizontalSizeClass == .regular ? 350 : 250, 
                                       height: horizontalSizeClass == .regular ? 350 : 250)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1), value: viewModel.progress)
                            
                            // Breathing circle
                            Circle()
                                .fill(Color(viewModel.selectedPattern.color).opacity(0))
                                .frame(width: horizontalSizeClass == .regular ? 300 : 200, 
                                       height: horizontalSizeClass == .regular ? 300 : 200)
                                .scaleEffect(breathingScale)
                                .animation(.easeInOut(duration: breathingDuration), value: viewModel.currentPhase)
                            
                            // Phase label
                            VStack {
                                Text(viewModel.currentPhase.rawValue)
                                    .font(horizontalSizeClass == .regular ? .title : .title2)
                                    .fontWeight(.medium)
                                
                                Text(viewModel.currentPhase.instruction)
                                    .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(timeString(from: viewModel.timeRemaining))
                                    .font(.system(size: horizontalSizeClass == .regular ? 56 : 44, 
                                                weight: .bold, 
                                                design: .rounded))
                                    .monospacedDigit()
                            }
                        }
                        
                        // Controls
                        VStack(spacing: 20) {
                            // Pattern selection button
                            Button(action: { showingPatternPicker = true }) {
                                HStack {
                                    Image(systemName: viewModel.selectedPattern.systemImage)
                                        .font(horizontalSizeClass == .regular ? .title2 : .body)
                                    Text("Change Pattern")
                                        .font(horizontalSizeClass == .regular ? .title3 : .body)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                            .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                            
                            // Duration picker
                            if !viewModel.isActive {
                                Picker("Duration", selection: $viewModel.totalDuration) {
                                    Text("1 minute").tag(60)
                                    Text("2 minutes").tag(120)
                                    Text("5 minutes").tag(300)
                                    Text("10 minutes").tag(600)
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                            }
                            
                            // Start/Pause button
                            Button(action: {
                                if viewModel.isActive {
                                    viewModel.pauseExercise()
                                } else if viewModel.timeRemaining > 0 {
                                    viewModel.resumeExercise()
                                } else {
                                    viewModel.startExercise()
                                }
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                                    Text(viewModel.isActive ? "Pause" : "Start")
                                }
                                .font(horizontalSizeClass == .regular ? .title : .title2)
                                .foregroundColor(.white)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                                .padding()
                                .background(Color(viewModel.selectedPattern.color.opacity(0.8)))
                                .cornerRadius(15)
                            }
                            
                            if viewModel.isActive {
                                Button(action: { viewModel.stopExercise() }) {
                                    Text("End Session")
                                        .font(horizontalSizeClass == .regular ? .title3 : .body)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Stats preview
                        if !viewModel.isActive {
                            let columns = horizontalSizeClass == .regular ? [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ] : [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                StatCard(
                                    title: "Sessions",
                                    value: "\(viewModel.totalSessionsCount)",
                                    icon: "number.circle.fill"
                                )
                                
                                StatCard(
                                    title: "Minutes",
                                    value: "\(viewModel.totalBreathingMinutes)",
                                    icon: "clock.fill"
                                )
                                
                                StatCard(
                                    title: "Streak",
                                    value: "\(viewModel.currentStreak) days",
                                    icon: "flame.fill"
                                )
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 800 : .infinity)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarItems(
                trailing: HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                    Button(action: { showingReminders = true }) {
                        Image(systemName: "bell.badge")
                            .font(horizontalSizeClass == .regular ? .title2 : .body)
                    }
                    
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                            .font(horizontalSizeClass == .regular ? .title2 : .body)
                    }
                }
            )
            .sheet(isPresented: $showingPatternPicker) {
                PatternPickerView(selectedPattern: $viewModel.selectedPattern)
            }
            .sheet(isPresented: $showingReminders) {
                RemindersView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                StatsView(viewModel: viewModel)
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    viewModel.pauseExercise()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var breathingScale: CGFloat {
        switch viewModel.currentPhase {
        case .inhale: return 1.2
        case .holdInhale: return 1.2
        case .exhale: return 1.0
        case .holdExhale: return 1.0
        }
    }
    
    private var breathingDuration: Double {
        switch viewModel.currentPhase {
        case .inhale: return Double(viewModel.selectedPattern.inhaleSeconds)
        case .holdInhale: return Double(viewModel.selectedPattern.holdInhaleSeconds)
        case .exhale: return Double(viewModel.selectedPattern.exhaleSeconds)
        case .holdExhale: return Double(viewModel.selectedPattern.holdExhaleSeconds)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct StatCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 12 : 8) {
            Image(systemName: icon)
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(horizontalSizeClass == .regular ? .title2 : .title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(horizontalSizeClass == .regular ? .headline : .caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PatternPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var selectedPattern: BreathingPattern
    
    var body: some View {
        NavigationView {
            List(BreathingPattern.presets) { pattern in
                Button(action: {
                    selectedPattern = pattern
                    dismiss()
                }) {
                    HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                        Image(systemName: pattern.systemImage)
                            .foregroundColor(Color(pattern.color))
                            .font(horizontalSizeClass == .regular ? .title : .title2)
                            .frame(width: horizontalSizeClass == .regular ? 60 : 44)
                        
                        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 8 : 4) {
                            Text(pattern.name)
                                .font(horizontalSizeClass == .regular ? .title3 : .headline)
                            
                            Text(pattern.description)
                                .font(horizontalSizeClass == .regular ? .body : .subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if pattern.id == selectedPattern.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(horizontalSizeClass == .regular ? .title3 : .body)
                        }
                    }
                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                }
            }
            .navigationTitle("Breathing Patterns")
            .navigationBarItems(trailing: Button("Done") { dismiss() }
                .font(horizontalSizeClass == .regular ? .title3 : .body))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var viewModel: BreathingExerciseViewModel
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.reminders) { reminder in
                        ReminderRow(reminder: reminder) { _ in
                            viewModel.toggleReminder(reminder)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteReminder(viewModel.reminders[index])
                        }
                    }
                }
                
                Section {
                    Button(action: { showingAddReminder = true }) {
                        Label("Add Reminder", systemImage: "plus.circle.fill")
                            .font(horizontalSizeClass == .regular ? .title3 : .body)
                    }
                }
            }
            .navigationTitle("Reminders")
            .navigationBarItems(trailing: Button("Done") { dismiss() }
                .font(horizontalSizeClass == .regular ? .title3 : .body))
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(viewModel: viewModel, isPresented: $showingAddReminder)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ReminderRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let reminder: BreathingReminder
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 8 : 4) {
                Text(timeString(from: reminder.time))
                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                
                Text(daysString(from: reminder.days))
                    .font(horizontalSizeClass == .regular ? .headline : .caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { onToggle($0) }
            ))
            .scaleEffect(horizontalSizeClass == .regular ? 1.2 : 1.0)
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 8 : 4)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func daysString(from days: Set<Int>) -> String {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days.sorted().map { weekdays[$0 - 1] }.joined(separator: ", ")
    }
}

struct AddReminderView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var viewModel: BreathingExerciseViewModel
    @Binding var isPresented: Bool
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<Int> = Set(1...7)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time").font(horizontalSizeClass == .regular ? .title3 : .headline)) {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .font(horizontalSizeClass == .regular ? .title3 : .body)
                }
                
                Section(header: Text("Repeat").font(horizontalSizeClass == .regular ? .title3 : .headline)) {
                    ForEach(1...7, id: \.self) { day in
                        let weekday = Calendar.current.weekdaySymbols[day - 1]
                        Toggle(weekday, isOn: Binding(
                            get: { selectedDays.contains(day) },
                            set: { isSelected in
                                if isSelected {
                                    selectedDays.insert(day)
                                } else {
                                    selectedDays.remove(day)
                                }
                            }
                        ))
                        .font(horizontalSizeClass == .regular ? .title3 : .body)
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false }
                    .font(horizontalSizeClass == .regular ? .title3 : .body),
                trailing: Button("Save") {
                    let reminder = BreathingReminder(time: selectedTime, days: selectedDays)
                    viewModel.addReminder(reminder)
                    isPresented = false
                }
                .font(horizontalSizeClass == .regular ? .title3 : .body)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var viewModel: BreathingExerciseViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Overview").font(horizontalSizeClass == .regular ? .title3 : .headline)) {
                    StatRow(title: "Total Sessions", value: String(viewModel.totalSessionsCount))
                    StatRow(title: "Total Minutes", value: String(viewModel.totalBreathingMinutes))
                    StatRow(title: "Average Duration", value: String(viewModel.averageSessionDuration / 60) + " min")
                    StatRow(title: "Current Streak", value: String(viewModel.currentStreak) + " days")
                }
                
                Section(header: Text("Recent Sessions").font(horizontalSizeClass == .regular ? .title3 : .headline)) {
                    ForEach(viewModel.sessions.prefix(10)) { session in
                        SessionRow(session: session)
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarItems(trailing: Button("Done") { dismiss() }
                .font(horizontalSizeClass == .regular ? .title3 : .body))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(horizontalSizeClass == .regular ? .title3 : .body)
            Spacer()
            Text(value)
                .font(horizontalSizeClass == .regular ? .title3 : .body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 8 : 4)
    }
}

struct SessionRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let session: BreathingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 8 : 4) {
            Text(dateString(from: session.date))
                .font(horizontalSizeClass == .regular ? .title3 : .headline)
            
            HStack {
                Text("\(session.durationSeconds / 60) minutes")
                Text("•")
                Text("\(session.completedCycles) cycles")
            }
            .font(horizontalSizeClass == .regular ? .headline : .caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 8 : 4)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    BreathingExerciseView()
}
