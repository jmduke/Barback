import Foundation

enum IngredientBaseSortingMethod: Int, SortingMethod {
    case NameDescending = 0
    case NameAscending
    case RecipeUsageDescending
    case RecipeUsageAscending
    case ColorDescending
    case ColorAscending
    
    typealias SortedObject = IngredientBase
    
    func title() -> String {
        return ["Name", "# of Recipes", "Color"][rawValue / 2] + ["↓", "↑"][rawValue % 2]
    }
    
    func possibleMethods() -> [IngredientBaseSortingMethod] {
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
        return rawValues.map({IngredientBaseSortingMethod(rawValue: $0)!})
    }
    
    func sortFunction() -> ((IngredientBase, IngredientBase) -> Bool) {
        switch self {
        case .NameDescending:
            return ({ return $0.name.lowercaseString < $1.name.lowercaseString })
        case .NameAscending:
            return ({ return $0.name.lowercaseString > $1.name.lowercaseString })
        case .RecipeUsageDescending:
            return ({ return $0.uses.count < $1.uses.count })
        case .RecipeUsageAscending:
            return ({ return $0.uses.count > $1.uses.count })
        case .ColorDescending:
            return ({
                var oneHue: CGFloat = 0
                var twoHue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                $0.uiColor.getHue(&oneHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                $1.uiColor.getHue(&twoHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return oneHue < twoHue
            })
        case .ColorAscending:
            return ({
                var oneHue: CGFloat = 0
                var twoHue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                $0.uiColor.getHue(&oneHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                $1.uiColor.getHue(&twoHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return oneHue > twoHue
            })
        }
    }
}