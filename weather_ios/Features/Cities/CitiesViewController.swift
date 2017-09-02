import UIKit

class CitiesViewController: UIViewController {
    @IBOutlet weak var citiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.authorization { [weak self] (authorized) in
            self?.startRefreshing()
        }
    }
    
    func startRefreshing() {
        LocationManager.shared.last { (coordinate) in
            
        }
    }
}
