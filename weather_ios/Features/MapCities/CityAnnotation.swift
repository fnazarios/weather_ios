import UIKit
import MapKit

class CityAnnotation: NSObject, MKAnnotation {
    var temperature: String
    let contition: String
    let contidionImageUrl: URL?
    let coordinate: CLLocationCoordinate2D
    
    init(temperature: String, contition: String, contidionImageUrl: URL?, coordinate: CLLocationCoordinate2D) {
        self.temperature = temperature
        self.contition = contition
        self.contidionImageUrl = contidionImageUrl
        self.coordinate = coordinate
        
        super.init()
    }
    
    var title: String? {
        return temperature
    }
    
    var subtitle: String? {
        return nil
    }
}
