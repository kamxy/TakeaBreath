import Charts
import SwiftUI

struct HomeView: View {
    @StateObject private var meditationVM = MeditationViewModel()
    @StateObject private var moodVM = MoodTrackingViewModel()
    @StateObject private var breathingVM = BreathingExerciseViewModel()
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome Back")
                            .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                            .fontWeight(.bold)
                        Text("Take a moment to pause and reflect")
                            .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Current Mood
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you feeling?")
                            .font(horizontalSizeClass == .regular ? .title2 : .headline)
                        
                        NavigationLink(destination: MoodTrackingView()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Log Your Mood")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                    
                    // Quick Actions
                    let gridColumns = horizontalSizeClass == .regular ? [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ] : [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    LazyVGrid(columns: gridColumns, spacing: 15) {
                        NavigationLink(destination: BreathingExerciseView()) {
                            QuickActionCard(title: "Breathe",
                                          systemImage: "wind",
                                          color: .blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            navigationViewModel.selectedTab = .breathe
                        } label: {
                            QuickActionCard(title: "Meditate",
                                          systemImage: "sparkles",
                                          color: .purple)
                        }
                        
                        Button {
                            navigationViewModel.selectedTab = .focus
                        } label: {
                            QuickActionCard(title: "Focus",
                                          systemImage: "timer",
                                          color: .orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Progress Overview
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Progress")
                            .font(horizontalSizeClass == .regular ? .title2 : .headline)
                            .padding(.horizontal)
                        
                        let progressGridColumns = horizontalSizeClass == .regular ? [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ] : [
                            GridItem(.flexible())
                        ]
                        
                        LazyVGrid(columns: progressGridColumns, spacing: 15) {
                            ProgressCard(
                                title: "Meditation Streak",
                                value: String(breathingVM.currentStreak) + " days",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            ProgressCard(
                                title: "Today's Session Time",
                                value: String(breathingVM.dailySessionMinutes) + " min",
                                icon: "clock.fill",
                                color: .blue
                            )
                            
                            ProgressCard(
                                title: "Mood Trend",
                                value: "↗️ Improving",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: horizontalSizeClass == .regular ? 1000 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct QuickActionCard: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationViewModel())
}
