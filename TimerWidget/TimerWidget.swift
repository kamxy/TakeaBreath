//
//  TimerWidget.swift
//  TimerWidget
//
//  Created by Mehmet Kamay on 27.12.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = TimerEntry
    
    let defaults = UserDefaults(suiteName: "group.com.kamay.TakeaBreath")
    
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), timeRemaining: 0, isRunning: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        let entry = TimerEntry(
            date: Date(),
            timeRemaining: defaults?.double(forKey: "timeRemaining") ?? 0,
            isRunning: defaults?.bool(forKey: "isRunning") ?? false
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> ()) {
        let currentDate = Date()
        let timeRemaining = defaults?.double(forKey: "timeRemaining") ?? 0
        let isRunning = defaults?.bool(forKey: "isRunning") ?? false
        
        let entry = TimerEntry(
            date: currentDate,
            timeRemaining: timeRemaining,
            isRunning: isRunning
        )
        
        // Update every second if timer is running, otherwise every minute
        let updateInterval = isRunning ? 1.0 : 60.0
        let nextUpdate = Date().addingTimeInterval(updateInterval)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TimerEntry: TimelineEntry {
    let date: Date
    let timeRemaining: TimeInterval
    let isRunning: Bool
}

struct TimerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: entry.isRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    
                    Text(formatTime(entry.timeRemaining))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.orange)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d,%02d", minutes, seconds, milliseconds)
    }
}

struct TimerWidget: Widget {
    private let kind: String = "TimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("Timer", comment: "Widget display name"))
        .description(NSLocalizedString("Shows the current timer status.", comment: "Widget description"))
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview("Timer Widget") {
    TimerWidgetEntryView(entry: TimerEntry(
        date: Date(),
        timeRemaining: 125.45,
        isRunning: true
    ))
    .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
}
