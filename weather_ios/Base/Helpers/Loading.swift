import Foundation
import PKHUD
import RxCocoa
import RxSwift

final class Loading {
    func show() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        HUD.show(.progress)
    }
    
    func hide() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        HUD.hide()
    }
}

extension Loading: ReactiveCompatible { }

extension Reactive where Base: Loading {
    var isShow: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base, binding: { (loading, show) in
            if show {
                loading.show()
            } else {
                loading.hide()
            }
        })
    }
}

