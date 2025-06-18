import UIKit

extension UITableViewCell {
    func applyRoundedCorners(at indexPath: IndexPath, totalRows: Int) {
        if indexPath.row == 0 {
            self.layer.cornerRadius = 16
            self.layer.maskedCorners = totalRows == 1
                ? [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
                : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == totalRows - 1 {
            self.layer.cornerRadius = 16
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            self.layer.cornerRadius = 0
        }
    }
}
