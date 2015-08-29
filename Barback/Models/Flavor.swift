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
                "Brandy Crusta",
                "Daiquiri",
                "Painkiller",
                "Pina Colada",
                "Bocce Ball",
                "Moscow Mule",
                "Margarita",
                "Mai-tai",
                "Mint Julep",
                "Mojito",
                "Planter's Punch",
                "Sex on the Beach"
                ].contains(recipe.name)
        case .Smoky:
            return [
                "Angostura Sour",
                "Decolletage",
                "Manhattan",
                "Flannel Shirt",
                "Mark Twain",
                "Old Fashioned",
                "Old Smoke",
                "Penicillin",
                "Rob Roy",
                "Diamondback",
                "The Second Year",
                "Samsara"
                ].contains(recipe.name)
        case .Crisp:
            return [
                "Champagne Cocktail",
                "Dry Martini",
                "John Collins",
                "Americano",
                "Melon Stand",
                "Obituary",
                "Paloma",
                "Samsara",
                "Vesper",
                "Sazerac",
                "Smith & Kearns"
                ].contains(recipe.name)
        }
    }
}