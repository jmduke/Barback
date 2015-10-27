import Foundation

struct ControllerNavigator {
    
    var application: AppDelegate?
    
    func pushRecipeDetailController(recipe: Recipe) {
        let controller = R.storyboard.main.recipeDetail!
        controller.setRecipeAs(recipe)
        let tabBarController = application?.window?.rootViewController as! UITabBarController
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        navController.pushViewController(controller, animated: true)
    }
    
    func pushFavoriteListViewController() {
        let tabBarController = application?.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = 2
    }
    
    func pushRecipeListViewController(searchTerm: String?) {
        let tabBarController = application?.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = 0
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        let controller = navController.visibleViewController as! FullRecipeListViewController
        controller.searchController?.searchBar.text = searchTerm
    }
    
    func pushIngredientDetailController(ingredient: IngredientBase) {
        let controller = R.storyboard.main.ingredientDetail!
        controller.ingredient = ingredient
        let tabBarController = application?.window?.rootViewController as! UITabBarController
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        navController.pushViewController(controller, animated: true)
    }
    
    func pushPrefilledWizardViewController(baseGroup: IngredientBaseGroup, flavor: Flavor, adjective: Adjective) {
        let tabBarController = application?.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = 3
        let navController: UINavigationController = tabBarController.selectedViewController as! UINavigationController
        let controller = navController.visibleViewController as! RecipeWizardViewController
        controller.loadView()
        controller.viewDidLoad()
        
        if (controller.firstBaseSegmentedControl.baseGroups.contains(baseGroup)) {
            controller.firstBaseSegmentedControl.selectedBase = baseGroup
        } else {
            controller.secondBaseSegmentedControl.selectedBase = baseGroup
        }
        controller.firstAdjectiveSegmentedControl.selectedFlavor = flavor
        
        controller.updateAdjectives()
        controller.secondAdjectiveSegmentedControl.selectedAdjective = adjective
    }
}