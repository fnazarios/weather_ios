import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    typealias CompletionHandler = (CLLocationCoordinate2D?) -> Void
    typealias CompletionAuthorizationHandler = (Bool) -> Void

    private var executing = PublishSubject<Bool>()
    
    private let locationManager = CLLocationManager()
    private var completionHandler: CompletionHandler?
    private var completionAuthorizationHandler: CompletionAuthorizationHandler?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func authorization(completion: CompletionAuthorizationHandler? = nil) {
        completionAuthorizationHandler = completion
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            completionAuthorizationHandler?(true)
        default:
            break
        }
    }
    
    func last(completion: CompletionHandler? = nil) {
        completionHandler = completion
        
        locationManager.requestLocation()
    }
    
    var isExecuting: Observable<Bool> {
        return executing.asObservable()
    }
    
    var last: Observable<CLLocationCoordinate2D> {
        return Observable.create({ [weak self] (observer) -> Disposable in
            self?.executing.onNext(true)
            
            LocationManager.shared.last(completion: { (coordinate) in
                observer.onNext(coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
                observer.onCompleted()
                self?.executing.onNext(false)
            })
            
            return Disposables.create()
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            completionAuthorizationHandler?(true)
        default:
            completionAuthorizationHandler?(false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completionHandler?(locations.first?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] didFailWithError error: \(error)")
    }
}
