import SwiftUI

struct OnboardingView: View {
    @ObservedObject var navigationViewModel: NavigationViewModel
    @State private var selectedPage = 0
    @State private var showNameInput = false
    @AppStorage("username") private var username: String = "User"
    @State private var inputUsername: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(OnboardingItem.items[selectedPage].backgroundColor).opacity(0.3),
                    Color(OnboardingItem.items[selectedPage].backgroundColor).opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Control dots
                HStack(spacing: 8) {
                    ForEach(0 ..< OnboardingItem.items.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedPage ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == selectedPage ? 1.2 : 1.0)
                            .animation(.spring(), value: selectedPage)
                    }
                }
                .padding(.top, 20)
                
                // Page View
                TabView(selection: $selectedPage) {
                    ForEach(Array(OnboardingItem.items.enumerated()), id: \.element.id) { index, item in
                        OnboardingPageView(item: item)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedPage)
                
                // Navigation buttons
                VStack(spacing: 16) {
                    if selectedPage == OnboardingItem.items.count - 1 {
                        Button(action: {
                            showNameInput = true
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                
                        }.background(Color(.white)).cornerRadius(12).shadow(radius: 8)
                    } else {
                        Button(action: {
                            withAnimation {
                                selectedPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                               
                        }.background(Color(.white)).cornerRadius(12).shadow(radius: 8)
                    }
                    
                    if selectedPage < OnboardingItem.items.count - 1 {
                        Button(action: {
                            navigationViewModel.completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showNameInput) {
            NameInputView(username: $inputUsername) {
                username = inputUsername.isEmpty ? "User" : inputUsername
                navigationViewModel.completeOnboarding()
            }
        }
    }
}

struct OnboardingPageView: View {
    let item: OnboardingItem
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: item.systemImage)
                .font(.system(size: 80))
                .foregroundColor(Color(item.backgroundColor))
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showContent)
            
            VStack(spacing: 16) {
                // Title
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
                
                // Description
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            showContent = true
        }
        .onDisappear {
            showContent = false
        }
    }
}

struct NameInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var username: String
    let onComplete: () -> Void
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .padding(.top, 40)
                
                Text("What should we call you?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("We'll use this to personalize your experience.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                TextField("Your name", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 24)
                    .focused($isInputFocused)
                
                Spacer()
                
                Button(action: {
                    onComplete()
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarItems(
                trailing: Button("Skip") {
                    onComplete()
                    dismiss()
                }
            )
        }
        .onAppear {
            isInputFocused = true
        }
    }
}

#Preview {
    OnboardingView(navigationViewModel: NavigationViewModel())
}
