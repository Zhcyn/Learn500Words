import UIKit
let SettingsCellReuseIdentifier = "SettingsCellReuseIdentifier"
class WDSettingsViewController: WDBaseViewController {
    var tableData = [String]()
    var nightModeSwitch: UISwitch?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
        NotificationCenter.default.addObserver(self, selector: #selector(createTableData), name: Notification.Name(NotificationDidSaveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createTableData), name: Notification.Name(NotificationDidRemoveWord), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createTableData), name: Notification.Name(NotificationDidRemoveAllWords), object: nil)
        self.navigationItem.title = kSettingsNavigationTitle
        self.headingLabel.text = self.navigationItem.title
        self.contentTableView.delegate = self
        self.contentTableView.dataSource = self
        self.contentTableView.rowHeight = 78
        self.contentTableView.separatorColor = WDSeparatorGray
        self.contentTableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsCellReuseIdentifier)
        createTableData()
    }
    @objc func createTableData() {
        self.tableData.removeAll()
        self.tableData += ["Licences"]
        if WDWordListManager.sharedInstance.getWords().isEmpty == false {
            self.tableData += ["Delete saved words"]
        }
        self.contentTableView.reloadData()
    }
}
extension WDSettingsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellReuseIdentifier)
        cell?.textLabel?.font = WDFontTitleMedium
        cell?.textLabel?.text = tableData[indexPath.row]
        cell?.tintColor = WDMainTheme
        if indexPath.row == self.tableData.count - 1 && WDWordListManager.sharedInstance.getWords().isEmpty == false  {
            cell?.textLabel?.textColor = WDMainTheme
        }
        else {
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == self.tableData.count - 1 && WDWordListManager.sharedInstance.getWords().isEmpty == false {
            showAlert()
        }
        else if indexPath.row == 0 {
            self.navigationController?.pushViewController( WDWebViewController(), animated: true)
        }
    }
    func showAlert() {
        let alertController = UIAlertController.init(title: "Are you sure?", message: "This action will delete all saved words from the application and is irreversible", preferredStyle: .alert)
        let deleteAction = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            WDWordListManager.sharedInstance.removeAllWords()
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
