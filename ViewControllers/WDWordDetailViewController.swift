import UIKit
protocol WDWordDetailViewControllerDelegate {
    func didSaveWord(wordInstance:WordObject)
    func didRemoveWord(wordInstance:WordObject)
}
class WDWordDetailViewController: UIViewController {
    let wordLabel = UILabel()
    let definitionHeadingLabel = UILabel()
    fileprivate var wordObject:WordObject!
    let headerView = WDNavigationHeader()
    let wordLabelSeparator = WDSeparator.init(type: .WDSeparatorTypeMiddle, frame: .zero)
    let bottomRectButton = WDRoundRectButton()
    var delegate:WDWordDetailViewControllerDelegate?
    let bulletView:WDBulletListView = WDBulletListView()
    convenience init(withWord word:WordObject) {
        self.init()
        self.wordObject = word
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBottomButton), name: Notification.Name(NotificationDidSaveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBottomButton), name: Notification.Name(NotificationDidRemoveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBottomButton), name: Notification.Name(NotificationDidRemoveAllWords), object: nil)
        view.backgroundColor = UIColor.white
        if let backTitle = self.navigationController?.navigationBar.items?.last?.title {
            headerView.setBackButton(title: backTitle)
        }
        else {
            headerView.setBackButton(title: "")
        }
        headerView.delegate = self
        view.addSubview(headerView)
        wordLabel.text = self.wordObject.word
        definitionHeadingLabel.text = DefinitionHeadingString
        wordLabel.numberOfLines = 0
        headerView.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabelSeparator.translatesAutoresizingMaskIntoConstraints = false
        definitionHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomRectButton.translatesAutoresizingMaskIntoConstraints = false
        bulletView.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.font = WDFontBigTitleSemiBold
        wordLabel.textColor = WDTextBlack
        definitionHeadingLabel.font = WDFontSectionHeader
        definitionHeadingLabel.textColor = WDLightGray
        refreshBottomButton()
        bottomRectButton.addTarget(self, action: #selector(bottomButtonTapped), for: .touchUpInside)
        bulletView.setBullets(bullets: self.wordObject.definitions)
        view.addSubview(wordLabel)
        view.addSubview(wordLabelSeparator)
        view.addSubview(definitionHeadingLabel)
        view.addSubview(bulletView)
        view.addSubview(bottomRectButton)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant:kStatusBarHeight),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: kNavigationBarHeight)
            ])
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 17),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kSidePadding),
            wordLabelSeparator.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 2),
            wordLabelSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: kSidePadding),
            wordLabelSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            wordLabelSeparator.heightAnchor.constraint(equalToConstant: kSeparatorHeight)
            ])
        NSLayoutConstraint.activate([
            definitionHeadingLabel.topAnchor.constraint(equalTo: wordLabelSeparator.bottomAnchor, constant: 30),
            definitionHeadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: kSidePadding),
            definitionHeadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kSidePadding)
            ])
        NSLayoutConstraint.activate([
            bulletView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:kSidePadding),
            bulletView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-kSidePadding),
            bulletView.topAnchor.constraint(equalTo: definitionHeadingLabel.bottomAnchor, constant:kDefaultPadding),
            bulletView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-WDHelpers.tabBarHeight)
            ])
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        var bottomPadding = kDefaultPadding
        if let tabBarHeight = tabBarHeight {
            bottomPadding += tabBarHeight
        }
        NSLayoutConstraint.activate([
            bottomRectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: kSidePadding),
            bottomRectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -kSidePadding),
            bottomRectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(bottomPadding) )
            ])
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = (bottomRectButton.frame.size.height + 2*kDefaultPadding)
        bulletView.scrollView.contentSize = CGSize(width: bulletView.containerView.frame.width, height: bulletView.containerView.frame.height + bottomInset)
        bulletView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottomInset, 0)
    }
    @objc func refreshBottomButton() {
        if WDWordListManager.sharedInstance.isWordSaved(word: self.wordObject).exists == true {
            bottomRectButton.setTitle("Added", for: .normal)
            bottomRectButton.roundRectButtonState = .WDRoundRectButtonStateGreen
        }
        else {
            bottomRectButton.setTitle("Add", for: .normal)
            bottomRectButton.roundRectButtonState = .WDRoundRectButtonStateDefault
        }
    }
    @objc func bottomButtonTapped() {
        switch bottomRectButton.roundRectButtonState {
        case .WDRoundRectButtonStateDefault:
            WDWordListManager.sharedInstance.save(word: self.wordObject)
            delegate?.didSaveWord(wordInstance: self.wordObject)
        case .WDRoundRectButtonStateGreen:
            WDWordListManager.sharedInstance.remove(word: self.wordObject)
            delegate?.didRemoveWord(wordInstance: self.wordObject)
        }
        refreshBottomButton()
    }
}
extension WDWordDetailViewController:WDNavigationHeaderDelegate {
    func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
