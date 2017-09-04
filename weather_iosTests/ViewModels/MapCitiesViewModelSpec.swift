import Quick
import Nimble
@testable import WeatherApp
import RxSwift
import RxCocoa

class MapCitiesViewModelSpec: QuickSpec {
    private let disposeBag = DisposeBag()
    
    override func spec() {
        
        fdescribe("find ctities using lat lon") {
            fcontext("list cities") {
                var cities: [City]?
                let viewModel: MapCitiesViewModelType = MapCitiesViewModel()
                beforeSuite {
                    viewModel.outputs.cities.bind(onNext: { (value) in cities = value }).addDisposableTo(self.disposeBag)
                    viewModel.inputs.weatherFrom(lat: -23.473579521, lon: -46.545648649, count: 50)
                }
                
                fit("cities should not be nil") {
                    expect(cities).toEventuallyNot(beNil(), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("cities count should be eq 50") {
                    expect(cities?.count).toEventually(equal(50), timeout: 5.0, pollInterval: 0.2)
                }
            }
            
            fcontext("list annotations in celsius") {
                var annotations: [CityAnnotation]?
                let viewModel: MapCitiesViewModelType = MapCitiesViewModel()
                beforeSuite {
                    viewModel.outputs.annotations.bind(onNext: { (value) in annotations = value }).addDisposableTo(self.disposeBag)
                    
                    let main = Main(temp: 291.23, pressure: 1029, humidity: 23, tempMin: 289.15, tempMax: 295.15)
                    let weather = Weather(id: 1, main: "Ensolarado", description: "Ensolarado", icon: "04d")
                    let coord = Coordinate(lat: 0.0, lon: 0.0)
                    let city = City(id: 100, name: "Krakovia", coord: coord, main: main, weather: [weather])
                    viewModel.inputs.configure(withCities: [city], preferredUnit: .celsius)
                }
                
                fit("cities should not be nil") {
                    expect(annotations).toEventuallyNot(beNil(), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("cities count should be eq 50") {
                    expect(annotations?.count).toEventually(equal(1), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("first annotation title should be eq ") {
                    expect(annotations?.first?.title).toEventually(equal("19º"), timeout: 5.0, pollInterval: 0.2)
                }
            }
            
            fcontext("list annotations in fahrenheit") {
                var annotations: [CityAnnotation]?
                let viewModel: MapCitiesViewModelType = MapCitiesViewModel()
                beforeSuite {
                    viewModel.outputs.annotations.bind(onNext: { (value) in annotations = value }).addDisposableTo(self.disposeBag)
                    
                    let main = Main(temp: 291.23, pressure: 1029, humidity: 23, tempMin: 289.15, tempMax: 295.15)
                    let weather = Weather(id: 1, main: "Ensolarado", description: "Ensolarado", icon: "04d")
                    let coord = Coordinate(lat: 0.0, lon: 0.0)
                    let city = City(id: 100, name: "Krakovia", coord: coord, main: main, weather: [weather])
                    viewModel.inputs.configure(withCities: [city], preferredUnit: .fahrenheit)
                }
                
                fit("cities should not be nil") {
                    expect(annotations).toEventuallyNot(beNil(), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("cities count should be eq 50") {
                    expect(annotations?.count).toEventually(equal(1), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("first annotation title should be eq ") {
                    expect(annotations?.first?.title).toEventually(equal("65º"), timeout: 5.0, pollInterval: 0.2)
                }
            }
        }
    }
}

