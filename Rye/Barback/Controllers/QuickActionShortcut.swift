import Foundation

extension Array {
    func random() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

enum QuickActionShortcut {
    case AllFavorites
    case MostRecentFavorite
    case MostRecentSearch
    case BartendersChoice
    
    func title() -> String {
        switch self {
        case .AllFavorites:
            return "Favorites"
        case .MostRecentFavorite:
            let recipeName = getMostRecentRecipeFavorited() ?? "Manhattan"
            return "View '\(recipeName)'"
        case .MostRecentSearch:
            let mostRecentSearchQuery = getMostRecentSearch() ?? "Smoky"
            return "Search for '\(mostRecentSearchQuery)'"
        case .BartendersChoice:
            return "Recommend a drink"
        }
    }
    
    func performQuickAction(application: AppDelegate, shortcutItem: UIApplicationShortcutItem) {
        switch self {
        case .AllFavorites:
            application.controllerNavigator.pushFavoriteListViewController()
        case .MostRecentFavorite:
            let recipeName = getMostRecentRecipeFavorited() ?? "Manhattan"
            let recipe = Recipe.forName(recipeName)
            application.controllerNavigator.pushRecipeDetailController(recipe!)
        case .MostRecentSearch:
            let mostRecentSearchQuery = getMostRecentSearch() ?? "Smoky"
            application.controllerNavigator.pushRecipeListViewController(mostRecentSearchQuery)
        case .BartendersChoice:
            let encodedWizardData = shortcutItem.localizedSubtitle!.stringByReplacingOccurrencesOfString(" ", withString: "").componentsSeparatedByString("+")
            let baseGroup = IngredientBaseGroup(rawValue: encodedWizardData[0])!
            let flavor = Flavor(rawValue: encodedWizardData[1])!
            let adjective = Adjective(rawValue: encodedWizardData[2])!
            application.controllerNavigator.pushPrefilledWizardViewController(baseGroup, flavor: flavor, adjective: adjective)
        }
    }
    
    static func fromTitle(title: String) -> QuickActionShortcut {
        if (title.rangeOfString("Favorites") != nil) {
            return .AllFavorites
        } else if (title.rangeOfString("View") != nil) {
            return .MostRecentFavorite
        } else if (title.rangeOfString("Search for") != nil) {
            return .MostRecentSearch
        } else {
            return .BartendersChoice
        }
    }
    
    func subtitle() -> String {
        switch self {
        case .AllFavorites:
            let favoriteRecipeCount = Recipe.all().filter({ $0.isFavorited }).count
            return "\(favoriteRecipeCount) recipes"
        case .MostRecentFavorite:
            let favoriteDate = getMostRecentRecipeFavoritedTimestamp()
            if let date = favoriteDate {
                let millisecondsInDay = Double(60 * 60 * 24)
                let daysBack = -1 * date.timeIntervalSinceNow / millisecondsInDay
                if daysBack < 1 {
                    return "Favorited today"
                } else {
                    return "Favorited \(Int(daysBack)) days ago"
                }
            } else {
                return ""
            }
        case .MostRecentSearch:
            let searchDate = getMostRecentSearchTimestamp()
            if let date = searchDate {
                let millisecondsInDay = Double(60 * 60 * 24)
                let daysBack = -1 * date.timeIntervalSinceNow / millisecondsInDay
                if daysBack < 1 {
                    return "Searched today"
                } else {
                    return "Searched \(Int(daysBack)) days ago"
                }
            } else {
                return ""
            }
        case .BartendersChoice:
            let base = IngredientBaseGroup.all().random()
            let flavor = Flavor.all().random()
            let adjective = RecipeSelector().getPossibleAdjectives(base, flavor: flavor).random()
            return "\(base) + \(flavor) + \(adjective)"
        }
    }
    
    func toShortcutItem() -> UIApplicationShortcutItem {
        let shortcutItemType = NSBundle.mainBundle().bundleIdentifier! + ".Dynamic"
        return UIApplicationShortcutItem(type: shortcutItemType, localizedTitle: title(), localizedSubtitle: subtitle(), icon: nil, userInfo: nil)
    }
}