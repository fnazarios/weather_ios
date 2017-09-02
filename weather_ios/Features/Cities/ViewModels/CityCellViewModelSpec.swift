import Quick
import Nimble
@testable import WeatherApp
import RxSwift
import RxCocoa

class CityCellViewModelSpec: QuickSpec {
    private let disposeBag = DisposeBag()
    
    override func spec() {
        fdescribe("show city weather") {
            
            fdescribe("in celsius") {
                let main = Main(temp: 291.23, pressure: 1029, humidity: 23, tempMin: 289.15, tempMax: 295.15)
                let weather = Weather(id: 1, main: "Ensolarado", description: "Ensolarado", icon: "04d")
                let city = City(id: 100, name: "Krakovia", main: main, weather: [weather])
                
                let viewModel: CityCellViewModelType = CityCellViewModel()
                var cityName: String?
                var temp: String?
                var conditions: String?
                var icon: URL?
                
                beforeSuite {
                    viewModel.outputs.cityName.bind(onNext: { (value) in cityName = value }).addDisposableTo(self.disposeBag)
                    viewModel.outputs.temperature.bind(onNext: { (value) in temp = value }).addDisposableTo(self.disposeBag)
                    viewModel.outputs.conditions.bind(onNext: { (value) in conditions = value }).addDisposableTo(self.disposeBag)
                    viewModel.outputs.conditionsIcon.bind(onNext: { (value) in icon = value }).addDisposableTo(self.disposeBag)
                    viewModel.inputs.configure(with: city, preferredUnit: PreferredUnit.celsius)
                }
                
                fit("cityName should be eq Krakovia") {
                    expect(cityName).toEventually(equal("Krakovia"), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("temp should be eq 12") {
                    expect(temp).toEventually(equal("19º"), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("conditions should be eq Ensolarado") {
                    expect(conditions).toEventually(equal("Ensolarado"), timeout: 5.0, pollInterval: 0.2)
                }
                
                fit("icon url should be eq http://openweathermap.org/img/w/04d.png") {
                    expect(icon?.absoluteString).toEventually(equal("http://openweathermap.org/img/w/04d.png"), timeout: 5.0, pollInterval: 0.2)
                }
            }
            
            fdescribe("in fahrenheit") {
                let main = Main(temp: 291.23, pressure: 1029, humidity: 23, tempMin: 289.15, tempMax: 295.15)
                let weather = Weather(id: 1, main: "Ensolarado", description: "Ensolarado", icon: "04d")
                let city = City(id: 100, name: "Krakovia", main: main, weather: [weather])
                
                let viewModel: CityCellViewModelType = CityCellViewModel()
                var temp: String?
                
                beforeSuite {
                    viewModel.outputs.temperature.bind(onNext: { (value) in temp = value }).addDisposableTo(self.disposeBag)
                    viewModel.inputs.configure(with: city, preferredUnit: PreferredUnit.fahrenheit)
                }

                fit("temp should be eq 12") {
                    expect(temp).toEventually(equal("65º"), timeout: 5.0, pollInterval: 0.2)
                }
            }
        }
    }
}


