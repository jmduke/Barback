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
        func sortByName(isDescending: Bool) -> ((IngredientBase, two: IngredientBase) -> Bool) {
            func ascending(one: IngredientBase, two: IngredientBase) -> Bool { return one.name < two.name }
            func descending(one: IngredientBase, two: IngredientBase) -> Bool { return one.name > two.name }
            return (isDescending ? descending : ascending)
        }
        func sortByRecipeUsage(isDescending: Bool) -> ((IngredientBase, two: IngredientBase) -> Bool) {
            func ascending(one: IngredientBase, two: IngredientBase) -> Bool { return one.uses.count < two.uses.count }
            func descending(one: IngredientBase, two: IngredientBase) -> Bool { return one.uses.count > two.uses.count }
            return (isDescending ? descending : ascending)
        }
        func sortByColor(isDescending: Bool) -> ((IngredientBase, two: IngredientBase) -> Bool) {
            func ascending(one: IngredientBase, two: IngredientBase) -> Bool {
                var oneHue: CGFloat = 0
                var twoHue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                one.uiColor.getHue(&oneHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                two.uiColor.getHue(&twoHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return oneHue < twoHue
            }
            func descending(one: IngredientBase, two: IngredientBase) -> Bool {
                var oneHue: CGFloat = 0
                var twoHue: CGFloat = 0
                var saturation: CGFloat = 0
                var brightness: CGFloat = 0
                var alpha: CGFloat = 0
                one.uiColor.getHue(&oneHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                two.uiColor.getHue(&twoHue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
                return oneHue > twoHue
            }
            return (isDescending ? descending : ascending)
        }
        
        switch self {
        case .NameDescending:
            return sortByName(true)
        case .NameAscending:
            return sortByName(false)
        case .RecipeUsageDescending:
            return sortByRecipeUsage(true)
        case .RecipeUsageAscending:
            return sortByRecipeUsage(false)
        case .ColorDescending:
            return sortByColor(true)
        case .ColorAscending:
            return sortByColor(false)
        }
    }
}