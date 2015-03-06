import Foundation
import Parse

// NSUserDefault keys.
let launchedOnceKey = "launchedOnce"
let syncedThisLaunchKey = "syncedThisLaunch"
let dataVersionKey = "dataVersion"
let syncDateKey = "syncDate"
let appVersionKey = "appVersion"
let currentAppVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String

func isFirstTimeAppLaunched() -> Bool {
    return !NSUserDefaults.standardUserDefaults().boolForKey(launchedOnceKey)
}

func isAppSyncedThisLaunch() -> Bool {
    return !NSUserDefaults.standardUserDefaults().boolForKey(syncedThisLaunchKey)
}

func isNewVersionOfApp() -> Bool {
    return !(NSUserDefaults.standardUserDefaults().stringForKey(appVersionKey) == currentAppVersion)
}

func getLatestDataVersion() -> Int {
    return NSUserDefaults.standardUserDefaults().integerForKey(dataVersionKey)
}

func updateVersionOfApp() {
    NSUserDefaults.standardUserDefaults().setObject(currentAppVersion, forKey: appVersionKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}

func setFirstTimeAppLaunched() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: launchedOnceKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}

func setAppSyncedThisLaunch() {
    NSUserDefaults.standardUserDefaults().setBool(true, forKey:syncedThisLaunchKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}

func setLatestDataVersion(dataVersion: Int) {
    NSUserDefaults.standardUserDefaults().setInteger(dataVersion, forKey: dataVersionKey)
    NSUserDefaults.standardUserDefaults().synchronize()
}

func setLatestSyncDate(date: NSDate) {
    let dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    NSUserDefaults.standardUserDefaults().setObject(dateString, forKey:syncDateKey)
    NSUserDefaults.standardUserDefaults().synchronize()
    
}

func dataNeedsSyncing() -> Bool {
    let config = PFConfig.getConfig()
    let dataVersion = config.objectForKey(dataVersionKey) as! Int
    return dataVersion > getLatestDataVersion()
    return false
}

func syncNewData() {
    let ingredientBases = IngredientBase.syncWithParse()
    saveContext()
    let recipes = Recipe.syncWithParse()
    saveContext()
    let ingredients = Ingredient.syncWithParse()
    saveContext()
    let brands = Brand.syncWithParse()
    saveContext()
    
    let latestDataVersion = PFConfig.getConfig().objectForKey(dataVersionKey) as! Int
    setLatestDataVersion(latestDataVersion)
    setLatestSyncDate(NSDate())
}

func syncDataFromJSON() {
    let ingredients = IngredientBase.syncWithJSON()
    let recipes = Recipe.syncWithJSON()
    
    let latestDataVersion = 0
    setLatestDataVersion(latestDataVersion)
    setLatestSyncDate(NSDate())
}

func markAppAsLaunched() {
    setFirstTimeAppLaunched()
    setAppSyncedThisLaunch()
}
