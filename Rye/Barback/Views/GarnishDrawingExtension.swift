
import Foundation

extension Garnish {
    
    func draw(diagramScale: Double) {
        
        let ovalRadius = 10.0 * diagramScale
        func drawOval(color: UIColor) {
            let insetRect = CGRect(origin: CGPoint(x: 30, y: 10), size: CGSize(width: ovalRadius, height: ovalRadius))
            let diagram = UIBezierPath(ovalInRect: insetRect)
            color.setFill()
            diagram.fill()
            UIColor.whiteColor().setStroke()
            diagram.stroke()
        }

        switch(base) {

        case .Cherry?:
            drawOval(UIColor.fromHex("EEACAC"))

        case .Olive?:
            drawOval(UIColor.fromHex("BDE6BA"))

        case .Orange?:
            if (type != .Slice) {
                break
            }

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

        case .Lemon?:
            if (type != .Twist) {
                break
            }

            //// Color Declarations
            let color = UIColor(red: 1.000, green: 0.985, blue: 0.140, alpha: 1.000)
            
            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(30.5, 16.11))
            bezierPath.addCurveToPoint(CGPointMake(59.69, 16.11), controlPoint1: CGPointMake(30.5, 16.11), controlPoint2: CGPointMake(45.09, -0.76))
            bezierPath.addCurveToPoint(CGPointMake(90.5, 16.11), controlPoint1: CGPointMake(74.28, 32.99), controlPoint2: CGPointMake(90.5, 16.11))
            UIColor.whiteColor().setStroke()
            bezierPath.lineWidth = 7
            bezierPath.stroke()
            
            
            //// Bezier 2 Drawing
            let bezier2Path = UIBezierPath()
            bezier2Path.moveToPoint(CGPointMake(30.5, 16.11))
            bezier2Path.addCurveToPoint(CGPointMake(59.69, 16.11), controlPoint1: CGPointMake(30.5, 16.11), controlPoint2: CGPointMake(45.09, -0.76))
            bezier2Path.addCurveToPoint(CGPointMake(90.5, 16.11), controlPoint1: CGPointMake(74.28, 32.99), controlPoint2: CGPointMake(90.5, 16.11))
            color.setStroke()
            bezier2Path.lineWidth = 5
            bezier2Path.stroke()
        
        default: break
        }
    }
}