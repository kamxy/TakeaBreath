import SwiftUI

struct ProfileView: View {
    @AppStorage("username") private var username: String = "User"
    @AppStorage("dailyMeditationGoal") private var dailyMeditationGoal: Int = 10
    @StateObject private var settingsManager = AppSettingsManager.shared
    @State private var showingEditProfile = false
    @State private var showingSubscription = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Free Plan")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                // Statistics
                Section("Your Progress") {
                    StatisticRow(title: "Meditation Minutes", value: "120", icon: "clock.fill")
                    StatisticRow(title: "Sessions Completed", value: "8", icon: "checkmark.circle.fill")
                    StatisticRow(title: "Current Streak", value: "3 days", icon: "flame.fill")
                }
                
                // Goals
                Section("Daily Goals") {
                    HStack {
                        Text("Meditation Time")
                        Spacer()
                        Text("\(dailyMeditationGoal) min")
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: 0.6)
                        .tint(.purple)
                }
                
                // Appearance & Language
                Section(NSLocalizedString("Appearance", comment: "Appearance settings section")) {
                    Picker(NSLocalizedString("Dark Mode", comment: "Dark mode setting"), selection: Binding(
                        get: { settingsManager.theme },
                        set: { settingsManager.setTheme($0) }
                    )) {
                        Text(NSLocalizedString("System", comment: "System theme option"))
                            .tag(AppTheme.system)
                        Text(NSLocalizedString("Light", comment: "Light theme option"))
                            .tag(AppTheme.light)
                        Text(NSLocalizedString("Dark", comment: "Dark theme option"))
                            .tag(AppTheme.dark)
                    }
                    
                    Picker(NSLocalizedString("Language", comment: "Language setting"), selection: Binding(
                        get: { settingsManager.language },
                        set: { settingsManager.setLanguage($0) }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                }
                
                // Settings
                Section("Settings") {
                    Button(action: { showingEditProfile = true }) {
                        SettingsRow(title: "Edit Profile", icon: "person.fill")
                    }
                    
                    Button(action: { showingSubscription = true }) {
                        SettingsRow(title: "Subscription", icon: "star.fill")
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingsRow(title: "Notifications", icon: "bell.fill")
                    }
                    
                    NavigationLink(destination: AppSettingsView()) {
                        SettingsRow(title: "App Settings", icon: "gear")
                    }
                }
                
                // About
                Section {
                    Link(destination: URL(string: "https://firebasestorage.googleapis.com/v0/b/kamay-quote-app.appspot.com/o/policies%2Fkamay_inc_privacy.html?alt=media&token=e9d109ff-11da-44b7-ae6a-e736efded042")!) {
                        Text("Privacy Policy")
                    }
                    
                    Link(destination: URL(string: "https://firebasestorage.googleapis.com/v0/b/kamay-quote-app.appspot.com/o/policies%2Fkamay_inc_privacy.html?alt=media&token=e9d109ff-11da-44b7-ae6a-e736efded042")!) {
                        Text("Terms of Service")
                    }
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(username: $username)
            }
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView()
            }
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(title)
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var username: String
    @State private var newUsername: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Username", text: $newUsername)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    username = newUsername
                    dismiss()
                }
            )
            .onAppear {
                newUsername = username
            }
        }
    }
}

struct NotificationSettingsView: View {
    @AppStorage("meditationReminders") private var meditationReminders = true
    @AppStorage("breakReminders") private var breakReminders = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Meditation Reminders", isOn: $meditationReminders)
                Toggle("Break Reminders", isOn: $breakReminders)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct AppSettingsView: View {
    @AppStorage("playBackgroundSounds") private var playBackgroundSounds = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Background Sounds", isOn: $playBackgroundSounds)
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
            }
        }
        .navigationTitle("App Settings")
    }
}

struct SubscriptionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Upgrade to Premium")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Unlock all features and meditations")
                    .foregroundColor(.secondary)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(title: "Unlimited Meditations", description: "Access our entire library")
                    FeatureRow(title: "Offline Access", description: "Download for offline use")
                    FeatureRow(title: "Custom Sessions", description: "Create your own meditation plans")
                    FeatureRow(title: "Advanced Statistics", description: "Detailed progress tracking")
                }
                .padding()
                
                // Pricing
                VStack(spacing: 8) {
                    Text("$9.99 / month")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("or $99.99 / year")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Subscribe Button
                Button(action: {
                    // Handle subscription
                }) {
                    Text("Subscribe Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ProfileView()
}
