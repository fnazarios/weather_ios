import UIKit
import RxSwift
import RxCocoa

class CitiesViewController: UIViewController {
    @IBOutlet weak var citiesTableView: UITableView!
    
    private let viewModel: CitiesViewModelType = CitiesViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.estimatedRowHeight = 80
        
        bindViewModel()
        LocationManager.shared.authorization { [weak self] (authorized) in
            self?.startRefreshing()
        }
    }
    
    func bindViewModel() {
        viewModel.outputs.cities
            .bind(to: citiesTableView.rx.items(cellIdentifier: "CityTableViewCell", cellType: CityTableViewCell.self)) { (row, model, cell) in
                cell.configure(withCity: model, preferredUnit: PreferredUnit.celsius)
            }
            .addDisposableTo(disposeBag)
    }
    
    func startRefreshing() {
        LocationManager.shared.last { [weak self] (coordinate) in
            self?.viewModel.inputs.weatherFrom(lat: coordinate?.latitude ?? 0.0, lon: coordinate?.longitude ?? 0.0, count: 50)
        }
    }
}
