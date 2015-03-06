import CoreData
import Foundation
import UIKit

protocol NamedManagedObject {
    
    static func entityName() -> String
    
}

extension NSManagedObjectContext {
    
    func objects<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type, predicate:NSPredicate? = nil,
        sortDescriptors:[NSSortDescriptor]? = nil) -> [T]? {

        let request = NSFetchRequest(entityName: entity.entityName())
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        var error:NSError? = nil
        let results = self.executeFetchRequest(request, error: &error) as? [T]
        
        assert(error == nil)
        
        return results
    }
    
    func objectForName<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type, name: String) -> T? {
        let predicate = NSPredicate(format: "name LIKE[cd] \"\(name)\"")
        return objects(entity, predicate: predicate)?.first
    }
    
    func objectForObjectId<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type, objectId: String) -> T? {
        let predicate = NSPredicate(format: "objectId LIKE[cd] \"\(objectId)\"")
        return objects(entity, predicate: predicate)?.first
    }
    
    func objectForDictionary<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type, dictionary: [NSObject : AnyObject], checkForObject: Bool = true) -> T {
        var object: T
        if checkForObject {
            object = objectForObjectId(entity, objectId: dictionary["objectId"] as! String) ?? entity.newObject() as! T
        } else {
            object = entity.newObject() as! T
        }
        object.updateWithDictionary(dictionary)
        return object
    }
    
    func randomObject<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type) -> T? {
        let allObjects = objects(entity)
        return allObjects?[Int(arc4random_uniform(UInt32(allObjects!.count)))]
    }
    
}

extension NSManagedObject : NamedManagedObject {
    class func entityName() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".")[1].componentsSeparatedByString("_")[0]
    }
    
    class func attributes() -> [String] {
        let entity = NSEntityDescription.entityForName(entityName(), inManagedObjectContext: managedContext())!
        let attributes = entity.attributesByName as! [String: NSAttributeDescription]
        return Array(attributes.keys)
    }
    
    func updateWithDictionary(valuesForKeys: [NSObject : AnyObject]) {
        var objectValues: [String : AnyObject] = [:]
        for attribute: String in self.dynamicType.attributes() {
            let value: AnyObject? = valuesForKeys[attribute]
            if let value: AnyObject = value {
                objectValues[attribute] = value
            }
        }
        setValuesForKeysWithDictionary(objectValues)
    }
    
    class func newObject() -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName(), inManagedObjectContext: managedContext()) as! NSManagedObject
    }
}