import AdSupport
import Appirater
import CoreData
import CoreSpotlight
import JLRoutes
import MBProgressHUD
import MobileCoreServices
import RealmSwift
import SystemConfiguration
import UIKit

func initializeDependencies(launchOptions: NSDictionary?) {

    // Fabric.with([Crashlytics()])

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
                    pushRecipeDetailController(recipe)
                } else {
                    let ingredient = IngredientBase.forIndexableID(uniqueIdentifier)
                    pushIngredientDetailController(ingredient)
                }
                
                }
            }
        
        return true
        }

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

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerUserNotificationSettings(notificationSettings)
    }

        
    func pushRecipeDetailController(recipe: Recipe) {
        let controller = R.storyboard.main.recipeDetail!
        controller.setRecipeAs(recipe)
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        navController.pushViewController(controller, animated: true)
    }
    
    func pushIngredientDetailController(ingredient: IngredientBase) {
        let controller = R.storyboard.main.ingredientDetail!
        controller.ingredient = ingredient
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        navController.pushViewController(controller, animated: true)
    }

    func registerPushNotifications(application: UIApplication) {
        // Register for push notifications.
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        initializeRouting()
        initializeDependencies(launchOptions)
        registerPushNotifications(application)
        styleApp()
        
        let dataSource = RealmDataSource()
        if dataSource.needsSyncing() {
            dataSource.sync()
        }
        return true
    }
    
    func initializeRouting() {
        // Format of `barback://recipe/<RecipeName>`.
        JLRoutes.addRoute("/recipe/:name", handler:
            {
                (params: [NSObject: AnyObject]!) -> Bool in
                let recipe = Recipe.forName(params["name"] as! String)!
                self.pushRecipeDetailController(recipe)
                return true
        })
        // Format of `barback://recipe/<RecipeName>`.
        JLRoutes.addRoute("/ingredient/:name", handler:
            {
                (params: [NSObject: AnyObject]!) -> Bool in
                let base = IngredientBase.all().filter({ $0.name == (params["name"] as! String) }).first!
                self.pushIngredientDetailController(base)
                return true
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

