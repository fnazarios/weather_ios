import Foundation
import RxSwift
import RxCocoa
import MapKit

extension Reactive where Base: MKMapView {
    var showAnnotations: UIBindingObserver<Base, [MKAnnotation]> {
        return UIBindingObserver(UIElement: self.base, binding: { (map, annotations) in
            map.addAnnotations(annotations)
        })
    }
}
