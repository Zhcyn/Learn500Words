import Foundation
import UIKit
fileprivate let kTagButtonInset:CGFloat = 8
class WDSearchResultTableViewCell:UITableViewCell {
    let titleLabel = UILabel()
    let tagButton = UIButton()
    let bottomSeparator = WDSeparator.init(type: .WDSeparatorTypeMiddle, frame: .zero)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init with coder not implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    func createViews() {
        titleLabel.font = WDFontTitleMedium
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagButton.titleLabel?.font = WDFontTagMedium
        tagButton.layer.cornerRadius = kCornerRadius
        tagButton.layer.masksToBounds = true
        tagButton.setTitleColor(UIColor.white, for: .normal)
        tagButton.isUserInteractionEnabled = false
        tagButton.contentEdgeInsets = UIEdgeInsetsMake(kTagButtonInset/2,kTagButtonInset,kTagButtonInset/2,kTagButtonInset)
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(tagButton)
        contentView.addSubview(bottomSeparator)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kSidePadding),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13)
            ])
        NSLayoutConstraint.activate([
            tagButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: kDefaultPadding),
            tagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kSidePadding),
            tagButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
            ])
        NSLayoutConstraint.activate([bottomSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                                     bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kSidePadding),
                                     bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
                                     bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                                     ])
    }
    func setTitle(_ title:String) {
        titleLabel.text = title
    }
    func setTitle(_ title:String, tag:WDSearchTag) {
        titleLabel.text = title
        tagButton.setTitle(tag.rawValue, for: .normal)
        tagButton.backgroundColor = WDSearchTag.getBackgroundColorFor(tag: tag)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        tagButton.setTitle("", for: .normal)
        tagButton.backgroundColor = UIColor.white
    }
}
