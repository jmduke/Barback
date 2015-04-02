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
            return (100.0, 30.0, 90.0)
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
        return base
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
    
    var recipe: Recipe? 
    var glassware: Glassware  {
        get {
            return Glassware.fromString(self.recipe!.glassware)
        }
    }
    
    var strokeWidth: Double = 3.0
    var diagramScale: Double = 2.0
    var bgColor: UIColor = Color.Background.toUIColor()
    var heightOffset: Double = 6.0
    var widthOffset: Double = 6.0
    
    let EMPTY_SPACE_PROPORTION = 0.2
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.recipe = Recipe.all()[0]
    }
    
    init(recipe: Recipe) {
        super.init(frame: Glassware.fromString(recipe.glassware).rect())
        self.recipe = recipe
    }
    
    
    func idealHeight() -> CGFloat {
        return glassware.rect().height * CGFloat(diagramScale) + CGFloat(strokeWidth * 4.0)
    }
    
    func idealWidth() -> CGFloat {
        return glassware.rect().width * CGFloat(diagramScale) + CGFloat(strokeWidth * 4.0)
    }
    
    override func drawRect(rect: CGRect) {
        bgColor.setFill()
        UIRectFill(rect)
        drawRecipe(self.recipe!)
    }
    
    func drawRecipe(newRecipe: Recipe) {
        
        let height = glassware.dimensions().0 * diagramScale
        let bottomWidth = glassware.dimensions().1 * diagramScale
        let topWidth = glassware.dimensions().2 * diagramScale
        
        let inset = (topWidth - bottomWidth) / 2
        
        let totalCount = newRecipe.ingredients.map({ Double($0.amount) }).reduce(0.0, combine: +)
        
        var ratios: [(Double, UIColor)] = [(0.0, UIColor.redColor())]
        for ingredient in newRecipe.ingredients {
            let ratioFraction = (1.0 - EMPTY_SPACE_PROPORTION) * Double(ingredient.amount) / totalCount
            ratios.append(ratioFraction + ratios[ratios.count - 1].0, ingredient.base.uiColor)
        }
        ratios.append(1.0, UIColor.whiteColor())
        
        UIColor.whiteColor().setStroke()

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
            subCanvas.lineWidth = CGFloat(strokeWidth)
            subCanvas.moveToPoint(bottomLeft)
            subCanvas.addLineToPoint(bottomRight)
            subCanvas.addLineToPoint(topRight)
            subCanvas.addLineToPoint(topLeft)
            subCanvas.addLineToPoint(bottomLeft)
            subCanvas.closePath()
            subCanvas.fill()
            subCanvas.stroke()
        }

        let bottomLeft = CGPointMake(CGFloat(widthOffset + inset - 3), CGFloat(heightOffset + height + 3))
        let bottomRight = CGPointMake(CGFloat(widthOffset + topWidth - inset + 3), CGFloat(heightOffset + height + 3))
        let topRight = CGPointMake(CGFloat(widthOffset + topWidth + 3), CGFloat(heightOffset - 3))
        let topLeft = CGPointMake(CGFloat(widthOffset - 3), CGFloat(heightOffset - 3))
        
        Color.Dark.toUIColor().setStroke()
        let subCanvas = UIBezierPath()
        subCanvas.lineWidth = CGFloat(strokeWidth)
        subCanvas.moveToPoint(bottomLeft)
        subCanvas.addLineToPoint(bottomRight)
        subCanvas.addLineToPoint(topRight)
        subCanvas.addLineToPoint(topLeft)
        subCanvas.addLineToPoint(bottomLeft)
        subCanvas.closePath()
        subCanvas.stroke()
        
        sizeToFit()
    }
}

