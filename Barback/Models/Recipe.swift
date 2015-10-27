import CoreData
import CoreSpotlight
import Foundation
import MobileCoreServices
import Mustache
import RealmSwift

public final class Recipe: Object, SpotlightIndexable, Equatable, Hashable {

    public dynamic var directions: String = ""
    public dynamic var glassware: String = ""
    public dynamic var garnish: String = ""
    public dynamic var source: String = ""
    public dynamic var name: String = ""
    dynamic var slug: String = ""
    public dynamic var information: String = ""
    public dynamic var isFavorited: Bool = false
    public dynamic var emoji: String = ""

    public var ingredients = List<Ingredient>()

    var parsedSource: Source? {
        return Source(rawSource: self.source)
    }
    
    func uniqueID() -> String {
        return name
    }

    var parsedGarnishes: [Garnish] {
        let rawGarnishes: [String] = garnish.componentsSeparatedByString(",") ?? []
        let parsedGarnishes: [Garnish] = rawGarnishes.map({ Garnish(rawGarnish: $0) })
        return parsedGarnishes
    }

    var isNew: Bool = false

    var url: NSURL {
        return externalUrl!.URLByAppendingPathComponent("recipe/\(slug)")
    }

    var detailDescription: String {
        get {
            let sortedIngredients = ingredients.sort({$0.amount > $1.amount})
            
            // This should, uh, never happen.
            if sortedIngredients.count == 0 {
                return ""
            }
            
            let ingredientCountInDescription = 3
            let relevantIngredients = Array(sortedIngredients[0...max(0,min(sortedIngredients.count - 1, ingredientCountInDescription))].map({
                (ingredient: Ingredient) -> String in
                return (ingredient.base?.name ?? "")
            }))
            return relevantIngredients.joinWithSeparator(", ")
        }
    }

    lazy public var abv: Double = {
        let amounts = self.ingredients.map({ $0.amount ?? 0.0 }) as [Float]
        let denominator = amounts.reduce(0, combine: +) as Float
        let numerator = (self.ingredients.map({
            (ingredient: Ingredient) -> Double in
            (ingredient.base?.abv ?? 0.0 as Double).description
            let abv = ingredient.base?.abv ?? 0.0
            let proportion = Double(ingredient.amount ?? 0.0)
            return abv * proportion
        }) as [Double]).reduce(0.0, combine: +)
        return Double(numerator) / Double(denominator)
    }()

    public var htmlString: String {
        get {
            let hasGarnish = (garnish != "" && !garnish.isEmpty)
            let hasInformation = (information != "")
            var convertedMarkdown: String = ""
            if hasInformation {
                var markdownConverter = Markdown()
                convertedMarkdown = markdownConverter.transform(information)
            }

            // Render using Mustache.
            let template = try! Template(named: "Recipe")
            let data = [
                "parsedABV": round(abv),
                "recipe": self,
                "hasGarnish": hasGarnish,
                "hasInformation": hasInformation,
                "renderedInformation": convertedMarkdown,
                "ingredients": self.ingredients
            ]
            let rendering = try! template.render(Box(data))
            return rendering
        }
    }

    func usesIngredient(ingredient: IngredientBase) -> Bool {
        let bases: [IngredientBase] = ingredients.filter({ $0.base != nil }).map({$0.base!})
        return bases.contains(ingredient)
    }

    public func similarRecipes() -> [Recipe] {
        let ingredientBases = self.ingredients.filter({ $0.base != nil }).map({ $0.base! })
        let numberOfSimilarIngredientsRequired = Int(ceil(Double(self.ingredients.count) / 2.0))

        let similarUses: [[Recipe]] = ingredientBases.map({ $0.uses.map({ $0.recipe! }) })
        let similarRecipes = Recipe.all().filter({
            (recipe: Recipe) -> Bool in
            let similarities = similarUses.filter({ $0.contains(recipe) })
            return similarities.count >= numberOfSimilarIngredientsRequired && recipe.name != self.name
        })

        return similarRecipes
    }

    class public func all() -> [Recipe] {
        return (try? Realm().objects(Recipe).sorted("name").map({ $0 })) ?? []
    }
    
    class public func favorites() -> [Recipe] {
        return all().filter({ $0.isFavorited })
    }

    class public func random() -> Recipe {
        let recipes =  all()
        let randomIndex = Int(arc4random_uniform(UInt32(recipes.count)))
        return recipes[randomIndex]
    }

    class public func forName(name: String) -> Recipe? {
        return ((try? Realm().objects(Recipe).filter("name = '\(name)'").map({ $0 })) ?? []).first
    }
    
    class func forIndexableID(indexableID: String) -> Recipe {
        return forName(getUniqueIDFromIndexableID(indexableID))!
    }
    
    func toAttributeSet() -> CSSearchableItemAttributeSet {
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        
        attributeSet.title = name
        attributeSet.contentDescription = name + ": " + information
        
        let view = RecipeDiagramView(recipe: self)
        view.diagramScale = 0.5
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let recipeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData = NSData(data: UIImagePNGRepresentation(recipeImage)!)
        attributeSet.thumbnailData = imageData
        
        return attributeSet
    }
}

extension Recipe {
    func matchesText(text: String) -> Bool {
        if (name.lowercaseString.rangeOfString(text.lowercaseString) != nil) {
            return true
        }
        
        if (text.lowercaseString.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 2 &&
            information.lowercaseString.rangeOfString(text.lowercaseString) != nil) {
            return true
        }
        
        if (emoji.rangeOfString(text) != nil) {
            return true
        }
        
        return false
    }
}

public func ==(lhs: Recipe, rhs: Recipe) -> Bool {
    return lhs.name == rhs.name
}