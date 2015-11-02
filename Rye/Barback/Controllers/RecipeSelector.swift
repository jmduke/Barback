import Foundation

struct RecipeSelector {
    
    var recipeBlacklist: [Recipe] = []
    
    func getRecipes(adjective: Adjective, flavor: Flavor, baseGroup: IngredientBaseGroup) -> [Recipe] {
        var recipes = baseGroup.recipes.filter({ flavor.describesRecipe($0) }).filter({ adjective.describesRecipe($0) })
        
        // If there are recipes we haven't seen before, use 'em!
        if (recipeBlacklist.count < recipes.count) {
            recipes = recipes.filter({
                !recipeBlacklist.contains($0)
            })
        }
        
        return recipes
    }
    
    func getRecipes(baseGroup: IngredientBaseGroup, flavor: Flavor) -> [Recipe] {
        var recipes = baseGroup.recipes.filter({ flavor.describesRecipe($0) })
        
        // If there are recipes we haven't seen before, use 'em!
        if (recipeBlacklist.count < recipes.count) {
            recipes = recipes.filter({
                !recipeBlacklist.contains($0)
            })
        }
        
        return recipes
    }
    
    func getPossibleAdjectives(baseGroup: IngredientBaseGroup, flavor: Flavor) -> [Adjective] {
        let recipes = getRecipes(baseGroup, flavor: flavor)
        return Adjective.all().filter({
            (adjective: Adjective) -> Bool in
            recipes.filter({
                adjective.describesRecipe($0)
                }).count > 0
        })
    }

}