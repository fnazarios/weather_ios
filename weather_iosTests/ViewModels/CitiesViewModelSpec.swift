import Quick
import Nimble
@testable import WeatherApp
import RxSwift
import RxCocoa

class CitiesViewModelSpec: QuickSpec {
    private let disposeBag = DisposeBag()
    
    override func spec() {
        fdescribe("find ctities using lat lon") {
            var cities: [City]?
            let viewModel: CitiesViewModelType = CitiesViewModel()
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
    }
}

