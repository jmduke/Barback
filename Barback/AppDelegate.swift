import AdSupport
import Appirater
import CoreData
import CoreSpotlight
import Crashlytics
import Fabric
import JLRoutes
import MBProgressHUD
import MobileCoreServices
import RealmSwift
import SystemConfiguration
import UIKit

func initializeDependencies(launchOptions: NSDictionary?) {

    Fabric.with([Crashlytics()])

    // Initialize Appirater.
    Appirater.setAppId("829469529")
    Appirater.setDaysUntilPrompt(7)
    Appirater.setUsesUntilPrompt(5)
    Appirater.setSignificantEventsUntilPrompt(-1)
    Appirater.setTimeBeforeReminding(2)
    Appirater.setDebug(false)
    Appirater.appLaunched(true)
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var tabBarItems: [UITabBarItem] {
        get {
            let tabBarController = self.window?.rootViewController as! UITabBarController
            let tabBar = tabBarController.tabBar
            let items = tabBar.items!
            return items
        }
    }

    // Needed to access UITabBarIcons.
    var window: UIWindow?
    var controllerNavigator = ControllerNavigator() {
        didSet {
            controllerNavigator.application = self
        }
    }
    
    func application(
        application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return JLRoutes.routeURL(url)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let _ = uniqueIdentifier.rangeOfString("ecipe") {
                    let recipe = Recipe.forIndexableID(uniqueIdentifier)
                    controllerNavigator.pushRecipeDetailController(recipe)
                } else {
                    let ingredient = IngredientBase.forIndexableID(uniqueIdentifier)
                    controllerNavigator.pushIngredientDetailController(ingredient)
                }
                
            }
        }
        
        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let title = shortcutItem.localizedTitle
        let quickActionShortcut = QuickActionShortcut.fromTitle(title)
        quickActionShortcut.performQuickAction(self, shortcutItem: shortcutItem)
    }

    func registerPushNotifications(application: UIApplication) {
        // Register for push notifications.
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func registerQuickActions() {
        UIApplication.sharedApplication().shortcutItems = [
            QuickActionShortcut.AllFavorites.toShortcutItem(),
            QuickActionShortcut.MostRecentFavorite.toShortcutItem(),
            QuickActionShortcut.MostRecentSearch.toShortcutItem(),
            QuickActionShortcut.BartendersChoice.toShortcutItem()
        ]
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        initializeRouting()
        initializeDependencies(launchOptions)
        registerPushNotifications(application)
        styleApp()
        
        let dataSource = RealmDataSource()
        if dataSource.needsSyncing() || true {
            dataSource.sync()
        }
        
        // Register quick actions after syncing since it requires certain stuff to be present.
        registerQuickActions()
        
        return true
    }
    
    func initializeRouting() {
        URLRoute.all().map({
            JLRoutes.addRoute($0.url, handler: $0.handler)
        })
    }

    func styleApp() {
        // Set status bar to active.  And white.
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        if !runningOnIPad() {
            // Set font of tab bar items.
            var tabBarAttributes = [String : AnyObject]()
            tabBarAttributes[NSFontAttributeName] = UIFont(name: UIFont.primaryFont(), size: 10)
            UITabBarItem.appearance().setTitleTextAttributes(tabBarAttributes, forState: UIControlState.Normal)
            
            let imageColor = Color.Light.toUIColor()
            
            if tabBarItems.count > 3 {
                tabBarItems[0].image = BezierImage.Glass.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[1].image = BezierImage.Search.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[2].image = BezierImage.Favorited.path().toImageWithStrokeColor(imageColor, fillColor: nil)
                tabBarItems[3].image = BezierImage.Random.path().toImageWithStrokeColor(imageColor, fillColor: nil)
            }
        }
    }

}

