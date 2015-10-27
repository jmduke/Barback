//
//  IngredientBase.swift
//  
//
//  Created by Justin Duke on 10/6/14.
//
//

import CoreData
import CoreSpotlight
import Foundation
import MobileCoreServices
import RealmSwift

public final class IngredientBase: Object, SpotlightIndexable, Equatable {

    public dynamic var information: String = ""
    public dynamic var name: String = ""
    dynamic var slug: String = ""
    dynamic var cocktaildb: String = ""
    public dynamic var abv: Double = 0.0
    dynamic var color: String = ""
    public dynamic var emoji: String = ""
    
    // Need to do it because of https://github.com/realm/realm-cocoa/issues/921.
    dynamic var type: String = ""
    public var ingredientType: IngredientType {
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

    public var brands = List<Brand>()
    
    public var sortedBrands: [Brand] {
        return brands.sorted("price").map({ $0 })
    }

    public class func all() -> [IngredientBase] {
        return (try? Realm().objects(IngredientBase).map({ $0 })) ?? []
    }


    class public func forName(name: String) -> IngredientBase? {
        let queryString = "name = \"\(name)\""
        return ((try? Realm().objects(IngredientBase).filter(queryString).map({ $0 })) ?? []).first
    }
    
    class func forIndexableID(indexableID: String) -> IngredientBase {
        return forName(getUniqueIDFromIndexableID(indexableID))!
    }
    
    func uniqueID() -> String {
        return name
    }
    
    func toAttributeSet() -> CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeSet.title = name
        attributeSet.contentDescription = information
        
        let view = IngredientDiagramView(frame: CGRectMake(0, 0, 50, 50),ingredient: self)
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let recipeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = NSData(data: UIImagePNGRepresentation(recipeImage)!)
        attributeSet.thumbnailData = imageData
        return attributeSet
    }
}

public func ==(lhs: IngredientBase, rhs: IngredientBase) -> Bool {
    return lhs.name == rhs.name
}
