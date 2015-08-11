import Foundation
import WSCoachMarksView

protocol HasCoachMarks {
    
    func coachMarksForController() -> [CoachMark]
    func runCoachMarks()
    
}

extension HasCoachMarks {
    
    func runCoachMarks() {
        if let controller = self as? UIViewController {
            controller.runCoachMarks(coachMarksForController())
        }
    }
}

extension UIViewController {
    
    func runCoachMarks(coachMarks: [CoachMark]) {
        
        if coachMarks.isEmpty {
            return
        }
        
        let caption = coachMarks[0].caption
        let prefix: AnyObject = caption.componentsSeparatedByString(" ")[0]
        let userDefaultsKey = "coachMarksFor\(prefix)"
        let haveCoachMarksBeenShown = NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsKey) && false
        
        if (!haveCoachMarksBeenShown) {
            let parsedCoachMarks: [Dictionary] = coachMarks.map {
                ["rect": NSValue(CGRect: $0.rect), "caption": $0.caption]
            }
            if let controller = navigationController {
                let coachMarksView = WSCoachMarksView(frame: controller.view.bounds, coachMarks: parsedCoachMarks)
                coachMarksView.lblCaption.font = UIFont(name: UIFont.primaryFont(), size: 20)
                controller.view.addSubview(coachMarksView)
                coachMarksView.start()
            } else {
                let coachMarksView = WSCoachMarksView(frame: view.bounds, coachMarks: parsedCoachMarks)
                coachMarksView.lblCaption.font = UIFont(name: UIFont.primaryFont(), size: 20)
                view.addSubview(coachMarksView)
                coachMarksView.start()
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: userDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}