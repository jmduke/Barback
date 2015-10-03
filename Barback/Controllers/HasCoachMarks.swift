import Foundation

protocol HasCoachMarks {
    
    func coachMarksForController() -> [CoachMark]
    func runCoachMarks(attachedView: UIView)
    
}

extension HasCoachMarks {
    
    func runCoachMarks(attachedView: UIView) {
        if let controller = self as? UIViewController {
            controller.runCoachMarks(attachedView, coachMarks: coachMarksForController())
        }
    }
}

extension UIViewController {
    
    func runCoachMarks(attachedView: UIView, coachMarks: [CoachMark]) {
        
        if coachMarks.isEmpty {
            return
        }
        
        let caption = coachMarks[0].caption
        
        let prefix: AnyObject = caption.componentsSeparatedByString(" ")[0]
        let userDefaultsKey = "coachMarksFor\(prefix)"
        let haveCoachMarksBeenShown = NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsKey)
        
        if (haveCoachMarksBeenShown) {
            return
        }

        let frame = (attachedView as? UIScrollView)?.contentSize ?? attachedView.bounds.size
        
        let visibleCoachMarks = coachMarks.filter({ $0.rect.height > 0 })
        let coachMarksView = CoachMarksView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: attachedView.bounds.width, height: frame.height)), coachMarks: visibleCoachMarks)
    
        let fontSize = max(UIFontDescriptor
            .preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline)
            .pointSize, 20)
        coachMarksView.captionLabel?.font = UIFont(name: UIFont.primaryFont(), size: fontSize)
    
        coachMarksView.delegate = (self as? CoachMarksViewDelegate)
        attachedView.addSubview(coachMarksView)
        coachMarksView.start()
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: userDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}