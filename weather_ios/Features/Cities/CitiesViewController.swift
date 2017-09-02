import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class CitiesViewController: UIViewController {
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var mapViewButton: UIBarButtonItem!
    @IBOutlet weak var unitButton: UIBarButtonItem!
    
    private var refreshControl = UIRefreshControl()
    private let viewModel: CitiesViewModelType = CitiesViewModel()
    private let disposeBag = DisposeBag()
    private var currentUnit: PreferredUnit = .celsius
    private let loadingView = Loading()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.addSubview(refreshControl)
        citiesTableView.estimatedRowHeight = 80
        
        bindViewModel()
        
        LocationManager.shared.authorization { [weak self] (authorized) in
            self?.loadingView.show()
            self?.startRefreshing()
        }
        
        NotificationCenter.default.addObserver(forName: preferredUnitChanged, object: nil, queue: nil) { [weak self] (notification) in
            guard let unit = notification.object as? PreferredUnit else { return }
            
            self?.currentUnit = unit
            self?.citiesTableView.reloadData()
        }
    }
    
    func bindViewModel() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] (_) in
                self?.startRefreshing()
            })
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.isLoading
            .drive(refreshControl.rx.isRefreshing)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.isLoading
            .drive(loadingView.rx.isShow)
            .addDisposableTo(disposeBag)
        
        viewModel.outputs.cities
            .bind(to: citiesTableView.rx.items(cellIdentifier: "CityTableViewCell", cellType: CityTableViewCell.self)) { [weak self] (row, model, cell) in
                cell.configure(withCity: model, preferredUnit: self?.currentUnit ?? .celsius)
            }
            .addDisposableTo(disposeBag)
    }
    
    func startRefreshing() {
        LocationManager.shared.last { [weak self] (coordinate) in
            self?.viewModel.inputs.weatherFrom(lat: coordinate?.latitude ?? 0.0, lon: coordinate?.longitude ?? 0.0, count: 50)
        }
    }
}
