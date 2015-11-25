import Foundation
import SafariServices
import UIKit

extension UIViewController {

    func styleController() {
        navigationController?.styleController()

        tabBarController?.tabBar.translucent = false
        tabBarController?.tabBar.barTintColor = Color.Dark.toUIColor()
        tabBarController?.tabBar.tintColor = Color.Tint.toUIColor()

        view.backgroundColor = Color.Dark.toUIColor()
    }

}

extension UIViewController {
    func openUrl(url: NSURL) {
        let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        if (self as? SFSafariViewControllerDelegate) != nil {
            vc.delegate = self as? SFSafariViewControllerDelegate
            navigationController!.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

extension UINavigationController {
    override func styleController() {
        navigationBar.translucent = false
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = Color.Dark.toUIColor()
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline)
            .pointSize, 20)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: fontSize as CGFloat)!]
        let buttonFontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleCaption1)
            .pointSize, 16)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: UIFont.primaryFont(), size: buttonFontSize)!], forState: UIControlState.Normal)
    }
}