import Foundation
import JLRoutes

enum URLRoute {
    case RecipeDetail
    case IngredientDetail
    
    var url: String {
        switch self {
        case .RecipeDetail:
            return "/recipe/:name"
        case .IngredientDetail:
            return "/ingredient/:name"
        }
    }
    
    var handler: ((params: [NSObject: AnyObject]!) -> Bool) {
        switch self {
        case .RecipeDetail:
            func function(params: [NSObject: AnyObject]!) -> Bool {
                let recipe = Recipe.forName(params["name"] as! String)!
                var controllerNavigator = ControllerNavigator()
                controllerNavigator.application = UIApplication.sharedApplication() as? AppDelegate
                controllerNavigator.pushRecipeDetailController(recipe)
                return true
            }
            return function
        case .IngredientDetail:
            func function(params: [NSObject: AnyObject]!) -> Bool {
                let base = IngredientBase.all().filter({ $0.name == (params["name"] as! String) }).first!
                var controllerNavigator = ControllerNavigator()
                controllerNavigator.application = UIApplication.sharedApplication() as? AppDelegate
                controllerNavigator.pushIngredientDetailController(base)
                return true
            }
            return function
        }
    }
    
    static func all() -> [URLRoute] {
        return [
            .RecipeDetail,
            .IngredientDetail
        ]
    }
}
