import UIKit
import MapKit
import RxSwift
import RxCocoa
import Nuke
import RxNuke

class MapCitiesViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private let loadingView = Loading()
    private let bannerMessage = Banner()
    
    private let viewModel: MapCitiesViewModelType = MapCitiesViewModel()
    private let disposeBag = DisposeBag()
    
    private var currentUnit: PreferredUnit = .celsius
    private var currentCities = Variable<[City]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        NotificationCenter.default.addObserver(forName: preferredUnitChanged, object: nil, queue: nil) { [weak self] (notification) in
            guard let unit = notification.object as? PreferredUnit else { return }
            
            self?.currentUnit = unit
            self?.viewModel.inputs.configure(withCities: self?.currentCities.value ?? [], preferredUnit: self?.currentUnit ?? .celsius)
        }
        
        startRefreshing()
    }
    
    func bindViewModel() {
        viewModel.outputs.isLoading
            .drive(loadingView.rx.isShow)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.cities
            .subscribe(onNext: { [weak self] (cities) in
                self?.viewModel.inputs.configure(withCities: cities, preferredUnit: self?.currentUnit ?? .celsius)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.cities
            .bind(to: currentCities)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.annotations
            .subscribe(onNext: { [weak self] (annotations) in
                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                self?.mapView.addAnnotations(annotations)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self?.zoomToFitMapAnnotations()
                })
            })
            .addDisposableTo(disposeBag)
    }
    
    func startRefreshing() {
        LocationManager.shared.last
            .bind { [weak self] (coordinate) in
                self?.viewModel.inputs.weatherFrom(lat: coordinate.latitude, lon: coordinate.longitude, count: 50)
            }
            .addDisposableTo(disposeBag)
    }
    
    func startRefreshing(withCoordinate coordinate: CLLocationCoordinate2D) {
        viewModel.inputs.weatherFrom(lat: coordinate.latitude, lon: coordinate.longitude, count: 50)
    }
}

extension MapCitiesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard animated == false else { return }
        
        startRefreshing(withCoordinate: mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView? = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        
        if let cityAnnotation = annotationView?.annotation as? CityAnnotation {
            let leftView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            annotationView?.leftCalloutAccessoryView = leftView
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "pin")
            
            if let url = cityAnnotation.contidionImageUrl {
                Nuke.loadImage(with: url, into: leftView, handler: { (response, _) in
                    leftView.image = response.value
                })
            }
            
            return annotationView
        }
        
        return annotationView
    }
    
    func zoomToFitMapAnnotations() {
        guard mapView.annotations.count > 0 else { return }
        
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)

        mapView.annotations.forEach { (annotation) in
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }

        let regionCoordinate = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
        let span = MKCoordinateSpan(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1, longitudeDelta: fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1)
        var region = MKCoordinateRegion(center: regionCoordinate, span: span)

        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
}
