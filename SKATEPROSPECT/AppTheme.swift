import SwiftUI

// Все темы которые можно выбрать в настройках профиля
enum AppThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }

    // Название темы для popup меню
    var title: String {
        switch self {
        case .system: "Как на устройстве"
        case .light: "Светлая"
        case .dark: "Тёмная"
        }
    }

    // Иконка рядом с названием темы
    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }

    // Передаем выбранную тему в SwiftUI
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// Один общий контейнер темы для всего приложения
final class AppearanceSettings: ObservableObject {
    private static let storageKey = "appearance.theme"

    @Published var theme: AppThemeMode {
        didSet {
            // Сохраняем тему чтобы она не сбросилась после перезапуска
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
    // Модификатор темы для Canvas Preview
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
    // Основные цвета приложения
    static let brandBlue = Color(red: 0.08, green: 0.42, blue: 1.0)
    static let appBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
}
