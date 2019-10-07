import UIKit
enum WDRoundRectButtonState {
    case WDRoundRectButtonStateDefault, WDRoundRectButtonStateGreen
}
class WDRoundRectButton: UIButton {
    var roundRectButtonState:WDRoundRectButtonState = .WDRoundRectButtonStateDefault {
        didSet {
            setProperties(forState: roundRectButtonState)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setDefaultProperties()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaultProperties()
    }
    convenience init() {
        self.init(type: .system)
        setDefaultProperties()
    }
    func setDefaultProperties() {
        self.backgroundColor = WDMainTheme
        self.titleLabel?.font = WDFontBigButtonTitle
        self.setTitleColor(UIColor.white, for: .normal)
        self.layer.cornerRadius = kCornerRadius
    }
    func setProperties(forState state:WDRoundRectButtonState) {
        switch roundRectButtonState {
        case .WDRoundRectButtonStateDefault:
            setDefaultProperties()
        case .WDRoundRectButtonStateGreen:
            setDefaultProperties()
            self.backgroundColor = WDColorGreen
        }
    }
}
