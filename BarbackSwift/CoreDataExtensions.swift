import CoreData
import Foundation
import UIKit

protocol NamedManagedObject {
    
    class func entityName() -> String
    
}

extension NSManagedObjectContext {
    
    func objects<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type, predicate:NSPredicate? = nil, sortDescriptors:[NSSortDescriptor]? = nil) -> [T]? {
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
    
    func randomObject<T:NSManagedObject where T:NamedManagedObject>(entity:T.Type) -> T? {
        let allObjects = objects(entity)?
        return allObjects?[Int(arc4random_uniform(UInt32(allObjects!.count)))]
    }
    
}

extension NSManagedObject : NamedManagedObject {
    class func entityName() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".")[1]
    }
}