//
//  XrayClassifierApp.swift
//  XrayClassifier
//
//  Created by Ioannis Pavlidis on 11/12/25.
//

import SwiftUI

// When your XrayClassifier app launches, it immediately asks the user for notification permissions, then shows ContentView as the main screen inside the main app window.
@main
struct XrayClassifierApp: App {
    init() {
        // Ask for notification permission as the app launches
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
