import UIKit

extension UIViewController {
    func changeScreen(to viewController: UIViewController, animated: Bool = true, hideNavigationBar: Bool = false) {
        navigationController?.isNavigationBarHidden = hideNavigationBar
        navigationController?.pushViewController(viewController, animated: animated)
    }
}
