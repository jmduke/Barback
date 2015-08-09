//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import RealmSwift

public final class IngredientBase: Object, SpotlightIndexable {

    public dynamic var information: String = ""
    public dynamic var name: String = ""
    dynamic var slug: String = ""
    dynamic var cocktaildb: String = ""
    public dynamic var abv: Double = 0.0
    dynamic var color: String = ""
    
    // Need to do it because of https://github.com/realm/realm-cocoa/issues/921.
    dynamic var type: String = ""
    var ingredientType: IngredientType {
        get {
            guard let parsedType = IngredientType(rawValue: self.type) else { return .Other }
            return parsedType
        }
    }

    public var uses: [Ingredient] {
        return linkingObjects(Ingredient.self, forProperty: "base")
    }

    var uiColor: UIColor {
        get {
            return UIColor.fromHex(color)
        }
    }

    public dynamic var brands = List<Brand>()
    
    public var sortedBrands: [Brand] {
        return brands.sorted("price").map({ $0 })
    }

    public class func all() -> [IngredientBase] {
        do {
            return try Realm().objects(IngredientBase).map({ $0 })
        } catch {
            print("\(error)")
            return []
        }
    }


    class func forName(name: String) -> IngredientBase? {
        do {
            return try Realm().objects(IngredientBase).filter("name = '\(name)'").map({ $0 }).first
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    class func forIndexableID(indexableID: String) -> IngredientBase {
        return forName(getUniqueIDFromIndexableID(indexableID))!
    }
    
    func uniqueID() -> String {
        return name
    }
}
