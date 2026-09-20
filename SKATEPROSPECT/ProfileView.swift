import SwiftUI

struct ProfileView: View {
    @Binding var favorites: Set<SkateSpot.ID>
    @AppStorage("profile.name") private var profileName = "Vladislav Katashov"
    @AppStorage("profile.city") private var profileCity = "Санкт-Петербург"
    @AppStorage("profile.level") private var profileLevel = "Новичок"
    @AppStorage("profile.bio") private var profileBio = "хуйхуйхуйхуй"
    @AppStorage("appearance.theme") private var selectedTheme = AppThemeMode.dark.rawValue
    @State private var isEditingProfile = false
    @State private var isChoosingTheme = false

    private var favoriteSpots: [SkateSpot] {
        SkateSpot.samples.filter { favorites.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    profileHeader
                    stats
                    favoritesSection
                    settingsSection
                }
                .padding(16)
                .padding(.bottom, 16)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Профиль")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $isEditingProfile) {
                EditProfileView(
                    name: profileName,
                    city: profileCity,
                    level: profileLevel,
                    bio: profileBio
                ) { name, city, level, bio in
                    profileName = name
                    profileCity = city
                    profileLevel = level
                    profileBio = bio
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isChoosingTheme) {
                ThemeSettingsView(selection: $selectedTheme)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandBlue, Color.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 92, height: 92)
                Image(systemName: "figure.skating")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
            .overlay { Circle().stroke(.white.opacity(0.9), lineWidth: 4) }
            .shadow(color: Color.brandBlue.opacity(0.35), radius: 16, y: 8)

            Text(profileName)
                .font(.title2.bold())
            Label(profileCity, systemImage: "location.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(profileBio)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 28)

            Button {
                isEditingProfile = true
            } label: {
                Label("Редактировать профиль", systemImage: "pencil")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 42)
                    .background(Color.brandBlue, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }

    private var stats: some View {
        HStack(spacing: 0) {
            ProfileStat(value: "\(favoriteSpots.count)", title: "Избранное")
            Divider().frame(height: 44)
            ProfileStat(value: "6", title: "Спотов")
            Divider().frame(height: 44)
            ProfileStat(value: profileLevel, title: "Уровень")
        }
        .padding(.vertical, 16)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.06)) }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Избранные споты", systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(.white)

            if favoriteSpots.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Пока ничего не добавлено")
                        .font(.subheadline.weight(.semibold))
                    Text("Нажми на сердце в карточке спота на карте")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
            } else {
                ForEach(favoriteSpots) { spot in
                    HStack(spacing: 12) {
                        Image(systemName: spot.category.icon)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(spot.category.color, in: RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(spot.name).font(.subheadline.bold())
                            Text(spot.address).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            favorites.remove(spot.id)
                        } label: {
                            Image(systemName: "heart.fill").foregroundStyle(.pink)
                        }
                    }
                    .padding(12)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                isChoosingTheme = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.brandBlue, in: RoundedRectangle(cornerRadius: 8))
                    Text("Тема").font(.subheadline.weight(.medium))
                    Spacer()
                    Text(currentTheme.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Divider().padding(.leading, 52)
            ProfileRow(icon: "bell.fill", title: "Уведомления", color: Color.brandBlue)
            Divider().padding(.leading, 52)
            ProfileRow(icon: "shield.fill", title: "Приватность", color: .indigo)
            Divider().padding(.leading, 52)
            ProfileRow(icon: "questionmark.circle.fill", title: "Помощь", color: .purple)
        }
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
    }

    private var currentTheme: AppThemeMode {
        AppThemeMode(rawValue: selectedTheme) ?? .dark
    }
}

private struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                ForEach(AppThemeMode.allCases) { theme in
                    Button {
                        withAnimation(.snappy) {
                            selection = theme.rawValue
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: theme.icon)
                                .font(.title3.bold())
                                .foregroundStyle(Color.brandBlue)
                                .frame(width: 42, height: 42)
                                .background(Color.brandBlue.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                            Text(theme.title)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            if selection == theme.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.brandBlue)
                            }
                        }
                        .padding(12)
                        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selection == theme.rawValue ? Color.brandBlue : .clear, lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Тема приложения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .tint(Color.brandBlue)
    }
}

private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var city: String
    @State private var level: String
    @State private var bio: String

    private let levels = ["Новичок", "Любитель", "Продвинутый", "Про"]
    let onSave: (String, String, String, String) -> Void

    init(
        name: String,
        city: String,
        level: String,
        bio: String,
        onSave: @escaping (String, String, String, String) -> Void
    ) {
        _name = State(initialValue: name)
        _city = State(initialValue: city)
        _level = State(initialValue: level)
        _bio = State(initialValue: bio)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.brandBlue, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 88, height: 88)
                            Image(systemName: "figure.skating")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Основное") {
                    LabeledContent("Имя") {
                        TextField("Скейтбордист", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Город") {
                        TextField("Санкт-Петербург", text: $city)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Уровень", selection: $level) {
                        ForEach(levels, id: \.self) { Text($0) }
                    }
                }

                Section("О себе") {
                    TextField("Расскажи немного о своём катании", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(
                            name.trimmingCharacters(in: .whitespacesAndNewlines),
                            city.trimmingCharacters(in: .whitespacesAndNewlines),
                            level,
                            bio.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .tint(Color.brandBlue)
    }
}

private struct ProfileStat: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color, in: RoundedRectangle(cornerRadius: 8))
            Text(title).font(.subheadline.weight(.medium))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(12)
    }
}
