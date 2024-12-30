//
//  TakeABreakApp.swift
//  TakeABreak
//
//  Created by Mehmet Kamay on 25.12.2024.
//

import BackgroundTasks
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.kamay.TakeaBreath.timer", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Schedule the next background task
        scheduleAppRefresh()
        
        task.setTaskCompleted(success: true)
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.kamay.TakeaBreath.timer")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}

@main
struct TakeaBreathApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsManager = AppSettingsManager.shared
    @State private var refreshFlag = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(refreshFlag)
                .preferredColorScheme(settingsManager.theme.colorScheme)
                .environment(\.layoutDirection, settingsManager.language == .ar ? .rightToLeft : .leftToRight)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                    // Force view refresh when language changes
                    UserDefaults.standard.synchronize()
                    refreshFlag.toggle()
                }
                .environmentObject(settingsManager)
        }
    }
}
