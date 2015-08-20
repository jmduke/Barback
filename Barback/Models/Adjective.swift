public enum Adjective: CustomStringConvertible {
    case Bold
    case Bubbly
    case Ecstatic
    case Pensive
    case Thirsty
    case Weird
    
    public func describesRecipe(recipe: Recipe) -> Bool {
        switch self {
            case .Bold:
                return recipe.abv > 20
            case .Bubbly:
                return recipe.ingredients.filter({
                    $0.base!.name.rangeOfString("soda") != nil ||
                    $0.base!.name.rangeOfString("ale") != nil ||
                    $0.base!.name.rangeOfString("tonic") != nil
                }).count > 0
            case .Weird:
                return recipe.ingredients.filter({
                    (i: Ingredient) -> Bool in
                    Ingredient.all().filter({ $0.base == i }).count < 3
                }).count > 0
            case .Ecstatic:
                return recipe.abv > 30
            case .Pensive:
                return recipe.ingredients.filter({
                    $0.base!.name.rangeOfString("Lemon juice") != nil ||
                    $0.base!.name.rangeOfString("Lime juice") != nil
                }).count > 0
            case .Thirsty:
                return recipe.glassware == "highball"
        }
    }
    
    static func all() -> [Adjective] {
        return [.Bold, .Bubbly, .Ecstatic, .Pensive, .Thirsty, .Weird]
    }
    
    public var description : String {
        switch self {
        case .Bold: return "Bold";
        case .Bubbly: return "Bubbly";
        case .Ecstatic: return "Mighty";
        case .Thirsty: return "Thirsty";
        case .Pensive: return "Pensive";
        case .Weird: return "Weird";
        }
    }
}