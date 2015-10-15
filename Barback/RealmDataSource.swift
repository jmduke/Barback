import CoreSpotlight
import Foundation
import MobileCoreServices
import RealmSwift

struct RealmDataSource {
    
    func needsSyncing() -> Bool {
        return isFirstTimeAppLaunched()
    }
    
    func sync() {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.deleteAll()
                }
                
                let baseFilepath = NSBundle.mainBundle().pathForResource("bases", ofType: "json")!
                let baseData = try NSData(contentsOfFile: baseFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
                let baseDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(baseData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
                try realm.write {
                    for object in baseDict {
                        let rawBase = NSMutableDictionary(dictionary: object)
                        let base = IngredientBase(value: rawBase)
                        realm.add(base)
                        
                        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                        
                        attributeSet.title = base.name
                        attributeSet.contentDescription = base.information
                        
                        let view = IngredientDiagramView(frame: CGRectMake(0, 0, 50, 50),ingredient: base)
                        UIGraphicsBeginImageContext(view.frame.size)
                        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                        let recipeImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        let imageData = NSData(data: UIImagePNGRepresentation(recipeImage)!)
                        attributeSet.thumbnailData = imageData
                        
                        let item = CSSearchableItem(uniqueIdentifier: base.indexableID(), domainIdentifier: "com.jmduke.Barback", attributeSet: attributeSet)
                        item.expirationDate = NSDate.distantFuture()
                        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                            if let error = error {
                                print("Indexing error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                
                let recipeFilepath = NSBundle.mainBundle().pathForResource("recipes", ofType: "json")!
                let recipeData = try NSData(contentsOfFile: recipeFilepath, options: NSDataReadingOptions.DataReadingMappedAlways)
                let recipeDict: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(recipeData, options: NSJSONReadingOptions.AllowFragments) as! [NSDictionary]
                try realm.write {
                    for object in recipeDict {
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
                        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                        
                        attributeSet.title = recipe.name
                        attributeSet.contentDescription = recipe.name + ": " + recipe.information
                        
                        let view = RecipeDiagramView(recipe: recipe)
                        view.diagramScale = 0.5
                        UIGraphicsBeginImageContext(view.frame.size)
                        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                        let recipeImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        let imageData = NSData(data: UIImagePNGRepresentation(recipeImage)!)
                        attributeSet.thumbnailData = imageData
                        
                        
                        let item = CSSearchableItem(uniqueIdentifier: recipe.indexableID(), domainIdentifier: "com.jmduke.Barback", attributeSet: attributeSet)
                        item.expirationDate = NSDate.distantFuture()
                        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                            if let error = error {
                                print("Indexing error: \(error.localizedDescription)")
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error info: \(error)")
            }
        setFirstTimeAppLaunched()
    }
}