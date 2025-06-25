import UIKit

extension UILabel {
    func attributedText(
        withString string: String,
        highlightedString: String,
        normalFont: UIFont?,
        highlightColor: UIColor,
        normalColor: UIColor = .label
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: string,
            attributes: [
                .font: normalFont ?? .systemFont(ofSize: 20),
                .foregroundColor: normalColor
            ]
        )
        
        let range = (string as NSString).range(of: highlightedString)
        if range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
        }
        
        return attributedString
    }
}

