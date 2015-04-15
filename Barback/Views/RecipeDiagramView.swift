// Playground - noun: a place where people can play

import Foundation
import UIKit

class RecipeDiagramView: UIView {
    
    var recipe: Recipe? 
    var glassware: Glassware  {
        get {
            return Glassware.fromString(self.recipe!.glassware)
        }
    }
    
    var strokeWidth: Double = 3.0
    var diagramScale: Double = 2.0
    var heightOffset: Double = 6.0
    var widthOffset: Double = 6.0
    var outlineColor: UIColor = Color.Dark.toUIColor()
    var outlineWidth: Double = 3.0
    
    let EMPTY_SPACE_PROPORTION = 0.2
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.recipe = Recipe.all()[0]
        backgroundColor = UIColor.clearColor()
    }
    
    init(recipe: Recipe) {
        super.init(frame: Glassware.fromString(recipe.glassware).rect())
        self.recipe = recipe
        backgroundColor = UIColor.clearColor()
    }
    
    
    func idealHeight() -> CGFloat {
        return glassware.rect().height * CGFloat(diagramScale) + CGFloat(outlineWidth * 4.0)
    }
    
    func idealWidth() -> CGFloat {
        return glassware.rect().width * CGFloat(diagramScale) + CGFloat(outlineWidth * 4.0)
    }
    
    override func drawRect(rect: CGRect) {
        drawRecipe(self.recipe!)
    }
    
    func drawRecipe(newRecipe: Recipe) {
        
        let height = glassware.dimensions().0 * diagramScale
        let bottomWidth = glassware.dimensions().1 * diagramScale
        let topWidth = glassware.dimensions().2 * diagramScale
        
        let inset = (topWidth - bottomWidth) / 2
        
        let totalCount = newRecipe.ingredients.map({ Double($0.amount) }).reduce(0.0, combine: +)
        
        var ratios: [(Double, UIColor)] = [(0.0, UIColor.redColor())]
        let sortedIngredients = newRecipe.ingredients.sorted({ $0.amount.intValue > $1.amount.intValue })
        for ingredient in sortedIngredients {
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

        let bottomLeft = CGPointMake(CGFloat(widthOffset + inset - strokeWidth), CGFloat(heightOffset + height + strokeWidth))
        let bottomRight = CGPointMake(CGFloat(widthOffset + topWidth - inset + strokeWidth), CGFloat(heightOffset + height + strokeWidth))
        let topRight = CGPointMake(CGFloat(widthOffset + topWidth + strokeWidth), CGFloat(heightOffset - strokeWidth))
        let topLeft = CGPointMake(CGFloat(widthOffset - strokeWidth), CGFloat(heightOffset - strokeWidth))
        
        outlineColor.setStroke()
        let subCanvas = UIBezierPath()
        subCanvas.lineWidth = CGFloat(1)
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

