import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class CitiesViewController: UIViewController {
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var mapViewButton: UIBarButtonItem!
    @IBOutlet weak var unitButton: UIBarButtonItem!

    private var refreshControl = UIRefreshControl()
    private let loadingView = Loading()
    private let bannerMessage = Banner()
    
    private var currentUnit: PreferredUnit = .celsius
    
    private let viewModel: CitiesViewModelType = CitiesViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.addSubview(refreshControl)
        citiesTableView.estimatedRowHeight = 80
        
        bindViewModel()
        bindLocalizationServices()
        setupRefreshControl()
        
        LocationManager.shared.requestAuthorization()

        NotificationCenter.default.addObserver(forName: preferredUnitChanged, object: nil, queue: nil) { [weak self] (notification) in
            guard let unit = notification.object as? PreferredUnit else { return }
            
            self?.currentUnit = unit
            self?.citiesTableView.reloadData()
        }
    }
    
    func setupRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] (_) in
                self?.startRefreshing()
            })
            .addDisposableTo(disposeBag)
    }
    
    func bindLocalizationServices() {
        LocationManager.shared.notAuthorizedMessage
            .bind(to: bannerMessage.rx.failureMessage)
            .addDisposableTo(disposeBag)
        
        LocationManager.shared.isAuthorized
            .filter({ $0 == true })
            .bind { [weak self] (_) in
                self?.startRefreshing()
            }
            .addDisposableTo(disposeBag)
    }
    
    func bindViewModel() {
        let isShowLoading = Observable.from([viewModel.outputs.isLoading.asObservable(), LocationManager.shared.isExecuting])
            .merge()
            .asDriver(onErrorJustReturn: false)
        
        isShowLoading
            .drive(refreshControl.rx.isRefreshing)
            .addDisposableTo(disposeBag)
        
        isShowLoading
            .drive(loadingView.rx.isShow)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.cities
            .bind(to: citiesTableView.rx.items(cellIdentifier: "CityTableViewCell", cellType: CityTableViewCell.self)) { [weak self] (row, model, cell) in
                cell.configure(withCity: model, preferredUnit: self?.currentUnit ?? .celsius)
            }
            .addDisposableTo(disposeBag)
    }
    
    func startRefreshing() {
        LocationManager.shared.last
            .bind { [weak self] (coordinate) in
                self?.viewModel.inputs.weatherFrom(lat: coordinate.latitude, lon: coordinate.longitude, count: 50)
            }
            .addDisposableTo(disposeBag)
    }
}
