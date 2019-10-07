import Foundation
import UIKit
fileprivate let numberOfDots = 3
let beginTimeMultiplier:Float = 0.07
class WDDottedLoader:UIView {
    var dots:[UIView] = []
    required init?(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented!")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let (x,_,width,height) = (frame.origin.x,frame.origin.y,frame.width,frame.height)
        for i in 0..<numberOfDots {
            let dotWidth = ((width)/CGFloat(numberOfDots)).rounded()
            let dotHeight = height*0.6
            let dotRect = CGRect(x: x + dotWidth*CGFloat(i) + (dotWidth/2 - dotHeight/2).rounded(), y: (height - dotHeight)/2, width: dotHeight, height: dotHeight)
            let dot = UIView()
            dot.backgroundColor = WDMainTheme
            dot.frame = dotRect
            dot.layer.cornerRadius = dotHeight/2
            dots += [dot]
            self.addSubview(dot)
        }
    }
    func startAnimating() {
        guard let dot = dots.first else {
            return
        }
        let beginTime = CACurrentMediaTime()
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.keyTimes = [0, 0.33, 0.66 , 1]
        animation.timingFunctions = [timingFunction,timingFunction,timingFunction]
        let dotSize = dot.frame.height
        animation.values = [0, dotSize*0.3, -dotSize*0.3, 0]
        animation.duration = 0.6
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        for (i,dot) in dots.enumerated() {
            animation.beginTime = beginTime + CFTimeInterval.init(Float(i+1)*beginTimeMultiplier)
            dot.layer.add(animation, forKey: "animation")
        }
    }
    func stopAnimating() {
        for dot in dots {
            dot.layer.removeAllAnimations()
        }
    }
}
