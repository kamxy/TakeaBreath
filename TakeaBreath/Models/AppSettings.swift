import SwiftUI

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case system = "system"
    case en = "en"
    case es = "es"
    case ar = "ar"
    case hi = "hi"
    case pt = "pt"
    case ru = "ru"
    case ja = "ja"
    case tr = "tr"
    
    var displayName: String {
        switch self {
        case .system: return NSLocalizedString("System", comment: "System language option")
        case .en: return NSLocalizedString("English", comment: "English language option")
        case .es: return NSLocalizedString("Spanish", comment: "Spanish language option")
        case .ar: return NSLocalizedString("Arabic", comment: "Arabic language option")
        case .hi: return NSLocalizedString("Hindi", comment: "Hindi language option")
        case .pt: return NSLocalizedString("Portuguese", comment: "Portuguese language option")
        case .ru: return NSLocalizedString("Russian", comment: "Russian language option")
        case .ja: return NSLocalizedString("Japanese", comment: "Japanese language option")
        case .tr: return NSLocalizedString("Turkish", comment: "Turkish language option")
        }
    }
}

class AppSettingsManager: ObservableObject {
    static let shared = AppSettingsManager()
    
    @AppStorage("appTheme") private(set) var theme: AppTheme = .system
    @AppStorage("appLanguage") private(set) var language: AppLanguage = .system
    
    private init() {
        // Set initial language on app launch
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let appLanguage = AppLanguage(rawValue: savedLanguage) {
            setInitialLanguage(appLanguage)
        }
    }
    
    func setTheme(_ newTheme: AppTheme) {
        theme = newTheme
    }
    
    private func setInitialLanguage(_ language: AppLanguage) {
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
    
    func setLanguage(_ newLanguage: AppLanguage) {
        language = newLanguage
        
        // Update the app's language
        if newLanguage == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([newLanguage.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        
        // Post notification for language change
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        
        // Restart the app to apply language change
        DispatchQueue.main.async {
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                // Create a new instance of the root view controller
                let newRootViewController = UIHostingController(rootView: ContentView())
                
                // Set the new root view controller with animation
                UIView.transition(with: window,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                    window.rootViewController = newRootViewController
                }, completion: nil)
            }
        }
    }
} 