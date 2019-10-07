import UIKit
protocol WDNavigationHeaderDelegate {
    func didTapBackButton()
}
class WDNavigationHeader: UIView {
    fileprivate let backButton = UIButton(type: .system)
    var delegate:WDNavigationHeaderDelegate?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    func createViews() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.titleEdgeInsets = UIEdgeInsetsMake(-5, -15, -5, -15)
        self.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: kSidePadding),
            backButton.topAnchor.constraint(equalTo: self.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
    }
    @objc func backButtonPressed() {
        delegate?.didTapBackButton()
    }
    func setBackButton(title:String) {
        var fontIconString:String?
        do {
            try fontIconString = "&#xf124;".convertHtmlSymbols()
        }
        catch {
            print("Fatal error")
        }
        if let fontIconString = fontIconString {
            let attributedTitle = NSMutableAttributedString.init(string: fontIconString, attributes: [NSAttributedStringKey.font:WDIconFont,
                                                                                                      NSAttributedStringKey.foregroundColor:WDMainTheme,
                                                                                                      NSAttributedStringKey.baselineOffset:-1])
            attributedTitle.append(NSMutableAttributedString.init(string: " \(title)", attributes: [NSAttributedStringKey.font:WDFontSectionHeader,
                                                                                              NSAttributedStringKey.foregroundColor:WDMainTheme]))
            backButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
}
