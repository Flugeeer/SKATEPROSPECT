import SwiftUI

struct ProfileView: View {
    @Binding var favorites: Set<SkateSpot.ID>

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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Профиль")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.mint, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 92, height: 92)
                Image(systemName: "figure.skating")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.black)
            }
            .overlay { Circle().stroke(.white, lineWidth: 4) }
            .shadow(color: .mint.opacity(0.25), radius: 14, y: 8)

            Text("Скейтбордист")
                .font(.title2.bold())
            Label("Санкт-Петербург", systemImage: "location.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Редактировать профиль") { }
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
                .padding(.horizontal, 18)
                .frame(height: 40)
                .background(.mint, in: Capsule())
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
            ProfileStat(value: "Новичок", title: "Уровень")
        }
        .padding(.vertical, 16)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Избранные споты", systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(.primary)

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
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
            } else {
                ForEach(favoriteSpots) { spot in
                    HStack(spacing: 12) {
                        Image(systemName: spot.category.icon)
                            .font(.title3.bold())
                            .foregroundStyle(.black)
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
                    .background(.background, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ProfileRow(icon: "bell.fill", title: "Уведомления", color: .orange)
            Divider().padding(.leading, 52)
            ProfileRow(icon: "shield.fill", title: "Приватность", color: .blue)
            Divider().padding(.leading, 52)
            ProfileRow(icon: "questionmark.circle.fill", title: "Помощь", color: .purple)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
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
