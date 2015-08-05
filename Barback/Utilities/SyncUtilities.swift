import Foundation


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
    return NSUserDefaults.standardUserDefaults().boolForKey(syncedThisLaunchKey)
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

func dataNeedsSyncing() -> Bool {
    return false
}

func markAppAsLaunched() {
    setFirstTimeAppLaunched()
    setAppSyncedThisLaunch()
}
