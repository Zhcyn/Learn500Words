import UIKit
let WordListCellReuseIdentifier = "WordListCellReuseIdentifier"
fileprivate let kEstimatedListRowHeight:CGFloat = 78.0
class WDWordListViewController: WDBaseViewController {
    var tableData = [WordObject]()
    var searchTableData = [WordObject]()
    let emptyStateView = WDEmptyStateView()
    let searchBar:UISearchBar = UISearchBar()
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidSaveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidRemoveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Notification.Name(NotificationDidRemoveAllWords), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(willShowKeyboard(notification:)) , name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(willHideKeyboard) , name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
        registerForNotifications()
        createSearchBar()
        createEmptyStateView()
        self.headingLabel.text = kListNavigationTitle
        self.navigationItem.title = self.headingLabel.text
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        self.contentTableView.rowHeight = kEstimatedListRowHeight
        self.contentTableView.register(UITableViewCell.self, forCellReuseIdentifier: WordListCellReuseIdentifier)
        refreshTableView()
    }
    func createSearchBar() {
        view.addSubview(searchBar)
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search"
        searchBar.returnKeyType = .done
        searchBar.tintColor = WDTextBlack
        searchBar.delegate = self
        contentTableViewTopConstraint.isActive = false
        contentTableViewTopConstraint = contentTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: self.headingLabel.bottomAnchor, constant: 2*kDefaultPadding),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            contentTableViewTopConstraint
            ])
    }
    func createEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        emptyStateView.setEmptyStateMessage(message: "You don't seem to have any words saved.\n Words you add will show up here!")
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    @objc func refreshTableView() {
        tableData = WDWordListManager.sharedInstance.getWords()
        self.contentTableView.reloadData()
        if tableData.isEmpty == true {
            emptyStateView.isHidden = false
        }
        else {
            emptyStateView.isHidden = true
        }
    }
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.isCurrentActiveTabController() else {return}
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            contentTableViewBottomConstraint.isActive = false
            contentTableViewBottomConstraint = contentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-keyboardHeight)
            NSLayoutConstraint.activate([
                contentTableViewBottomConstraint
                ])
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc func willHideKeyboard() {
        guard self.isCurrentActiveTabController() else {return}
        contentTableViewBottomConstraint.isActive = false
        contentTableViewBottomConstraint = contentTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-WDHelpers.tabBarHeight)
        NSLayoutConstraint.activate([
            contentTableViewBottomConstraint
            ])
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
extension WDWordListViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTableData = tableData.filter({ (wordObject) -> Bool in
            wordObject.word.localizedCaseInsensitiveContains(searchText)
        })
        if searchText.isEmpty == false {
            contentTableView.contentOffset = CGPoint(x: 0, y: -contentTableView.contentInset.top)
        }
        contentTableView.reloadData()
    }
}
extension WDWordListViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.isEmpty == false {
            return self.searchTableData.count
        }
        else {
            return self.tableData.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WordListCellReuseIdentifier)
        if searchBar.text?.isEmpty == false {
            cell?.textLabel?.text = searchTableData[indexPath.row].word
        }
        else {
            cell?.textLabel?.text = tableData[indexPath.row].word
        }
        cell?.textLabel?.font = WDFontTitleMedium
        cell?.tintColor = WDMainTheme
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var selectedWord:WordObject!
        if searchBar.text?.isEmpty == false {
            selectedWord = searchTableData[indexPath.row]
        }
        else {
            selectedWord = tableData[indexPath.row]
        }
        let wordDetailVC = WDWordDetailViewController.init(withWord: selectedWord)
        wordDetailVC.delegate = self
        self.navigationController?.pushViewController(wordDetailVC, animated: true)
    }
}
extension WDWordListViewController:WDWordDetailViewControllerDelegate {
    func didSaveWord(wordInstance: WordObject) {
        refreshTableView()
    }
    func didRemoveWord(wordInstance: WordObject) {
        refreshTableView()
    }
}
