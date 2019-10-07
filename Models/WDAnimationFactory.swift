import Foundation
import UIKit
enum WDAnimationFactory {
    static func hoverAnimationWith(layer:CALayer) -> CABasicAnimation {
        let hoverAnimation = CABasicAnimation(keyPath: "position.y")
        hoverAnimation.fromValue = layer.position.y
        hoverAnimation.toValue = layer.position.y + 5
        hoverAnimation.duration = 0.5
        hoverAnimation.repeatCount = Float.infinity
        hoverAnimation.autoreverses = true
        return hoverAnimation
    }
    static func alphaAnimation()->CABasicAnimation {
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fillMode = kCAFillModeBoth
        alphaAnimation.fromValue = 0
        alphaAnimation.toValue = 1
        alphaAnimation.duration = 0.5
        return alphaAnimation
    }
}
