 //
//  Brand.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import Foundation
import CoreData
import RealmSwift

public class Brand: Object {

    dynamic var name: String = ""
    dynamic var price: Float = 0.0
    dynamic var url: String = ""
    dynamic var base: IngredientBase?

    var detailDescription: String {
        get {
            return "$\(price)"
        }
    }

    public class func all(useLocal: Bool) -> [Brand] {
        do {
            return try Realm().objects(Brand).map({ $0 })
        } catch {
            print("\(error)")
            return []
        }
    }

    class func forName(name: String) -> Brand? {
        do {
            return try Realm().objects(Brand).filter("name = '\(name)'").first
        } catch {
            print("\(error)")
            return nil
        }
    }
}
