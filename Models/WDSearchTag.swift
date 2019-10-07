import Foundation
import UIKit
enum WDSearchTag:String {
    case Added
    static func getBackgroundColorFor(tag:WDSearchTag) -> UIColor {
        switch tag {
        case .Added:
            return WDColorGreen
        }
    }
}
