import Foundation

protocol SpotlightIndexable {
    
    func uniqueID() -> String
    func indexableID() -> String
    static func forIndexableID(indexableID: String) -> Self
    
}

extension SpotlightIndexable {
    
    func indexableIDDelimiter() -> String {
        return  "."
    }
    
    func indexableID() -> String {
        return "\(self.dynamicType)" + indexableIDDelimiter() + uniqueID()
    }
    
    static func getUniqueIDFromIndexableID(indexableId: String) -> String {
        return indexableId.componentsSeparatedByString(".").last!
    }
}