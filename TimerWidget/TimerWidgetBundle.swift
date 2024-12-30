//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Mehmet Kamay on 27.12.2024.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
        TimerWidgetControl()
        TimerWidgetLiveActivity()
    }
}
