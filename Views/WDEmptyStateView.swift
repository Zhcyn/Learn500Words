import UIKit
class WDEmptyStateView: UIView {
    let iconLabel = UILabel()
    let messageLabel = UILabel()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createEmptyState()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        createEmptyState()
    }
    func createEmptyState() {
        self.backgroundColor = UIColor.white
        iconLabel.textColor = WDMainTheme
        iconLabel.font = WDIconFontEmptyState
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.textAlignment = .center
        if let iconString = try? "&#xf4d7;".convertHtmlSymbols() {
            iconLabel.text = iconString
        }
        self.addSubview(self.iconLabel)
        messageLabel.textColor = WDTextBlack
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.font = WDFontBodyText
        messageLabel.numberOfLines = 0
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -kDefaultPadding)
            ])
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: iconLabel.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 2*kDefaultPadding),
            messageLabel.leadingAnchor.constraint(lessThanOrEqualTo: self.leadingAnchor, constant:kSidePadding),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant:-kSidePadding)
            ])
    }
    func setEmptyStateMessage(message:String) {
        messageLabel.text = message
    }
}
