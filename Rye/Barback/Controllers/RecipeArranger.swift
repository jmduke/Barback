import Foundation

struct RecipeArranger {
    
    func getSectionTitles(sortingMethod: RecipeSortingMethod, recipes: [Recipe]) -> [String] {
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            return Array(Set(recipes.map({ return String($0.name[$0.name.startIndex]) }))).sort()
        } else {
            return []
        }
    }
    
    func getSectionCount(sortingMethod: RecipeSortingMethod, recipes: [Recipe]) -> Int {
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            return getSectionTitles(sortingMethod, recipes: recipes).count
        } else {
            return 1
        }
    }
    
    func getSectionSize(sortingMethod: RecipeSortingMethod, recipes: [Recipe], sectionIndex: Int) -> Int {
        return getRecipesInSection(sortingMethod, recipes: recipes, sectionIndex: sectionIndex).count
    }
    
    func getRecipesInSection(sortingMethod: RecipeSortingMethod, recipes: [Recipe], sectionIndex: Int) -> [Recipe] {
        let titles = getSectionTitles(sortingMethod, recipes: recipes)
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            return recipes.filter({ return String($0.name[$0.name.startIndex]) == titles[sectionIndex] })
        } else {
            return recipes
        }
    }
}