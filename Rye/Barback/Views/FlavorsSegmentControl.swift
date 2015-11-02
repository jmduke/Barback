import Foundation
import UIKit

class FlavorsSegmentControl: SegmentControl {
    
    var flavors: [Flavor] = Flavor.all() {
        didSet {
            (0...(flavors.count - 1)).map({
                setTitle(Flavor.all()[$0].rawValue, forSegmentAtIndex: $0)
            })
        }
    }
    
    var selectedFlavor: Flavor {
        get {
            return flavors[selectedSegmentIndex]
        }
        set {
            selectedSegmentIndex = flavors.indexOf(newValue)!
        }
    }
}