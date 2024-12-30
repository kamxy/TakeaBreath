
import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

let onboardingPages = [
    OnboardingPage(
        title: "Welcome to TakeABreak",
        description: "Your personal wellness companion for mindful breaks throughout the day",
        imageName: "sparkles"
    ),
    OnboardingPage(
        title: "Track Your Mood",
        description: "Monitor your daily emotional well-being and discover patterns",
        imageName: "heart.fill"
    ),
    OnboardingPage(
        title: "Mindful Meditation",
        description: "Take time to breathe and center yourself with guided meditation sessions",
        imageName: "brain.head.profile"
    ),
    OnboardingPage(
        title: "Smart Break Timer",
        description: "Set reminders for regular breaks to stay productive and energized",
        imageName: "timer"
    )
]