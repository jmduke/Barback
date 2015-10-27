import CoreSpotlight
import Foundation
import MobileCoreServices
import RealmSwift

struct RealmDataSource {
    
    func needsSyncing() -> Bool {
        return isFirstTimeAppLaunched()
    }
    
    func deleteAllData(realm: Realm) throws {
        try realm.write {
            realm.deleteAll()
        }
    }
    
    func deserializeJSONFile(filename: String) throws -> [NSDictionary] {
        let filepath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")!
        let rawData = try NSData(contentsOfFile: filepath, options: NSDataReadingOptions.DataReadingMappedAlways)
        let rawDictionaries: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(rawData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
        return rawDictionaries
    }
    
    func indexItem(item: SpotlightIndexable) {
        let item = CSSearchableItem(uniqueIdentifier: item.indexableID(), domainIdentifier: "com.jmduke.Barback", attributeSet: item.toAttributeSet())
        item.expirationDate = NSDate.distantFuture()
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }
    }
    
    func syncIngredients(realm: Realm) throws {
        let deserializedBases = try deserializeJSONFile("bases")
        try realm.write {
            for object in deserializedBases {
                let rawBase = NSMutableDictionary(dictionary: object)
                let base = IngredientBase(value: rawBase)
                realm.add(base)
                self.indexItem(base)
            }
        }
    }
    
    func syncRecipes(realm: Realm) throws {
        let deserializedRecipes = try deserializeJSONFile("recipes")
        try realm.write {
            for object in deserializedRecipes {
                let recipe = Recipe(value: object)
                realm.add(recipe)
                for ingredient: Ingredient in recipe.ingredients {
                    ingredient.base = IngredientBase.forName(ingredient.baseName)
                    if (ingredient.base == nil) {
                        ingredient.base = IngredientBase(value: ["name": ingredient.baseName])
                    }
                    ingredient.recipe = recipe
                    realm.add(ingredient)
                }
                self.indexItem(recipe)
            }
        }
    }
    
    func sync() {
        do {
            let realm = try Realm()
            try deleteAllData(realm)
            try syncIngredients(realm)
            try syncRecipes(realm)
        } catch {
            print("Error info: \(error)")
        }
        setFirstTimeAppLaunched()
    }
}