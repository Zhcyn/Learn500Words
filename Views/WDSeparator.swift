import UIKit
enum WDSeparatorType {
    case WDSeparatorTypeMiddle
}
class WDSeparator: UIView {
    convenience init(type:WDSeparatorType, frame:CGRect) {
        self.init(frame: frame)
        switch type {
        case .WDSeparatorTypeMiddle:
            self.backgroundColor = WDSeparatorGray
        }
    }
}
