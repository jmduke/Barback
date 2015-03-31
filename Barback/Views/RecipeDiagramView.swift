// Playground - noun: a place where people can play

import Foundation
import UIKit


enum Glassware {
    case Champagne
    case Cocktail
    case Collins
    case Goblet
    case Hurricane
    case Highball
    case Margarita
    case Martini
    case Mug
    case OldFashioned
    case Rocks
    case Shot
    
    func dimensions() -> (Double, Double, Double) {
        var base: (Double, Double, Double) = {
        switch self {
        case .Champagne:
            return (100.0, 0.0, 30.0)
        case .Cocktail, .Martini:
            return (50.0, 0.0, 60.0)
        case .Collins, .Highball:
            return (100.0, 40.0, 40.0)
        case .Goblet:
            return (100.0, 0.0, 100.0)
        case .Hurricane:
            return (100.0, 50.0, 80.0)
        case .Mug, .OldFashioned, .Rocks:
            return (60.0, 80.0, 80.0)
        case .Shot:
            return (40.0, 30.0, 40.0)
        case .Margarita:
            return (50.0, 10.0, 90.0)
        }
        }()
        return (base.0 * 2.0, base.1 * 2.0, base.2 * 2.0)
    }
    
    func rect() -> CGRect {
        return CGRectMake(0.0, 0.0, CGFloat(dimensions().2), CGFloat(dimensions().0))
    }
    
    static func fromString(string: String) -> Glassware {
        switch string {
        case "champagne flute":
            return .Champagne
        case "cocktail":
            return .Cocktail
        case "collins":
            return .Collins
        case "goblet":
            return .Goblet
        case "hurricane":
            return .Hurricane
        case "highball":
            return .Highball
        case "mug":
            return .Mug
        case "old fashioned":
            return .OldFashioned
        case "rocks":
            return .Rocks
        case "shot":
            return .Shot
        case "margarita":
            return .Margarita
        case "martini":
            return .Martini
        default:
            return .Martini
        }
    }
}

class RecipeDiagramView: UIView {
    
    let canvasWidth = 200.0
    let canvasHeight = 200.0
    
    var recipe: Recipe? 
    var glassware: Glassware  {
        get {
            return Glassware.fromString(self.recipe!.glassware)
        }
    }
    
    let EMPTY_SPACE_PROPORTION = 0.2
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.recipe = Recipe.all()[0]
    }
    
    init(recipe: Recipe) {
        super.init(frame: Glassware.fromString(recipe.glassware).rect())
        self.recipe = recipe
    }
    
    
    
    override func drawRect(rect: CGRect) {
        Color.Background.toUIColor().setFill()  // changes are here
        UIRectFill(rect);               // and here
        drawRecipe(self.recipe!)
    }
    
    func drawRecipe(newRecipe: Recipe) {
        
        let glassware = Glassware.fromString(newRecipe.glassware)
        
        let height = glassware.dimensions().0
        let bottomWidth = glassware.dimensions().1
        let topWidth = glassware.dimensions().2
        
        let heightOffset = (canvasHeight - height) / 2.0
        let widthOffset = (canvasWidth - topWidth) / 2.0
        
        let inset = (topWidth - bottomWidth) / 2
        
        let totalCount = newRecipe.ingredients.map({ Double($0.amount) }).reduce(0.0, combine: +)
        
        var ratios: [(Double, UIColor)] = [(0.0, UIColor.redColor())]
        for ingredient in newRecipe.ingredients {
        let ratioFraction = (1.0 - EMPTY_SPACE_PROPORTION) * Double(ingredient.amount) / totalCount
        ratios.append(ratioFraction + ratios[ratios.count - 1].0, ingredient.base.uiColor)
        }
        ratios.append(1.0, UIColor.whiteColor())
        
        Color.Dark.toUIColor().setStroke()
        
        for ratioIndex in 0...(ratios.count - 1) {
            let ratio = ratios[ratioIndex].0
            let previousRatio = ratioIndex > 0 ? ratios[ratioIndex - 1].0 : ratio
            let paddingOffset = 0.0
            
            ratios[ratioIndex].1.setFill()
            
            let bottomLeft = CGPointMake(CGFloat(widthOffset + inset * (1 - previousRatio)), CGFloat(heightOffset + height * ( 1 - previousRatio)))
            let bottomRight = CGPointMake(CGFloat(widthOffset + topWidth - (inset * ( 1 - previousRatio))), CGFloat(heightOffset + height * ( 1 - previousRatio)))
            let topRight = CGPointMake(CGFloat(widthOffset + topWidth - (inset * ( 1 - ratio))), CGFloat(heightOffset + height * ( 1 - ratio)))
            let topLeft = CGPointMake(CGFloat(widthOffset + inset * (1 - ratio)), CGFloat(heightOffset + height * ( 1 - ratio)))
            
            let subCanvas = UIBezierPath()
            subCanvas.moveToPoint(bottomLeft)
            subCanvas.addLineToPoint(bottomRight)
            subCanvas.addLineToPoint(topRight)
            subCanvas.addLineToPoint(topLeft)
            subCanvas.addLineToPoint(bottomLeft)
            subCanvas.closePath()
            subCanvas.fill()
            subCanvas.stroke()
        }
    }
}

