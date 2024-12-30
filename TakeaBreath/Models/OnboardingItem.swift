import Foundation
import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let backgroundColor: Color

    static let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Welcome to Take a Breath",
            description: "Your personal companion for mindfulness, meditation, and stress management.",
            systemImage: "sun.and.horizon.fill",
            backgroundColor: .purple
        ),
        OnboardingItem(
            title: "Guided Meditations",
            description: "Choose from a variety of meditation sessions designed to help you relax, focus, and find inner peace.",
            systemImage: "leaf.fill",
            backgroundColor: .blue
        ),
        OnboardingItem(
            title: "Track Your Mood",
            description: "Log your daily emotions and activities to gain insights into your emotional well-being.",
            systemImage: "heart.circle.fill",
            backgroundColor: .pink
        ),
        OnboardingItem(
            title: "Smart Break Timer",
            description: "Stay productive with our Pomodoro-style timer and get reminders to take breaks when needed.",
            systemImage: "clock.circle.fill",
            backgroundColor: .orange
        ),
        OnboardingItem(
            title: "AI-Powered Insights",
            description: "Receive personalized recommendations based on your mood patterns and meditation habits.",
            systemImage: "brain.head.profile.fill",
            backgroundColor: .green
        )
    ]
}
