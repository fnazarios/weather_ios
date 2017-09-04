import Foundation
import SwiftyDrop
import RxSwift
import RxCocoa

final class Banner {
    func success(message: String) {
        Drop.down(message, state: DropState.success)
    }
    
    func failure(message: String) {
        Drop.down(message, state: DropState.success)
    }
    
    func warning(message: String) {
        Drop.down(message, state: DropState.warning)
    }
}

extension Banner: ReactiveCompatible { }
extension Reactive where Base: Banner {
    var failureMessage: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base, binding: { (banner, message) in
            banner.failure(message: message)
        })
    }
    
    var warningMessage: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base, binding: { (banner, message) in
            banner.warning(message: message)
        })
    }
}

