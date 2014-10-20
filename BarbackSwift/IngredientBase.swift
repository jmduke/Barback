//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData

class IngredientBase: NSManagedObject {

    @NSManaged var information: String
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var brands: NSSet
    @NSManaged var uses: NSSet
    
    var lowercaseName: String {
        return name.lowercaseString
    }

    class func forName(name: String) -> IngredientBase? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let request = NSFetchRequest(entityName: "IngredientBase")
        request.predicate = NSPredicate(format: "name == \"\(name)\"")
        
        let result = delegate.coreDataHelper.managedObjectContext!.executeFetchRequest(request, error: nil)
        return result?.first as? IngredientBase
    }
    
    class func fromAttributes(name: String, information: String, type: IngredientType, context: NSManagedObjectContext) -> IngredientBase {
        let newBase: IngredientBase = NSEntityDescription.insertNewObjectForEntityForName("IngredientBase", inManagedObjectContext: context) as IngredientBase
        newBase.name = name
        newBase.information = information
        newBase.type = type.toRaw()
        return newBase
    }
    
    class func fromDict(rawIngredient: NSDictionary, context: NSManagedObjectContext) -> IngredientBase {
        let name = (rawIngredient.objectForKey("name") as String)
        let description = rawIngredient.objectForKey("description") as String
        let type = IngredientType.fromRaw(rawIngredient.objectForKey("type") as String)!
        let rawBrands = rawIngredient.objectForKey("brands") as [NSDictionary]
        
        let base = fromAttributes(name, information: description, type: type, context: context)
        let newBrands = base.mutableSetValueForKey("brands")
        
        let brands = rawBrands.map({
            (rawBrand: NSDictionary) -> Brand in
            let brand = Brand.fromDict(rawBrand, context: context)
            newBrands.addObject(brand)
            return brand
        })
        return base
    }
    
    class func fromJSONFile(context: NSManagedObjectContext) -> [IngredientBase] {
        let filepath = NSBundle.mainBundle().pathForResource("ingredients", ofType: "json")
        let jsonData = NSString.stringWithContentsOfFile(filepath!, encoding:NSUTF8StringEncoding, error: nil)
        let ingredientData = jsonData.dataUsingEncoding(NSUTF8StringEncoding)
        var rawIngredients = NSJSONSerialization.JSONObjectWithData(ingredientData!, options: nil, error: nil) as [NSDictionary]
        
        return rawIngredients.map({IngredientBase.fromDict($0, context: context)})
    }
}
