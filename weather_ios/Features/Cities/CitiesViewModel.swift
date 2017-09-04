import Foundation
import RxSwift
import RxCocoa

protocol CitiesViewModelInputs {
    func weatherFrom(lat: Double, lon: Double, count: Int)
}

protocol CitiesViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var cities: Observable<[City]> { get }
}

protocol CitiesViewModelType {
    var inputs: CitiesViewModelInputs { get }
    var outputs: CitiesViewModelOutputs { get }
}

final class CitiesViewModel: CitiesViewModelType, CitiesViewModelInputs, CitiesViewModelOutputs {
    var inputs: CitiesViewModelInputs { return self }
    var outputs: CitiesViewModelOutputs { return self }
    
    var isLoading: Driver<Bool>
    var cities: Observable<[City]>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let searchAct = Action<SearchParams, Search> { (params) -> Observable<Search> in
            return Search.with(latitude: params.lat, longitude: params.lon, numberOfCities: params.count)
        }
        
        isLoading = searchAct.executing
            .asDriver(onErrorJustReturn: false)
        
        cities = searchAct.elements
            .map { $0.list }
        
        weatherFromProperty
            .bind(to: searchAct.inputs)
            .addDisposableTo(disposeBag)
    }
    
    typealias SearchParams = (lat: Double, lon: Double, count: Int)
    private let weatherFromProperty = PublishSubject<SearchParams>()
    func weatherFrom(lat: Double, lon: Double, count: Int) {
        weatherFromProperty.onNext((lat: lat, lon: lon, count: count))
    }
}
