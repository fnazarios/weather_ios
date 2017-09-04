import Foundation
import RxSwift
import RxCocoa
import Action
import CoreLocation

protocol MapCitiesViewModelInputs {
    func weatherFrom(lat: Double, lon: Double, count: Int)
    func configure(withCities: [City], preferredUnit: PreferredUnit)
}

protocol MapCitiesViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var cities: Observable<[City]> { get }
    var annotations: Observable<[CityAnnotation]> { get }
}

protocol MapCitiesViewModelType {
    var inputs: MapCitiesViewModelInputs { get }
    var outputs: MapCitiesViewModelOutputs { get }
}

final class MapCitiesViewModel: MapCitiesViewModelType, MapCitiesViewModelInputs, MapCitiesViewModelOutputs {
    var inputs: MapCitiesViewModelInputs { return self }
    var outputs: MapCitiesViewModelOutputs { return self }
    
    var isLoading: Driver<Bool>
    var cities: Observable<[City]>
    var annotations: Observable<[CityAnnotation]>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let searchAct = Action<SearchParams, Search> { (params) -> Observable<Search> in
            return Search.with(latitude: params.lat, longitude: params.lon, numberOfCities: params.count)
        }
        
        isLoading = searchAct.executing
            .asDriver(onErrorJustReturn: false)
        
        cities = searchAct.elements
            .map { $0.list }
        
        let preferredUnit = configureWithCities.map { $0.unit }
        
        annotations = configureWithCities.map { $0.cities }
            .withLatestFrom(preferredUnit, resultSelector: { (cities, preferUnit) -> [CityAnnotation] in
                return cities.map({ (city) -> CityAnnotation in
                    return CityAnnotation(
                        temperature: "\(city.main.temp.toPreferedUnit(preferUnit))º",
                        contition: city.weather.first?.description ?? "",
                        contidionImageUrl: URL(string: "\(EnviromentUtil.baseUrlIcon)/\(city.weather.first?.icon ?? "").png"),
                        coordinate: CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
                    )
                })
            })
        
        weatherFromProperty
            .bind(to: searchAct.inputs)
            .addDisposableTo(disposeBag)
    }
    
    typealias SearchParams = (lat: Double, lon: Double, count: Int)
    private let weatherFromProperty = PublishSubject<SearchParams>()
    func weatherFrom(lat: Double, lon: Double, count: Int) {
        weatherFromProperty.onNext((lat: lat, lon: lon, count: count))
    }
    
    private let configureWithCities = PublishSubject<(cities: [City], unit: PreferredUnit)>()
    func configure(withCities cities: [City], preferredUnit: PreferredUnit) {
        configureWithCities.onNext((cities: cities, unit: preferredUnit))
    }
}
