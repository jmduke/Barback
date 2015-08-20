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
            return [
                "Astor Hotel Special",
                "Painkiller",
                "Bocce Ball",
                "Moscow Mule",
                "Margarita",
                "Mint Julep",
                "Mojito",
                "Planter's Punch",
                "Sex on the Beach"
                ].contains(recipe.name)
        case .Smoky:
            return [
                "Angostura Sour",
                "Manhattan",
                "Flannel Shirt",
                "Mark Twain",
                "Old Fashioned",
                "Penicillin",
                "Rob Roy",
                "The Second Year"
                ].contains(recipe.name)
        case .Crisp:
            return [
                "Dry Martini",
                "Melon Stand",
                "Obituary",
                "Paloma",
                "Samsara",
                "Sazerac",
                "Smith & Kearns"
                ].contains(recipe.name)
        }
    }
}