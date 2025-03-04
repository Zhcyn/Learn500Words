import Foundation
import Foundation
import UIKit
let WDMainTheme = UIColor.init(hex:0xFE5F55)
let WDLightGray = UIColor.init(hex: 0xDDDDDD)
let WDTextBlack = UIColor.init(hex:0x2D2D2D)
let WDSeparatorGray = UIColor.init(hex:0xEAEAEA)
let WDColorGreen = UIColor.init(hex:0x8FD446)
extension UIColor {
    convenience init(red:Int, green:Int, blue:Int) {
        guard (red >= 0 && red <= 255) && (green >= 0 && green <= 255) && (blue >= 0 && blue <= 255) else {
            self.init()
            return
        }
        let redComponent = CGFloat.init(red)/255.0
        let greenComponent = CGFloat.init(green)/255.0
        let blueComponent = CGFloat.init(blue)/255.0
        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 1.0)
    }
    convenience init(hex:Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: (hex) & 0xFF)
    }
}
