import Quick
import Nimble
@testable import WeatherApp
import RxSwift

class SearchSpec: QuickSpec {
    private let disposeBag = DisposeBag()
    
    override func spec() {
        fdescribe("find ctities using lat lon") {
            var cities: [City]?
            var firstCity: City?
            
            beforeSuite {
                Search.with(latitude: -23.473579521, longitude: -46.545648649, numberOfCities: 50)
                    .subscribe(onNext: { (result) in
                        cities = result.list
                        firstCity = result.list.first
                    })
                    .addDisposableTo(self.disposeBag)
            }
            
            
            fit("cities should not be nil") {
                expect(cities).toEventuallyNot(beNil(), timeout: 5.0, pollInterval: 0.2)
            }
            
            fit("cities count should be eq 50") {
                expect(cities?.count).toEventually(equal(50), timeout: 5.0, pollInterval: 0.2)
            }
            
            fit("first city name should be eq Vila Gopouva") {
                expect(firstCity?.name).toEventually(equal("Vila Gopoúva"), timeout: 5.0, pollInterval: 0.2)
            }
        }
    }
}
