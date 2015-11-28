import Foundation

struct RecipeSearcher {
    
    func searchAndArrange(searchTerm: String) -> [Recipe] {
        return searchAndArrange(Recipe.all(), searchTerm: searchTerm)
    }
    
    func searchAndArrange(recipes: [Recipe], searchTerm: String) -> [Recipe] {
        return recipes.filter({
            $0.matchesText(searchTerm)
        }).sort({
            let firstLocation = $0.name.lowercaseString.rangeOfString(searchTerm.lowercaseString)
            let secondLocation = $1.name.lowercaseString.rangeOfString(searchTerm.lowercaseString)
            
            if (secondLocation?.startIndex == nil) {
                return true
            }
            
            if (firstLocation?.startIndex == nil) {
                return false
            }
            
            return firstLocation?.startIndex < secondLocation?.startIndex
        })
    }
}