import AdSupport
import Appirater
import CoreData
import CoreSpotlight
// import Crashlytics
// import Fabric
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

        // Format of `barback://recipe/<RecipeName>`.
        if (url.host?.lowercaseString == "recipe") {
            let recipeName = url.path?.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
            if let recipeName = recipeName {
                    let recipe = Recipe.forName(recipeName)
                    let storyboard = R.storyboard.main.instance
                    let controller: RecipeDetailViewController = storyboard.instantiateViewControllerWithIdentifier("recipeDetail") as! RecipeDetailViewController
                    controller.setRecipeAs(recipe)

                    let tabBarController = self.window?.rootViewController as! UITabBarController
                let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
                    navController.pushViewController(controller, animated: true)
            }
        }


        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                
                if let _ = uniqueIdentifier.rangeOfString("ecipe") {
                    let recipe = Recipe.forIndexableID(uniqueIdentifier)
                    let storyboard = R.storyboard.main.instance
                    let controller: RecipeDetailViewController = storyboard.instantiateViewControllerWithIdentifier("recipeDetail") as! RecipeDetailViewController
                    controller.setRecipeAs(recipe)
                    
                    let tabBarController = self.window?.rootViewController as! UITabBarController
                    let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
                    navController.pushViewController(controller, animated: true)
                } else {
                    let ingredient = IngredientBase.forIndexableID(uniqueIdentifier)
                    let storyboard = R.storyboard.main.instance
                    let controller: IngredientDetailViewController = storyboard.instantiateViewControllerWithIdentifier("ingredientDetail") as! IngredientDetailViewController
                    controller.ingredient = ingredient
                    
                    let tabBarController = self.window?.rootViewController as! UITabBarController
                    let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
                    navController.pushViewController(controller, animated: true)
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

    func syncData() {
        do {
            let realm = try Realm()
            realm.write {
                realm.deleteAll()
            }
            
            let baseFilepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")!
            let baseData = try NSData(contentsOfFile: baseFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
            let baseDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(baseData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
            realm.write {
                for object in baseDict {
                    let rawBase = NSMutableDictionary(dictionary: object)
                    let base = IngredientBase(value: rawBase)
                    realm.add(base)
                    
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                    
                    attributeSet.title = base.name
                    attributeSet.contentDescription = base.name + ": " + base.information
                    let item = CSSearchableItem(uniqueIdentifier: base.indexableID(), domainIdentifier: "com.jmduke.Barback", attributeSet: attributeSet)
                    item.expirationDate = NSDate.distantFuture()
                    CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                        if let error = error {
                            print("Indexing error: \(error.localizedDescription)")
                        } else {
                            print("Search item successfully indexed!")
                        }
                    }
                }
            }
            
            let recipeFilepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")!
            let recipeData = try NSData(contentsOfFile: recipeFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
            let recipeDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(recipeData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
            realm.write {
                for object in recipeDict {
                    let recipe = Recipe(value: object)
                    realm.add(recipe)
                    for ingredient: Ingredient in recipe.ingredients {
                        ingredient.base = realm.objects(IngredientBase).filter("name = \"\(ingredient.baseName)\"").first
                        if (ingredient.base == nil) {
                            ingredient.base = IngredientBase(value: ["name": ingredient.baseName])
                        }
                        ingredient.recipe = recipe
                        realm.add(ingredient)
                    }
                    let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                    
                    attributeSet.title = recipe.name
                    attributeSet.contentDescription = recipe.name + ": " + recipe.information
                    let item = CSSearchableItem(uniqueIdentifier: recipe.indexableID(), domainIdentifier: "com.jmduke.Barback", attributeSet: attributeSet)
                    item.expirationDate = NSDate.distantFuture()
                    CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                        if let error = error {
                            print("Indexing error: \(error.localizedDescription)")
                        } else {
                            print("Search item successfully indexed!")
                        }
                    }

                }
            }
        } catch {
            print("Error info: \(error)")
        }
    }

    func registerPushNotifications(application: UIApplication) {
        // Register for push notifications.
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        initializeDependencies(launchOptions)
        registerPushNotifications(application)
        styleApp()
        syncData()
        return true
    }

    func enableAppInteraction() {
        if !runningOnIPad() {
            for tabBarItem in tabBarItems {
                tabBarItem.enabled = true
            }
        }
    }

    func disableAppInteraction() {
        if !runningOnIPad() {
            for tabBarItem in tabBarItems {
                tabBarItem.enabled = false
            }
        }
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

