import Foundation

protocol SortingMethod {
    typealias SortedObject
    
    func title() -> String
    func sortFunction() -> ((SortedObject, SortedObject) -> Bool)
}