public enum Adjective: String {
    case Bold = "Bold"
    case Daring = "Daring"
    case Quiet = "Quiet"
    case Silly = "Silly"
    case Thirsty = "Thirsty"
    
    public func describesRecipe(recipe: Recipe) -> Bool {
        switch self {
            case .Bold:
                return recipe.abv > 20
            case .Daring:
                return recipe.ingredients.filter({
                    (i: Ingredient) -> Bool in
                    Ingredient.all().filter({ $0.base == i }).count < 3
                }).count > 0
            case .Silly:
                return recipe.ingredients.count > 3
            case .Quiet:
                return recipe.ingredients.filter({
                    $0.base!.name.rangeOfString("Lemon juice") != nil ||
                    $0.base!.name.rangeOfString("Lime juice") != nil
                }).count > 0
            case .Thirsty:
                return recipe.glassware == "highball"
        }
    }
    
    static func all() -> [Adjective] {
        return [.Bold, .Daring, .Silly, .Thirsty, .Quiet]
    }
    
    public var description : String {
        switch self {
        case .Bold: return "Bold";
        case .Daring: return "Daring";
        case .Quiet: return "Quiet";
        case .Thirsty: return "Thirsty";
        case .Silly: return "Silly";
        }
    }
}