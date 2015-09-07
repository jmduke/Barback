import Foundation
import UIKit

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
    var heightOffset: Double = 21.0
    var widthOffset: Double = 26.0
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

    override func drawRect(rect: CGRect) {
        
        let height = glassware.dimensions().0 * diagramScale
        let bottomWidth = glassware.dimensions().1 * diagramScale
        let topWidth = glassware.dimensions().2 * diagramScale

        let inset = (topWidth - bottomWidth) / 2

        let totalCount = recipe!.ingredients.map({ Double($0.amount) }).reduce(0.0, combine: +)

        var ratios: [(Double, UIColor)] = [(0.0, UIColor.redColor())]
        let sortedIngredients = recipe!.ingredients.sort({ $0.amount > $1.amount })
        for ingredient in sortedIngredients {
            let ratioFraction = (1.0 - EMPTY_SPACE_PROPORTION) * Double(ingredient.amount) / totalCount
            if let base = ingredient.base {
                ratios.append((ratioFraction + ratios[ratios.count - 1].0, base.uiColor))
            }
        }
        ratios.append((1.0, UIColor.whiteColor()))

        for ratioIndex in 0...(ratios.count - 1) {
            let ratio = ratios[ratioIndex].0
            let previousRatio = ratioIndex > 0 ? ratios[ratioIndex - 1].0 : ratio
            
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

            ratios[ratioIndex].1.setFill()
            subCanvas.fill()

            UIColor.whiteColor().setStroke()
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
        
        if diagramScale < 1.0 {
            return
        }
        
        // BDE6BA
        
        let garnishes = recipe!.parsedGarnishes
        print(garnishes)
        for garnish in garnishes {
            switch(garnish.base) {
            case .Cherry?:
                let cherryRadius = 10.0 * diagramScale
                let insetRect = CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: cherryRadius, height: cherryRadius))
                let diagram = UIBezierPath(ovalInRect: insetRect)
                UIColor.fromHex("EEACAC").setFill()
                diagram.fill()
                UIColor.whiteColor().setStroke()
                diagram.stroke()
            case .Olive?:
                let oliveRadius = 10.0 * diagramScale
                let insetRect = CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: oliveRadius, height: oliveRadius))
                let diagram = UIBezierPath(ovalInRect: insetRect)
                UIColor.fromHex("BDE6BA").setFill()
                diagram.fill()
                UIColor.whiteColor().setStroke()
                diagram.stroke()
            case .Orange?:
                //// General Declarations
                //// General Declarations
                let context = UIGraphicsGetCurrentContext()
                
                //// Color Declarations
                let f7B63E = UIColor(red: 0.969, green: 0.714, blue: 0.243, alpha: 1.000)
                
                //// Bezier Drawing
                CGContextSaveGState(context)
                CGContextTranslateCTM(context, 33.18, -5.74)
                CGContextRotateCTM(context, 45 * CGFloat(M_PI) / 180)
                
                let bezierPath = UIBezierPath()
                bezierPath.moveToPoint(CGPointMake(22, -0))
                bezierPath.addCurveToPoint(CGPointMake(0, 27), controlPoint1: CGPointMake(22, -0), controlPoint2: CGPointMake(0, 4))
                bezierPath.addCurveToPoint(CGPointMake(22, 54), controlPoint1: CGPointMake(0, 50), controlPoint2: CGPointMake(22, 54))
                bezierPath.addLineToPoint(CGPointMake(22, -0))
                bezierPath.closePath()
                f7B63E.setFill()
                bezierPath.fill()
                UIColor.whiteColor().setStroke()
                bezierPath.stroke()
                
                CGContextRestoreGState(context)



            default: break
            }
        }
    }
}

