import UIKit

extension UIViewController {
    static func instantiateViewController<T: UIViewController>(_ parentViewController: UIViewController) -> T {
        guard let storyboard = parentViewController.storyboard else { return T() }
        
        let identifier = String(describing: type(of: T()))
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else { return T() }
        
        return viewController
    }
}
