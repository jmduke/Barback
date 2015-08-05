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

public class IngredientBase: Object {

    public dynamic var information: String = ""
    public dynamic var name: String = ""
    dynamic var slug: String = ""
    dynamic var type: String = ""
    dynamic var cocktaildb: String = ""
    public dynamic var abv: Double = 0.0
    dynamic var color: String = ""

    public func uses() -> [Ingredient] {
        return Ingredient.all().filter({ $0.base == self })
    }

    var uiColor: UIColor {
        get {
            return UIColor.fromHex(color)
        }
    }

    public dynamic var brands = List<Brand>()

    public class func parseClassName() -> String {
        return "IngredientBase"
    }

    public class func all() -> [IngredientBase] {
        do {
            return try Realm().objects(IngredientBase).map({ $0 })
        } catch {
            print("\(error)")
            return []
        }
    }

    class func nameContainsString(string: String) -> [IngredientBase] {
        do {
            return try Realm().objects(IngredientBase).filter("name contains '\(string)'").map({ $0 })
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
}
