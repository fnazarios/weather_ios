import Foundation
import RxSwift
import RxCocoa

protocol CityCellViewModelInputs {
    func configure(with: City, preferredUnit: PreferredUnit)
}

protocol CityCellViewModelOutputs {
    var cityName: Observable<String> { get }
    var temperature: Observable<String> { get }
    var conditions: Observable<String> { get }
    var conditionsIcon: Observable<URL> { get }
    var min: Observable<String> { get }
    var max: Observable<String> { get }
}

protocol CityCellViewModelType {
    var inputs: CityCellViewModelInputs { get }
    var outputs: CityCellViewModelOutputs { get }
}

final class CityCellViewModel: CityCellViewModelType, CityCellViewModelInputs, CityCellViewModelOutputs {
    var inputs: CityCellViewModelInputs { return self }
    var outputs: CityCellViewModelOutputs { return self }
    
    var cityName: Observable<String>
    var temperature: Observable<String>
    var conditions: Observable<String>
    var conditionsIcon: Observable<URL>
    var min: Observable<String>
    var max: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let city = configureWithCityProperty.asObservable()
            .map { $0.city }
        
        let preferredUnit = configureWithCityProperty.asObservable()
            .map { $0.unit }
        
        cityName = city
            .map { $0.name }
        
        temperature = city
            .map { $0.main.temp }
            .withLatestFrom(preferredUnit, resultSelector: { (temp, preferUnit) -> String in
                return temp.toPreferedUnit(preferUnit)
            })
            .map { "\($0)º" }
        
        let weather = city
            .map { $0.weather.first }
            .ignoreNil()
        
        conditions = weather
            .map { $0.description }
        
        conditionsIcon = weather
            .map { $0.icon }
            .map { URL(string: "\(EnviromentUtil.baseUrlIcon)/\($0).png") }
            .ignoreNil()
        
        min = city
            .map { $0.main.tempMin }
            .withLatestFrom(preferredUnit, resultSelector: { (temp, preferUnit) -> String in
                return temp.toPreferedUnit(preferUnit)
            })
            .map { "Min.: \($0)" }
        
        max = city
            .map { $0.main.tempMax }
            .withLatestFrom(preferredUnit, resultSelector: { (temp, preferUnit) -> String in
                return temp.toPreferedUnit(preferUnit)
            })
            .map { "Max.: \($0)" }
    }
    
    private let configureWithCityProperty = PublishSubject<(city: City, unit: PreferredUnit)>()
    func configure(with city: City, preferredUnit: PreferredUnit) {
        configureWithCityProperty.onNext((city: city, unit: preferredUnit))
    }
}
