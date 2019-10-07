import Foundation
import UIKit
enum WDHelpers {
    static var tabBarHeight:CGFloat {
        let tabBarHeight = ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UITabBarController)?.tabBar.frame.height ?? 0.0
        return tabBarHeight
    }
    static var mainTabBarController:UITabBarController? {
        return ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UITabBarController)
    }
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    static func showInternetErrorDropdown() {
        WDNotificationDropdownView.showWith(message: "Something seems to have gone wrong :(")
    }
    static func isFirstLaunch() -> Bool {
        return UserDefaults.standard.integer(forKey: kIsFirstLaunchKey) == 1
    }
}
extension UIViewController {
    func isCurrentActiveTabController() -> Bool {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate), let tabBarController = appDelegate.window?.rootViewController as? UITabBarController else {
            return false
        }
        var activeVC:UIViewController? = nil
        if let navVC = tabBarController.selectedViewController as? UINavigationController {
            activeVC = navVC.topViewController
        }
        else {
            activeVC = tabBarController.selectedViewController
        }
        if let activeVC = activeVC {
            if self === activeVC {
                return true
            }
        }
        return false
    }
}
extension String {
    func convertHtmlSymbols() throws -> String? {
        guard let data = data(using: .utf8) else { return nil }
        return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
    }
}
