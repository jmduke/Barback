public enum Flavor: String {
    case Sweet
    case Smoky
    case Crisp
    
    static func all() -> [Flavor] {
        return [.Sweet, .Smoky, .Crisp]
    }
    
    public func describesRecipe(recipe: Recipe) -> Bool {
        switch self {
        case .Sweet:
            return recipe.ingredients.map({ $0.base }).filter({ $0 != nil }).filter({ $0!.name.rangeOfString("juice") != nil }).count > 0
        case .Smoky:
            return false
        case .Crisp:
            return false
        }
    }
}