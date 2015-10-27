import Foundation
import UIKit

class AdjectivesSegmentControl: SegmentControl {

    var adjectives: [Adjective] = [] {
        didSet {
            let adjectiveCount = min(adjectives.count, 3)
            (0..<adjectiveCount).map {
                (i: Int) -> () in
                    setTitle(adjectives[i].description, forSegmentAtIndex: i)
                    setEnabled(true, forSegmentAtIndex: i)
            }
            (adjectiveCount..<3).map {
                (i: Int) -> () in
                setTitle("", forSegmentAtIndex: i)
                setEnabled(false, forSegmentAtIndex: i)
            }
        }
    }
    
    var selectedAdjective: Adjective {
        get {
            return adjectives[selectedSegmentIndex]
        }
        set {
            selectedSegmentIndex = adjectives.indexOf(newValue)!
        }
    }
}