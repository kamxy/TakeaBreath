import SwiftUI

class NavigationViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showOnboarding: Bool = true
    
    init() {
        // Check if onboarding has been shown before
        showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        showOnboarding = false
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
} 