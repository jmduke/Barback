import Foundation

struct IngredientBaseArranger {
    
    func getSectionTitles(sortingMethod: IngredientBaseSortingMethod, bases: [IngredientBase]) -> [String] {
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            return Array(Set(bases.map({ return String($0.name[$0.name.startIndex]) }))).sort()
        } else {
            return []
        }
    }
    
    func getSectionCount(sortingMethod: IngredientBaseSortingMethod, bases: [IngredientBase]) -> Int {
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            return getSectionTitles(sortingMethod, bases: bases).count
        } else {
            return 1
        }
    }
    
    func getSectionSize(sortingMethod: IngredientBaseSortingMethod, bases: [IngredientBase], sectionIndex: Int) -> Int {
        return getRecipesInSection(sortingMethod, bases: bases, sectionIndex: sectionIndex).count
    }
    
    func getRecipesInSection(sortingMethod: IngredientBaseSortingMethod, bases: [IngredientBase], sectionIndex: Int) -> [IngredientBase] {
        let titles = getSectionTitles(sortingMethod, bases: bases)
        if (sortingMethod == .NameDescending || sortingMethod == .NameAscending) {
            
            if titles.count <= sectionIndex {
                return []
            }
            return bases.filter({ return String($0.name[$0.name.startIndex]) == titles[sectionIndex] })
        } else {
            return bases
        }
    }
}