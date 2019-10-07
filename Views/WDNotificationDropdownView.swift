import UIKit
fileprivate let kDropdownAnimationDuration = 0.2
class WDNotificationDropdownView: UIView {
    let messageLabel = UILabel()
    var panGesture:UIPanGestureRecognizer!
    var totalDrag:Int = 0
    var didBeginPan = false
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44 + kStatusBarHeight))
        self.addSubview(messageLabel)
        self.backgroundColor = WDTextBlack
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.addGestureRecognizer(panGesture)
        messageLabel.font = WDFontBannerMedium
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageLabel.frame = CGRect(x: kSidePadding, y: 0, width: self.frame.width - 2*kSidePadding, height: self.frame.height - 2*kDefaultPadding)
        messageLabel.center = self.center
    }
    func setMessage(_ message:String ) {
        messageLabel.text = message
        messageLabel.sizeToFit()
        self.frame.size = CGSize(width: self.frame.width, height:  messageLabel.frame.height + kStatusBarHeight + 2*kDefaultPadding)
        messageLabel.frame = CGRect(x: kSidePadding, y: (self.frame.height)/2 - (messageLabel.frame.height/2) + kDefaultPadding, width: self.frame.width - 2*kSidePadding, height: messageLabel.frame.height)
    }
    @objc func handlePan(gesture:UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            totalDrag = 0
            didBeginPan = true
        case .changed:
            totalDrag = Int(gesture.translation(in: self.superview).y)
            if totalDrag < 0 {
                if totalDrag < -20 {
                    gesture.isEnabled = false
                }
                else {
                    self.transform = CGAffineTransform(translationX: 0, y: CGFloat(totalDrag))
                }
            }
        case .cancelled, .ended:
            WDNotificationDropdownView.hide(dropdown: self)
        default:
            WDNotificationDropdownView.hide(dropdown: self)
        }
    }
    static func showWith(message:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.dropdown == nil, let window = appDelegate.window else {
            return
        }
        let dropdown = WDNotificationDropdownView.init()
        dropdown.setMessage(message)
        appDelegate.dropdown = dropdown
        dropdown.transform = CGAffineTransform(translationX: 0, y: -dropdown.frame.height)
        window.addSubview(dropdown)
        UIView.animate(withDuration: kDropdownAnimationDuration, animations: {
            dropdown.transform = .identity
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                if dropdown.didBeginPan == false {
                    WDNotificationDropdownView.hide(dropdown: dropdown)
                }
            })
        }
    }
    static func hide(dropdown:WDNotificationDropdownView) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.dropdown === dropdown else {
            return
        }
        dropdown.panGesture.isEnabled = false
        appDelegate.dropdown = nil
        UIView.animate(withDuration: kDropdownAnimationDuration, animations: {
            dropdown.transform = CGAffineTransform(translationX: 0, y: -dropdown.frame.height)
        }) { (_) in
            dropdown.removeFromSuperview()
        }
    }
}
