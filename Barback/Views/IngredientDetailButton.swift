import Foundation
import UIKit

class IngredientDetailButton: SimpleButton {
    
    var ingredient: IngredientBase? {
        didSet {
            let title = "Learn more about \(ingredient!.name)"
            setTitle(title, forState: UIControlState.Normal)
            setTitleColor(Color.Tint.toUIColor(), forState: UIControlState.Normal)
            
            titleLabel!.numberOfLines = 0
            titleLabel!.textAlignment = NSTextAlignment.Center
        }
    }
}
