//
//  NotesApp.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

import SwiftUI

// Marks this as the app’s entry point. When the watch app launches, SwiftUI instantiates this type first.
@main

//Your root type conforms to App, which defines the SwiftUI app lifecycle (no AppDelegate needed).
struct Notes_Watch_AppApp: App {
    
    // An app provides one or more “scenes.” On watchOS you typically have a single main scene.
    var body: some Scene {
        
        // Creates the app’s main UI window. On watchOS this is just one window that hosts your entire interface.
        WindowGroup {
            
            // Provides a navigation container for push-style navigation between views (the modern replacement for NavigationView). It manages a stack of destinations so you can NavigationLink to other screens.
            NavigationStack {
                
                // The first view shown inside the navigation stack—i.e., your home screen for the Notes app.
                ContentView()
            }
        }
    }
}


// Scene is a unit of UI the OS can show, hide, create, or destroy. Each scene has its own lifecycle (active/inactive/background), environment, and state.  Scenes expose lifecycle via @Environment(\.scenePhase) so you can react when the UI becomes active, goes inactive, etc. There are many scene types: WindowGroup, DocumentGroup,etc

// WindowGroup is the container (a special type of scene). ContentView is the content.
