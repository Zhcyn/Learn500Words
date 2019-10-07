import UIKit
let kBulletInterItemPadding:CGFloat = 26
class WDBulletListView: UIView {
    let scrollView = UIScrollView()
    var bulletData:[String] = []
    var bulletLabels:[UILabel] = []
    var bulletLabelDots:[UIView] = []
    var lineView:UIView?
    let containerView = UIView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeProperties()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeProperties()
    }
    convenience init(withData data:[String]) {
        self.init()
        bulletData = data
        initializeProperties()
    }
    func initializeProperties() {
        createScrollView()
        createContainerView()
        if bulletData.isEmpty == false {
            createBullets()
        }
    }
    func createScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
    func createContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: self.widthAnchor)
            ])
    }
    func createBullets() {
        guard bulletData.isEmpty == false else {
            return
        }
        for bulletLabel in bulletLabels {
            bulletLabel.removeFromSuperview()
        }
        bulletLabels.removeAll()
        for bulletDot in bulletLabelDots {
            bulletDot.removeFromSuperview()
        }
        bulletLabelDots.removeAll()
        var bottomPadding:CGFloat = 0
        var nearestAnchor = containerView.topAnchor
        for bullet in bulletData {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = bullet
            label.font = WDFontBodyText
            label.textColor = WDTextBlack
            label.numberOfLines = 0
            containerView.addSubview(label)
            let labelDot = UIView()
            labelDot.backgroundColor = WDMainTheme
            labelDot.translatesAutoresizingMaskIntoConstraints = false
            labelDot.layer.cornerRadius = 5
            containerView.addSubview(labelDot)
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                label.leadingAnchor.constraint(equalTo: labelDot.trailingAnchor, constant:15),
                label.topAnchor.constraint(equalTo: nearestAnchor, constant:bottomPadding),
                ])
            NSLayoutConstraint.activate([
                labelDot.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant:10),
                labelDot.topAnchor.constraint(equalTo: label.topAnchor, constant:7),
                labelDot.widthAnchor.constraint(equalToConstant: 10),
                labelDot.heightAnchor.constraint(equalToConstant: 10)
                ])
            bottomPadding = kBulletInterItemPadding
            nearestAnchor = label.bottomAnchor
            bulletLabels += [label]
            bulletLabelDots += [labelDot]
        }
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: nearestAnchor, constant:kBulletInterItemPadding)
            ])
        layoutIfNeeded()
    }
    func setBullets(bullets:[String]) {
        bulletData = bullets
        createBullets()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = containerView.frame.size
        if scrollView.contentSize.height > 0 {
            for dot in self.bulletLabelDots {
                dot.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.27, execute: {
                self.animateLine()
                self.animateDots()
            })
        }
    }
    func animateDots() {
        for dot in bulletLabelDots {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                dot.transform = .identity
            }, completion: nil)
        }
    }
    func animateLine() {
        guard bulletLabelDots.isEmpty == false else {
            return
        }
        if let line = lineView {
            line.removeFromSuperview()
        }
        let dot = bulletLabelDots[0]
        let nextDot = bulletLabelDots[bulletLabelDots.count - 1]
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = WDMainTheme
        self.lineView = line
        containerView.addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: dot.centerXAnchor, constant:-1),
            line.topAnchor.constraint(equalTo: dot.centerYAnchor),
            line.trailingAnchor.constraint(equalTo: dot.centerXAnchor, constant:1),
            ])
        self.layoutIfNeeded()
        let distance =  Double((nextDot.center.y - dot.center.y))
        let animSpeed:Double = 1000
        let animDuration:Double = distance/(animSpeed)
        line.bottomAnchor.constraint(equalTo: nextDot.centerYAnchor).isActive = true
        UIView.animate(withDuration: animDuration, animations: {
            self.layoutIfNeeded()
        })
    }
}
