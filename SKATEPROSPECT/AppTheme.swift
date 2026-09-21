import SwiftUI

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "Как на устройстве"
        case .light: "Светлая"
        case .dark: "Тёмная"
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

final class AppearanceSettings: ObservableObject {
    private static let storageKey = "appearance.theme"

    @Published var theme: AppThemeMode {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: Self.storageKey)
        }
    }

    init(theme previewTheme: AppThemeMode? = nil) {
        if let previewTheme {
            theme = previewTheme
        } else {
            let savedValue = UserDefaults.standard.string(forKey: Self.storageKey)
            theme = AppThemeMode(rawValue: savedValue ?? "") ?? .dark
        }
    }
}

extension View {
    @ViewBuilder
    func appTheme(_ theme: AppThemeMode) -> some View {
        switch theme {
        case .system:
            self
        case .light:
            preferredColorScheme(.light)
        case .dark:
            preferredColorScheme(.dark)
        }
    }
}

extension Color {
    static let brandBlue = Color(red: 0.08, green: 0.42, blue: 1.0)
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
}
