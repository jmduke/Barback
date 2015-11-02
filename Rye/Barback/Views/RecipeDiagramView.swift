import Foundation
import UIKit

struct RecipeDiagramViewSegment {
    
    var viewRatio: Double
    var color: UIColor
    
}

class RecipeDiagramView: UIView {

    var recipe: Recipe?  {
        didSet {
            self.setNeedsDisplay()
        }
    }
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.recipe = Recipe()
        backgroundColor = UIColor.clearColor()
    }

    init(recipe: Recipe) {
        super.init(frame: Glassware.fromString(recipe.glassware).rect())
        self.recipe = recipe
        backgroundColor = UIColor.clearColor()
    }

    
    func idealHeight() -> CGFloat {
        return glassware.rect().height * CGFloat(diagramScale) + CGFloat(outlineWidth * 4.0 + heightOffset)
    }

    func idealWidth() -> CGFloat {
        return glassware.rect().width * CGFloat(diagramScale) + CGFloat(outlineWidth * 4.0 + widthOffset)
    }
    
    func drawSegment(strokeWidth: Double, bottomLeft: CGPoint, bottomRight: CGPoint, topLeft: CGPoint, topRight: CGPoint) -> UIBezierPath {
        let subCanvas = UIBezierPath()
        subCanvas.lineWidth = CGFloat(strokeWidth)
        subCanvas.moveToPoint(bottomLeft)
        subCanvas.addLineToPoint(bottomRight)
        subCanvas.addLineToPoint(topRight)
        subCanvas.addLineToPoint(topLeft)
        subCanvas.addLineToPoint(bottomLeft)
        subCanvas.closePath()
        subCanvas.stroke()
        return subCanvas
    }

    override func drawRect(rect: CGRect) {
        
        let height = glassware.dimensions().0 * diagramScale
        let bottomWidth = glassware.dimensions().1 * diagramScale
        let topWidth = glassware.dimensions().2 * diagramScale

        let inset = (topWidth - bottomWidth) / 2

        let totalVolume = recipe!.ingredients.map({ Double($0.amount) }).reduce(0.0, combine: +)

        var viewSegments: [RecipeDiagramViewSegment] = []
        
        // Place an initial segment to seed it.
        viewSegments.append(RecipeDiagramViewSegment(viewRatio: 0.0, color: UIColor.redColor()))

        // It looks nicer with bigger ingredients on the bottom.
        let sortedIngredients = recipe!.ingredients.sort({ $0.amount > $1.amount })
        
        // For each ingredient,
        let whitespaceModifier = (1.0 - EMPTY_SPACE_PROPORTION) / totalVolume
        for ingredient in sortedIngredients {
            let ratioFraction =  Double(ingredient.amount) * whitespaceModifier
            
            // If the base doesn't actually exist, then there's no color.
            if let base = ingredient.base {
                let previousRatioFraction = viewSegments[viewSegments.count - 1].viewRatio
                viewSegments.append(RecipeDiagramViewSegment(viewRatio: ratioFraction + previousRatioFraction, color: base.uiColor))
            }
        }

        // Whitespace on the top of the glass.
        viewSegments.append(RecipeDiagramViewSegment(viewRatio: 1.0, color: UIColor.whiteColor()))

        for segmentIndex in 0...(viewSegments.count - 1) {
            let viewSegment = viewSegments[segmentIndex]
            let ratio = viewSegment.viewRatio
            let previousRatio = segmentIndex > 0 ? viewSegments[segmentIndex - 1].viewRatio : ratio
            
            let proportionOfSpaceLeftBeforeSegment = 1 - previousRatio
            let proportionOfSpaceLeftAfterSegment = 1 - ratio
            
            let bottomOfSegment = CGFloat(heightOffset + height * proportionOfSpaceLeftBeforeSegment)
            let topOfSegment = CGFloat(heightOffset + height * proportionOfSpaceLeftAfterSegment)
            
            let bottomLeft = CGPointMake(CGFloat(widthOffset + inset * proportionOfSpaceLeftBeforeSegment), bottomOfSegment)
            let bottomRight = CGPointMake(CGFloat(widthOffset + topWidth - (inset * proportionOfSpaceLeftBeforeSegment)), bottomOfSegment)
            let topRight = CGPointMake(CGFloat(widthOffset + topWidth - (inset * proportionOfSpaceLeftAfterSegment)), topOfSegment)
            let topLeft = CGPointMake(CGFloat(widthOffset + inset * proportionOfSpaceLeftAfterSegment), topOfSegment)
            
            let subCanvas = drawSegment(strokeWidth, bottomLeft: bottomLeft, bottomRight: bottomRight, topLeft: topLeft, topRight: topRight)

            viewSegment.color.setFill()
            subCanvas.fill()

            UIColor.whiteColor().setStroke()
            subCanvas.stroke()
        }
        
        let bottomOfGlass = CGFloat(heightOffset + height + strokeWidth)
        let topOfGlass = CGFloat(heightOffset - strokeWidth)

        let bottomExtra = bottomWidth == 0 ? 0 : strokeWidth
    
        let bottomLeft = CGPointMake(CGFloat(widthOffset + inset - bottomExtra), bottomOfGlass)
        let bottomRight = CGPointMake(CGFloat(widthOffset + topWidth - inset + bottomExtra), bottomOfGlass)
        let topRight = CGPointMake(CGFloat(widthOffset + topWidth + strokeWidth), topOfGlass)
        let topLeft = CGPointMake(CGFloat(widthOffset - strokeWidth), topOfGlass)

        outlineColor.setStroke()
        drawSegment(1.0, bottomLeft: bottomLeft, bottomRight: bottomRight, topLeft: topLeft, topRight: topRight)
        
        if diagramScale < 1.0 {
            return
        }

        let garnishes = recipe!.parsedGarnishes
        for garnish in garnishes {
            // garnish.draw(diagramScale)
        }
    }
}

