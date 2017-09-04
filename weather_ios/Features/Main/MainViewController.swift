import UIKit

enum PreferredView {
    case map
    case list
}

class MainViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    private var unitButton: UIBarButtonItem?
    private var viewStyleButton: UIBarButtonItem?
    private var currentViewController: UIViewController?
    private var currentUnit: PreferredUnit = .celsius
    private var currentView: PreferredView = .list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewStyleButton = UIBarButtonItem(image: UIImage(named: "icon_list"), style: UIBarButtonItemStyle.done, target: self, action: #selector(MainViewController.viewStyleChanged))
        unitButton = UIBarButtonItem(title: "Fº", style: UIBarButtonItemStyle.done, target: self, action: #selector(MainViewController.unitButtonTapped))
        navigationItem.setRightBarButtonItems([viewStyleButton!, unitButton!], animated: true)
        
        listSelected()
    }
    
    func transition(to viewController: UIViewController) {
        if let viewControllerPresented = currentViewController {
            viewControllerPresented.view.removeFromSuperview()
            viewControllerPresented.removeFromParentViewController()
        }
            
        addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        
        viewController.didMove(toParentViewController: self)
        viewController.view.frame = containerView.bounds
        containerView.layoutIfNeeded()
        viewController.view.layoutIfNeeded()
        
        currentViewController = viewController
    }
    
    func mapSelected() {
        currentView = .map
        viewStyleButton?.image = UIImage(named: "icon_list")
        
        let mapViewController: MapCitiesViewController = MapCitiesViewController.instantiateViewController(self)
        transition(to: mapViewController)
    }
    
    func listSelected() {
        currentView = .list
        viewStyleButton?.image = UIImage(named: "icon_map")
        
        let listViewController: CitiesViewController = CitiesViewController.instantiateViewController(self)
        transition(to: listViewController)
    }
    
    @objc func viewStyleChanged() {
        switch currentView {
        case .list:
            mapSelected()
        case .map:
            listSelected()
        }
    }
    
    @objc func unitButtonTapped() {
        switch currentUnit {
        case .celsius:
            currentUnit = .fahrenheit
            unitButton?.title = "Cº"
            
        case .fahrenheit:
            currentUnit = .celsius
            unitButton?.title = "Fº"
        default: break
        }
        
        NotificationCenter.default.post(name: preferredUnitChanged, object: currentUnit)
    }
}
