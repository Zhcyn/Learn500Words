import UIKit
import Fabric
import Crashlytics
let appKey = "314f9f9be320e2f8be44b063"
let channel = "Publish channel"
let isProduction = true
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var blockRotation = Bool()
    var dropdown:WDNotificationDropdownView?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setLaunchCount()
        Fabric.with([Crashlytics.self])
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = getRootViewController()
//        window?.backgroundColor = UIColor.white
        window?.rootViewController = PasscodeViewController()
        window?.makeKeyAndVisible()
        return true
    }
    func setLaunchCount() {
        let launchCount = UserDefaults.standard.integer(forKey: kIsFirstLaunchKey)
        UserDefaults.standard.set(launchCount + 1, forKey: kIsFirstLaunchKey)
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
        searchNav.tabBarItem.image = #imageLiteral(resourceName: "SearchIcon")
        searchNav.navigationBar.tintColor = WDMainTheme
        return searchNav
    }
    func getSettingsViewController() -> UINavigationController {
        let settingsViewController = WDSettingsViewController()
        let nav = UINavigationController(rootViewController: settingsViewController)
        nav.navigationBar.isHidden = true
        nav.tabBarItem.title = "Settings"
        nav.tabBarItem.image = #imageLiteral(resourceName: "SettingsIcon")
        nav.navigationBar.tintColor = WDMainTheme
        return nav
    }
    func getWordListViewController() -> UINavigationController {
        let wordListViewController = WDWordListViewController()
        let nav = UINavigationController(rootViewController: wordListViewController)
        nav.navigationBar.isHidden = true
        nav.tabBarItem.title = "List"
        nav.tabBarItem.image = #imageLiteral(resourceName: "ListIcon")
        nav.navigationBar.tintColor = WDMainTheme
        return nav
    }
    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
    }
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
    }
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("get the deviceToken  \(deviceToken)")
        JPUSHService.registerDeviceToken(deviceToken)
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if blockRotation {
            return .allButUpsideDown
        }
        return .portrait
    }
}
