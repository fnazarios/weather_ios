import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    typealias CompletionHandler = (CLLocationCoordinate2D?) -> Void

    private var executing = PublishSubject<Bool>()
    private var authorizationStatus = PublishSubject<CLAuthorizationStatus>()
    
    private let locationManager = CLLocationManager()
    private var completionHandler: CompletionHandler?
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    private func last(completion: CompletionHandler? = nil) {
        completionHandler = completion
        
        locationManager.requestLocation()
    }
    
    // MARK: Public
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
    
    var notAuthorizedMessage: Observable<String> {
        return isAuthorized
            .map { $0 != true ? "We need to access your location data. Please, go to Settings and Privacy and turn it on" : nil }
            .ignoreNil()
    }
    
    var isAuthorized: Observable<Bool> {
        return authorizationStatus.asObservable()
            .map { status -> Bool? in
                switch status {
                case .notDetermined:
                    return nil
                case .authorizedAlways, .authorizedWhenInUse:
                    return true
                case .denied, .restricted:
                    return false
                }
            }
            .ignoreNil()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus.onNext(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completionHandler?(locations.first?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationManager] didFailWithError error: \(error)")
    }
}
