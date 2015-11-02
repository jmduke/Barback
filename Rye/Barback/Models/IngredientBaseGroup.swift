import Foundation

public enum IngredientBaseGroup: String {
    case Whiskey = "Whiskey"
    case Vodka = "Vodka"
    case Gin = "Gin"
    case Tequila = "Tequila"
    
    var bases: [IngredientBase] {
        switch self {
        case .Whiskey:
            return [
                IngredientBase.forName("Whiskey")!,
                IngredientBase.forName("Rye")!,
                IngredientBase.forName("Bourbon")!,
                IngredientBase.forName("Scotch")!,
            ]
        case .Vodka:
            return [
                IngredientBase.forName("Vodka")!
            ]
        case .Gin:
            return [
                IngredientBase.forName("Gin")!,
                IngredientBase.forName("Sloe Gin")!,
            ]
        case .Tequila:
            return [
                IngredientBase.forName("Tequila")!,
                IngredientBase.forName("Mezcal")!,
            ]
        }
    }
    
    public var recipes: [Recipe] {
        var recipes = [Recipe]()
        for base in bases {
            recipes.appendContentsOf(base.uses.map({ $0.recipe! }))
        }
        return recipes
    }
    
    static public func all() -> [IngredientBaseGroup] {
        return [.Whiskey, .Vodka, .Gin, .Tequila]
    }
}