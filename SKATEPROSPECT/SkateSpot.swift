import MapKit
import SwiftUI

//база, чтобы чекать че за споты есть

enum SpotCategory: String, CaseIterable, Identifiable {
    case skatepark, street, bowl, plaza
    var id: Self { self }
    
    // Название для категории спотов

    var title: String {
        switch self {
        case .skatepark: "Скейтпарк"
        case .street: "Стрит"
        case .bowl: "Боул"
        case .plaza: "Плаза"
        }
    }
// Иконки для категории спотов
    
    var icon: String {
        switch self {
        case .skatepark: "figure.skating"
        case .street: "stairs"
        case .bowl: "water.waves"
        case .plaza: "square.grid.3x3.fill"
        }
    }

    // Цвета для категории спотов
    var color: Color {
        switch self {
        case .skatepark: Color.brandBlue
        case .street: .orange
        case .bowl: .indigo
        case .plaza: .yellow
        }
    }
}

// Переменные для спотов

struct SkateSpot: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: SpotCategory
    let difficulty: String
    let rating: Double
    let details: String
    
    //Кооррдинаты для спотов 

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    // сам массив спотов и их локации и полная информация о них

    static let samples: [SkateSpot] = [
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000001")!, name: "Севкабель Порт", address: "Кожевенная линия, 40", latitude: 59.9246, longitude: 30.2417, category: .plaza, difficulty: "Средний", rating: 4.8, details: "Просторная набережная, ровное покрытие и городские грани. Особенно красиво на закате."),
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000002")!, name: "Брусницын", address: "Кожевенная линия, 30", latitude: 59.9259, longitude: 30.2510, category: .street, difficulty: "Средний", rating: 4.5, details: "Индустриальный стрит-спот с открытой площадкой и несколькими интересными линиями."),
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000003")!, name: "Парк 300-летия", address: "Приморский проспект, 74", latitude: 59.9830, longitude: 30.1983, category: .skatepark, difficulty: "Любой", rating: 4.7, details: "Большая зона рядом с заливом: место для спокойного катания и длинных линий."),
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000004")!, name: "Под мостом Бетанкура", address: "Набережная Макарова", latitude: 59.9547, longitude: 30.2662, category: .skatepark, difficulty: "Продвинутый", rating: 4.6, details: "Крытая городская площадка с бетонными фигурами — можно кататься даже в небольшой дождь."),
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000005")!, name: "Удельный парк", address: "Фермское шоссе, 21", latitude: 60.0132, longitude: 30.3156, category: .bowl, difficulty: "Продвинутый", rating: 4.4, details: "Зелёная локация на севере города с радиусами и пространством для тренировок."),
        SkateSpot(id: UUID(uuidString: "B61DF770-1242-4EA0-8A6A-000000000006")!, name: "Московский парк Победы", address: "Кузнецовская улица, 25", latitude: 59.8688, longitude: 30.3254, category: .street, difficulty: "Начальный", rating: 4.2, details: "Широкие дорожки и спокойные участки для разминки, круиза и первых трюков.")
    ]
}

//Тут координаты центра спб
extension MKCoordinateRegion {
    static let saintPetersburg = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.9386, longitude: 30.3141),
        span: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.28)
    )
}
