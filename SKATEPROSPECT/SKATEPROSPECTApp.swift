//
//  SKATEPROSPECTApp.swift
//  SKATEPROSPECT
//
//  Created by Vladislav Katashov on 20.09.2026.
//

import SwiftUI

@main
struct SKATEPROSPECTApp: App {
    @AppStorage("appearance.theme") private var selectedTheme = AppThemeMode.dark.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(
                    AppThemeMode(rawValue: selectedTheme)?.colorScheme
                )
        }
    }
}
