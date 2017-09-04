import Foundation

struct Main: Codable {
    let temp: Double
    let pressure: Int
    let humidity: Int
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys : String, CodingKey {
        case temp
        case pressure
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}

struct City: Codable {
    let id: Int
    let name: String
    let coord: Coordinate
    let main: Main
    let weather: [Weather]
}
