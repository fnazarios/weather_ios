import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    typealias CompletionHandler = (CLLocationCoordinate2D?) -> Void
    typealias CompletionAuthorizationHandler = (Bool) -> Void

    private let locationManager = CLLocationManager()
    private var completionHandler: CompletionHandler?
    private var completionAuthorizationHandler: CompletionAuthorizationHandler?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func authorization(completion: CompletionAuthorizationHandler? = nil) {
        completionAuthorizationHandler = completion
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            completionAuthorizationHandler?(true)
        }
    }
    
    func last(completion: CompletionHandler? = nil) {
        completionHandler = completion
        
        locationManager.requestLocation()
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
