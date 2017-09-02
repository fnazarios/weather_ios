import Foundation
import RxSwift
import Moya

struct Search: Codable {
    let message: String
    let cod: String
    let count: Int
    let list: [City]
    
    private static var provider = RxMoyaProvider<OpenWeatherApi>(endpointClosure: endpointsClosure())
    
    static func with(latitude: Double, longitude: Double, numberOfCities: Int) -> Observable<Search> {
        return provider.request(.find(lat: latitude, lon: longitude, numberOfCities: numberOfCities))
            .successfulStatusCodes()
            .mapToDomain()
    }
}
