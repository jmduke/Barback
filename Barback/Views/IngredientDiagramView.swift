import Foundation

class IngredientDiagramView: UIView {
    
    var ingredient: IngredientBase?
    var strokeColor: UIColor?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ingredient = IngredientBase.all()[0]
    }
    
    init(frame: CGRect, ingredient: IngredientBase) {
        super.init(frame: frame)
        self.ingredient = ingredient
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        let fallbackColor = "eeeeee"
        
        let diagram = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: rect.size))
        let fillColor = UIColor.fromHex(ingredient!.color ?? fallbackColor)
        
        fillColor.setFill()
        diagram.fill()
        
        if let color = strokeColor {
            color.setStroke()
            diagram.stroke()
        }
    }
}
