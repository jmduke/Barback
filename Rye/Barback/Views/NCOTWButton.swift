import Foundation
import UIKit

public class NCOTWButton: SimpleButton {
    var recipe: Recipe? {
        didSet {
            if recipe!.ncotw != "" {
                setTitle("\(recipe!.name) on NCOTW", forState: UIControlState.Normal)
            } else {
                removeFromSuperview()
            }
        }
    }
}