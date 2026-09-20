//
//  ContentView.swift
//  SKATEPROSPECT
//
//  Created by Vladislav Katashov on 20.09.2026.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var favorites: Set<SkateSpot.ID>

    init() {
        _favorites = State(initialValue: FavoriteStore.load())
    }

    var body: some View {
        TabView {
            SkateMapView(favorites: $favorites)
                .tabItem { Label("Карта", systemImage: "map.fill") }

            ProfileView(favorites: $favorites)
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
        .tint(.mint)
        .onChange(of: favorites) { _, newValue in
            FavoriteStore.save(newValue)
        }
    }
}

private struct SkateMapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.saintPetersburg)
    @State private var selectedSpotID: SkateSpot.ID?
    @State private var selectedCategory: SpotCategory?
    @State private var searchText = ""
    @StateObject private var locationManager = LocationManager()
    @Binding var favorites: Set<SkateSpot.ID>

    private var visibleSpots: [SkateSpot] {
        SkateSpot.samples.filter { spot in
            let matchesCategory = selectedCategory == nil || spot.category == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || spot.name.localizedCaseInsensitiveContains(query)
                || spot.address.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }

    private var selectedSpot: SkateSpot? {
        SkateSpot.samples.first { $0.id == selectedSpotID }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition, selection: $selectedSpotID) {
                UserAnnotation()

                ForEach(visibleSpots) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                        SpotMarker(
                            spot: spot,
                            isSelected: selectedSpotID == spot.id,
                            isFavorite: favorites.contains(spot.id)
                        )
                    }
                    .tag(spot.id)
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .all, showsTraffic: false))
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
            .ignoresSafeArea()

            VStack(spacing: 12) {
                header
                categoryFilters
            }
            .padding(.top, 8)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let spot = selectedSpot {
                SpotCard(
                    spot: spot,
                    isFavorite: favorites.contains(spot.id),
                    onFavorite: { toggleFavorite(spot.id) },
                    onClose: { selectedSpotID = nil }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                resultsBadge.padding(.bottom, 12)
            }
        }
        .animation(.snappy, value: selectedSpotID)
        .animation(.snappy, value: selectedCategory)
        .onAppear {
            locationManager.requestPermissionAndLocation()
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            guard oldLocation == nil, let coordinate = newLocation?.coordinate else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.24)
                    )
                )
            }
        }
        .onChange(of: visibleSpots.map(\.id)) { _, ids in
            if let selectedSpotID, !ids.contains(selectedSpotID) {
                self.selectedSpotID = nil
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text("SKATE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.65))
                Text("PROSPECT")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 4)
            Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.7))
            TextField("Найти спот", text: $searchText)
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
                .tint(.mint)
                .frame(maxWidth: 150)

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.65))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 58)
        .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 20))
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.1)) }
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.22), radius: 18, y: 8)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Все", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(SpotCategory.allCases) { category in
                    FilterChip(title: category.title, icon: category.icon, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var resultsBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: visibleSpots.isEmpty ? "exclamationmark.magnifyingglass" : "mappin.and.ellipse")
                .foregroundStyle(.mint)
            Text(visibleSpots.isEmpty ? "Споты не найдены" : "Спотов на карте: \(visibleSpots.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(.black.opacity(0.82), in: Capsule())
        .overlay { Capsule().stroke(.white.opacity(0.1)) }
    }

    private func toggleFavorite(_ id: SkateSpot.ID) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
    }
}

private enum FavoriteStore {
    private static let key = "favoriteSpotIDs"

    static func load() -> Set<UUID> {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(saved.compactMap(UUID.init(uuidString:)))
    }

    static func save(_ favorites: Set<UUID>) {
        UserDefaults.standard.set(favorites.map(\.uuidString), forKey: key)
    }
}

private struct SpotMarker: View {
    let spot: SkateSpot
    let isSelected: Bool
    let isFavorite: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.mint : Color.black.opacity(0.88))
                    .frame(width: isSelected ? 52 : 44, height: isSelected ? 52 : 44)
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .frame(width: isSelected ? 52 : 44, height: isSelected ? 52 : 44)
                Image(systemName: spot.category.icon)
                    .font(.system(size: isSelected ? 20 : 17, weight: .bold))
                    .foregroundStyle(isSelected ? .black : .white)
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.pink)
                        .padding(5)
                        .background(.white, in: Circle())
                        .offset(x: 19, y: -19)
                }
            }
            Image(systemName: "triangle.fill")
                .font(.system(size: 11))
                .foregroundStyle(isSelected ? .mint : .black.opacity(0.88))
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
        .shadow(color: .black.opacity(0.28), radius: 5, y: 3)
        .animation(.snappy, value: isSelected)
    }
}

private struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(isSelected ? Color.mint : Color.black.opacity(0.78), in: Capsule())
                .overlay { Capsule().stroke(.white.opacity(isSelected ? 0 : 0.12)) }
        }
        .buttonStyle(.plain)
    }
}

private struct SpotCard: View {
    @Environment(\.openURL) private var openURL
    let spot: SkateSpot
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(spot.category.color.gradient)
                        .frame(width: 54, height: 54)
                    Image(systemName: spot.category.icon)
                        .font(.title2.bold())
                        .foregroundStyle(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name).font(.title3.bold()).foregroundStyle(.white)
                    Label(spot.address, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white.opacity(0.65))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                StatPill(icon: "star.fill", text: String(format: "%.1f", spot.rating), color: .yellow)
                StatPill(icon: "figure.skating", text: spot.category.title, color: .mint)
                StatPill(icon: "chart.bar.fill", text: spot.difficulty, color: .orange)
            }

            Text(spot.details)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))
                .lineLimit(2)

            HStack(spacing: 10) {
                Button { openDirections() } label: {
                    Label("Маршрут", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .foregroundStyle(.black)
                        .background(.mint, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3.bold())
                        .foregroundStyle(isFavorite ? .pink : .white)
                        .frame(width: 50, height: 46)
                        .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Удалить из избранного" : "Добавить в избранное")
            }
        }
        .padding(18)
        .background(.black.opacity(0.9), in: RoundedRectangle(cornerRadius: 24))
        .overlay { RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.12)) }
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    private func openDirections() {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(spot.coordinate.latitude),\(spot.coordinate.longitude)"),
            URLQueryItem(name: "dirflg", value: "w")
        ]
        if let url = components?.url { openURL(url) }
    }
}

private struct StatPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.88))
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(color.opacity(0.14), in: Capsule())
    }
}
