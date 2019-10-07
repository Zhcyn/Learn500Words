import UIKit
import WebKit
class WDWebViewController: UIViewController,WDNavigationHeaderDelegate {
    let webView = WKWebView()
    let headerView = WDNavigationHeader()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(topColor: Colors.backgroundGradientTop, bottomColor: Colors.backgroundGradientBottom)
        if let backTitle = self.navigationController?.navigationBar.items?.last?.title {
            headerView.setBackButton(title: backTitle)
        }
        else {
            headerView.setBackButton(title: "Back")
        }
        headerView.delegate = self
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant:kStatusBarHeight),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: kNavigationBarHeight)
            ])
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.maximumZoomScale = 1
        webView.scrollView.minimumZoomScale = 1
        view.addSubview(webView)
        var bottomPadding = kDefaultPadding
        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            bottomPadding += tabBarHeight
        }
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:kSidePadding),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-kSidePadding),
            webView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant:kDefaultPadding),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-bottomPadding)
            ])
        if let urlString = Bundle.main.path(forResource: "licences", ofType: "html"), let _ = URL(string:urlString) {
            do {
                let htmlString = try NSString(contentsOfFile: urlString, encoding: String.Encoding.utf8.rawValue)
                webView.loadHTMLString(htmlString as String, baseURL: nil)
            }
            catch {
                print("Invalid HTML")
            }
        }
    }
    func didTapBackButton() {
         self.navigationController?.popViewController(animated: true)
    }
}
