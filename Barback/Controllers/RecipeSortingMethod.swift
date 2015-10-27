import Foundation

enum RecipeSortingMethod: Int, SortingMethod {
    case ABVDescending = 0
    case ABVAscending
    case ComplexityDescending
    case ComplexityAscending
    case NameDescending
    case NameAscending
    
    typealias SortedObject = Recipe
    
    func title() -> String {
        return ["ABV", "Complexity", "Name"][rawValue / 2] + ["↓", "↑"][rawValue % 2]
    }
    
    func possibleMethods() -> [RecipeSortingMethod] {
        var rawValues: [Int]
        if (rawValue % 2 == 1) {
            rawValues = [0,2,4]
        } else if (rawValue == 0) {
            rawValues = [1,2,4]
        } else if (rawValue == 2) {
            rawValues = [0,3,4]
        } else {
            rawValues = [0,2,5]
        }
        return rawValues.map({RecipeSortingMethod(rawValue: $0)!})
    }
    
    func sortFunction() -> ((Recipe, Recipe) -> Bool) {
        switch self {
        case .ABVDescending:
            return ({ return $0.abv < $1.abv })
        case .ABVAscending:
            return ({ return $0.abv > $1.abv })
        case .ComplexityDescending:
            return ({ return $0.ingredients.count < $1.ingredients.count })
        case .ComplexityAscending:
            return ({ return $0.ingredients.count > $1.ingredients.count })
        case .NameDescending:
            return ({ return $0.name.lowercaseString < $1.name.lowercaseString })
        case .NameAscending:
            return ({ return $0.name.lowercaseString > $1.name.lowercaseString })
        }
    }
}
