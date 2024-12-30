//
//  ContentView.swift
//  TakeABreak
//
//  Created by Mehmet Kamay on 25.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationViewModel = NavigationViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if navigationViewModel.showOnboarding {
                OnboardingView(navigationViewModel: navigationViewModel)
            } else {
                if horizontalSizeClass == .regular {
                    // iPad Layout
                    NavigationView {
                        TabView(selection: $navigationViewModel.selectedTab) {
                            HomeView()
                                .tabItem {
                                    Label("Home", systemImage: "house.fill")
                                }
                                .tag(Tab.home)
                                .environmentObject(navigationViewModel)

                            BreathingExerciseView()
                                .tabItem {
                                    Label("Breathe", systemImage: "wind")
                                }
                                .tag(Tab.breathe)

                            BreakTimerView()
                                .tabItem {
                                    Label("Focus", systemImage: "timer")
                                }
                                .tag(Tab.focus)

                            ProfileView()
                                .tabItem {
                                    Label("Profile", systemImage: "person.fill")
                                }
                                .tag(Tab.profile)
                        }
                        .frame(maxWidth: 800)  // Limit width for better readability
                        .padding(.horizontal)   // Add horizontal padding
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    // iPhone Layout
                    TabView(selection: $navigationViewModel.selectedTab) {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                            .tag(Tab.home)
                            .environmentObject(navigationViewModel)

                        BreathingExerciseView()
                            .tabItem {
                                Label("Breathe", systemImage: "wind")
                            }
                            .tag(Tab.breathe)

                        BreakTimerView()
                            .tabItem {
                                Label("Focus", systemImage: "timer")
                            }
                            .tag(Tab.focus)

                        ProfileView()
                            .tabItem {
                                Label("Profile", systemImage: "person.fill")
                            }
                            .tag(Tab.profile)
                    }
                }
            }
        }
        .animation(.easeInOut, value: navigationViewModel.showOnboarding)
        .tint(.indigo)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
