import UIKit
let kTextFieldHeight:CGFloat = 55
let kSearchResultReuseIdentifer = "SearchResultCell"
let kDottedLoaderWidth:CGFloat = 52
let kDottedLoaderHeight:CGFloat = 16
let tableY = kStatusBarHeight + kTextFieldHeight + 3*kDefaultPadding
fileprivate let kFirstRunHoverAnimationKey = "WDFirstRunTranslationAnimation"
class WDSearchViewController: UIViewController {
    let searchTextField = UITextField()
    var firstRunLabel:UILabel?
    let textFieldSeparator = WDSeparator.init(type: .WDSeparatorTypeMiddle, frame: .zero)
    let searchTableView = UITableView.init(frame: .zero, style: .plain)
    let wordSearchObject = WordSearch()
    let dottedLoader = WDDottedLoader(frame: CGRect(x: 0, y: 0, width: kDottedLoaderWidth, height: kDottedLoaderHeight))
    var firstRunHoverAnimation:CABasicAnimation?
    var didShowHoverFirstRun = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kSearchNavigationTitle
        registerForNotifications()
        createSearchTextField()
        createTableView()
        createDottedLoader()
        view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSearchFirstRun()
    }
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(willShowKeyboard(notification:)) , name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(willHideKeyboard) , name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidSaveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidRemoveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidRemoveAllWords), object: nil)
    }
    fileprivate func createTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.tableFooterView = UIView.init()
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 55
        searchTableView.register(WDSearchResultTableViewCell.self, forCellReuseIdentifier: kSearchResultReuseIdentifer)
        searchTableView.separatorStyle = .none
        view.addSubview(searchTableView)
    }
    fileprivate func createSearchTextField() {
        searchTextField.frame = CGRect(x: kSidePadding, y: (view.frame.size.height - kTextFieldHeight)/2 - 20, width: view.frame.size.width - 2*kSidePadding, height: kTextFieldHeight)
        searchTextField.tintColor = WDTextBlack
        var placeholderFont = WDFontSearchPlaceholderBig
        if view.frame.width <= 320 {
            placeholderFont = WDFontSearchPlaceholderMedium
        }
        let placeholderAttributes = [NSAttributedStringKey.font: placeholderFont as Any,
                                     NSAttributedStringKey.foregroundColor: WDLightGray as Any]
        searchTextField.font = WDFontBigTitleSemiBold
        searchTextField.textColor = WDTextBlack
        searchTextField.attributedPlaceholder = NSAttributedString.init(string: "Search a word", attributes: placeholderAttributes)
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        searchTextField.clearButtonMode = .always
        view.addSubview(searchTextField)
        searchTextField.becomeFirstResponder()
        searchTextField.resignFirstResponder()
        textFieldSeparator.frame = CGRect(x: 0, y: searchTextField.frame.height - 1, width: searchTextField.frame.width - kSidePadding, height: 1)
        searchTextField.addSubview(textFieldSeparator)
    }
    fileprivate func createDottedLoader() {
        dottedLoader.backgroundColor = UIColor.white
        dottedLoader.alpha = 0
        view.addSubview(dottedLoader)
    }
    func transitionToSearchState(keyboardHeight:CGFloat) {
        if self.searchTableView.alpha == 0 {
            searchTableView.contentOffset = CGPoint(x: 0, y: -searchTableView.contentInset.top)
        }
        hideFirstRun()
        UIView.animate(withDuration: 0.17, animations: {
            self.searchTextField.frame = CGRect(x: self.searchTextField.frame.origin.x, y: kStatusBarHeight + kDefaultPadding, width: (self.view.frame.size.width - 2*kSidePadding) - 2*kDefaultPadding - kDottedLoaderWidth, height: self.searchTextField.frame.height)
            self.dottedLoader.frame = CGRect(x: self.searchTextField.frame.origin.x + self.searchTextField.frame.width + kDefaultPadding, y: self.searchTextField.frame.origin.y + self.searchTextField.frame.height/2 - kDottedLoaderHeight/2, width: kDottedLoaderWidth, height: kDottedLoaderHeight)
        }) { (finished) in
            UIView.animate(withDuration: 0.15, animations: {
                self.searchTableView.frame = CGRect(x: 0, y: tableY, width: self.view.frame.width , height: self.view.frame.height - tableY - keyboardHeight)
                self.searchTableView.alpha = 1
            })
        }
    }
    func transitionToDefaultState() {
        if didShowHoverFirstRun {
            hideFirstRun()
        }
        if searchTextField.text?.isEmpty == true {
            self.searchTableView.alpha = 0.0
            let searchFieldOriginY = (self.view.frame.size.height - kTextFieldHeight)/2 - 20
            UIView.animate(withDuration: 0.2) {
                self.searchTextField.frame = CGRect(x: kSidePadding, y: searchFieldOriginY, width: self.view.frame.size.width - 2*kSidePadding, height: self.searchTextField.frame.height)
            }
        }
        else {
            self.searchTableView.alpha = 1
            var bottomPadding:CGFloat = 0.0
            if let tabBarHeight = self.tabBarController?.tabBar.frame.size.height {
                bottomPadding += tabBarHeight
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.searchTextField.frame = CGRect(x: self.searchTextField.frame.origin.x, y: kStatusBarHeight + kDefaultPadding, width: (self.view.frame.size.width - 2*kSidePadding) - 2*kDefaultPadding - kDottedLoaderWidth, height: self.searchTextField.frame.height)
                self.dottedLoader.frame = CGRect(x: self.searchTextField.frame.origin.x + self.searchTextField.frame.width + kDefaultPadding, y: self.searchTextField.frame.origin.y + self.searchTextField.frame.height/2 - kDottedLoaderHeight/2, width: kDottedLoaderWidth, height: kDottedLoaderHeight)
                self.searchTableView.frame = CGRect(x: 0, y: tableY, width: self.view.frame.width , height: self.view.frame.height - tableY - bottomPadding)
            })
        }
    }
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.isCurrentActiveTabController() else {return}
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            transitionToSearchState(keyboardHeight: keyboardHeight)
        }
    }
    @objc func willHideKeyboard() {
        guard self.isCurrentActiveTabController() else {return}
            transitionToDefaultState()
    }
    func clearResults() {
        hideDottedLoader()
        wordSearchObject.clearSearch()
        searchTableView.reloadData()
    }
    func showDottedLoader() {
        if dottedLoader.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.dottedLoader.alpha = 1
            }, completion: { (finished) in
                self.dottedLoader.startAnimating()
            })
        }
    }
    func hideDottedLoader() {
        dottedLoader.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.dottedLoader.alpha = 0
        }
    }
    @objc func refreshTableView() {
        searchTableView.reloadData()
    }
    func showSearchFirstRun() {
        if let label = firstRunLabel, let hoverAnim = self.firstRunHoverAnimation {
            label.layer.removeAnimation(forKey: kFirstRunHoverAnimationKey)
            label.layer.add(hoverAnim, forKey: kFirstRunHoverAnimationKey)
        }
        else {
            guard WDHelpers.isFirstLaunch() && didShowHoverFirstRun == false else {return}
            didShowHoverFirstRun = true
            let label = UILabel()
            label.backgroundColor = UIColor.white
            var fontIconString:String?
            do {
                try fontIconString = "&#xf126;".convertHtmlSymbols()
                if let fontIconString = fontIconString {
                    let attributedTitle = NSMutableAttributedString.init(string: fontIconString,
                                                                         attributes: [NSAttributedStringKey.font:WDFonts.iconFontWith(size: 14),
                                                                                      NSAttributedStringKey.foregroundColor:WDTextBlack,
                                                                                      NSAttributedStringKey.baselineOffset:-1])
                    attributedTitle.append(NSMutableAttributedString.init(string: " \(kSearchFirstRunMessage)", attributes:[NSAttributedStringKey.font:WDFontBannerMedium,NSAttributedStringKey.foregroundColor:WDTextBlack]))
                    label.attributedText = attributedTitle
                }
            }
            catch {
                label.text = kSearchFirstRunMessage
                label.font = WDFontBannerMedium
                label.textColor = WDTextBlack
                print("Fatal error in loading icon fonts")
            }
            label.sizeToFit()
            view.addSubview(label)
            firstRunLabel = label
            label.frame.origin = CGPoint(x: self.searchTextField.frame.origin.x, y: self.searchTextField.frame.maxY + kDefaultPadding)
            let alphaAnimation = WDAnimationFactory.alphaAnimation()
            alphaAnimation.beginTime = CACurrentMediaTime() + 0.5
            alphaAnimation.setValue(label.layer, forKey: "layer")
            alphaAnimation.delegate = self
            label.layer.add(alphaAnimation, forKey: nil)
            firstRunLabel = label
        }
    }
    func hideFirstRun() {
        guard WDHelpers.isFirstLaunch() && didShowHoverFirstRun == true else {return}
        if let label = firstRunLabel {
            if label.layer.animation(forKey: kFirstRunHoverAnimationKey) != nil {
                label.layer.removeAnimation(forKey: kFirstRunHoverAnimationKey)
            }
            UIView.animate(withDuration: 0.08, animations: {
                label.alpha = 0.0
            }, completion: { (_) in
                label.removeFromSuperview()
                self.firstRunLabel = nil
            })
        }
    }
}
extension WDSearchViewController:CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let layer = anim.value(forKey: "layer") as? CALayer else {return}
        let hoverAnim = WDAnimationFactory.hoverAnimationWith(layer: layer)
        layer.add(hoverAnim, forKey: kFirstRunHoverAnimationKey)
        self.firstRunHoverAnimation = hoverAnim
        anim.setValue(nil, forKey: "layer")
    }
}
extension WDSearchViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let existingText = textField.text! as NSString
        let updatedText = existingText.replacingCharacters(in: range, with: string)
        if updatedText.count > 1 {
            wordSearchObject.performSearch(withQuery: updatedText, delegate: self)
            showDottedLoader()
            if  (searchTextField.frame.origin.y != kStatusBarHeight + kDefaultPadding) {
                transitionToDefaultState()
            }
        }
        else {
            clearResults()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearResults()
        return true
    }
}
extension WDSearchViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSearchResultReuseIdentifer)!
        if let cell = cell as? WDSearchResultTableViewCell {
            if WDWordListManager.sharedInstance.isWordSaved(word: wordSearchObject.searchResults[indexPath.row]).exists == true {
                cell.setTitle(wordSearchObject.searchResults[indexPath.row].word, tag: .Added)
            }
            else {
                cell.setTitle(wordSearchObject.searchResults[indexPath.row].word)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordSearchObject.searchResults.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        view.endEditing(true)
        let wordDetailVC = WDWordDetailViewController.init(withWord: wordSearchObject.searchResults[indexPath.row])
        self.navigationController?.pushViewController(wordDetailVC, animated: true)
    }
}
extension WDSearchViewController:WordSearchDelegate {
    func didPerformSearchSuccessfully(forQuery query: String) {
        searchTableView.reloadData()
        hideDottedLoader()
    }
    func didFailToSearch(query: String) {
        WDHelpers.showInternetErrorDropdown()
        searchTableView.reloadData()
        hideDottedLoader()
    }
}
