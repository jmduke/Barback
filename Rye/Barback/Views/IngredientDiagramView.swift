import Foundation
import UIKit

class IngredientDiagramView: UIView {

    var ingredients: [IngredientBase]? {
        didSet {
            if let _ = ingredients?.first?.color {
                backgroundColor = Color.Background.toUIColor()
                strokeColor = Color.Dark.toUIColor()
                self.setNeedsDisplay()
            } else {
                removeFromSuperview()
            }
        }
    }
    var strokeColor: UIColor?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ingredients = [IngredientBase.all()[0]]
    }

    init(frame: CGRect, ingredient: IngredientBase) {
        super.init(frame: frame)
        self.ingredients = [ingredient]
        backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, ingredients: [IngredientBase]) {
        super.init(frame: frame)
        self.ingredients = ingredients
        backgroundColor = UIColor.clearColor()
    }

    override func drawRect(rect: CGRect) {
        let fallbackColor = "eeeeee"
        let nestedIngredientStrokeWidth = 4
        
        for (ingredientNumber, ingredient) in ingredients!.enumerate() {
            let inset = CGFloat(ingredientNumber * nestedIngredientStrokeWidth)
            let insetRect = CGRect(origin: CGPoint(x: inset, y: inset), size: CGSize(width: rect.width - (inset * 2), height: rect.height - (inset * 2)))
            let diagram = UIBezierPath(ovalInRect: insetRect)
            let fillColor = UIColor.fromHex(ingredient.color ?? fallbackColor)
            fillColor.setFill()
            diagram.fill()
            
            if ingredientNumber > 0 {
                let color = UIColor.whiteColor()
                color.setStroke()
                diagram.stroke()
            }
            else if let color = strokeColor {
                color.setStroke()
                diagram.stroke()
            }
        }
    }
}
