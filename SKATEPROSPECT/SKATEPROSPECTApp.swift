//
//  SKATEPROSPECTApp.swift
//  SKATEPROSPECT
//
//  Created by Vladislav Katashov on 20.09.2026.
//

import SwiftUI

@main
struct SKATEPROSPECTApp: App {
    @StateObject private var appearance = AppearanceSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appearance)
                .preferredColorScheme(appearance.theme.colorScheme)
        }
    }
}
