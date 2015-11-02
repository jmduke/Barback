//
//  CoachMarkView.swift
//  Barback
//
//  Created by Justin Duke on 8/15/15.
//  Copyright © 2015 Justin Duke. All rights reserved.
//

import Foundation
import UIKit

class CoachMarksView: UIView {
    
    
    var coachMarks: [CoachMark]
    var delegate: CoachMarksViewDelegate?
    
    // Views.
    var captionLabel: UILabel?
    var continueLabel: UILabel?
    var overlayMask: CAShapeLayer?
    
    // State.
    var markIndex: Int = 0
    
    // Constants.
    let maxCaptionWidth = 320
    let captionMargin = CGFloat(10.0)
    let shape = CutoutShape.Square
    let continueLabelEnabled = false
    let animationDuration = 0.3
    
    init(frame: CGRect, coachMarks: [CoachMark]) {
        self.coachMarks = coachMarks
        super.init(frame: frame)
        setUp()
    }
    
    private func setUp() {
        
        // Add the actual dark mask.
        overlayMask = CAShapeLayer()
        overlayMask!.fillRule = kCAFillRuleEvenOdd
        overlayMask!.fillColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.9).CGColor
        layer.addSublayer(overlayMask!)
        
        // Detect taps to go to the next mark.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "userDidTap:")
        addGestureRecognizer(tapGestureRecognizer)
        
        let captionFrame = CGRect(x: 0, y: 0, width: maxCaptionWidth, height: 0)
        let caption = UILabel(frame: captionFrame)
        caption.backgroundColor = UIColor.clearColor()
        caption.textColor = UIColor.whiteColor()
        caption.font = UIFont.systemFontOfSize(20)
        caption.lineBreakMode = NSLineBreakMode.ByWordWrapping
        caption.numberOfLines = 0
        caption.textAlignment = NSTextAlignment.Center
        caption.alpha = 0
        
        self.captionLabel = caption
        addSubview(caption)
        
        hidden = true
    }
    
    private func setCutoutToRect(rect: CGRect, shape: CutoutShape) {
        let maskPath = UIBezierPath(rect: bounds)
        let cutoutPath = shape.bezierPath(rect)
        maskPath.appendPath(cutoutPath)
        overlayMask?.path = maskPath.CGPath
    }
    
    private func animateCutoutToRect(rect: CGRect, shape: CutoutShape) {
        let maskPath = UIBezierPath(rect: bounds)
        let cutoutPath = shape.bezierPath(rect)
        maskPath.appendPath(cutoutPath)
        
        let animationKey = "path"
        let animation = CABasicAnimation(keyPath: animationKey)
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = animationDuration
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = overlayMask!.path
        animation.toValue = maskPath.CGPath
        overlayMask!.addAnimation(animation, forKey: animationKey)
        overlayMask!.path = maskPath.CGPath
    }

    required init?(coder aDecoder: NSCoder) {
        coachMarks = []
        super.init(coder: aDecoder)
    }
    
    func userDidTap(recognizer: UITapGestureRecognizer) {
        goToCoachMark(markIndex + 1)
    }
    
    func start() {
        alpha = 0
        hidden = false
        
        UIView.animateWithDuration(animationDuration, animations: { self.alpha = CGFloat(1.0) }, completion: {
            (finished: Bool) in
            self.goToCoachMark(0)
        })
    }
    
    func goToCoachMark(index: Int) {
        if index >= coachMarks.count {
            cleanUp()
            return
        }
        
        markIndex = index
        
        let coachMark = coachMarks[index]
        
        self.delegate?.coachMarksViewWillNavigateToIndex?(self, index: index)
        
        captionLabel!.alpha = 0
        captionLabel!.frame = CGRect(x: 0, y: 0, width: maxCaptionWidth, height: 0)
        captionLabel!.text = coachMark.caption
        captionLabel!.sizeToFit()
        
        var y = coachMark.rect.origin.y + coachMark.rect.size.height + captionMargin
        let bottomY = y + captionLabel!.frame.height + captionMargin
        if (bottomY > bounds.size.height) {
            y = coachMark.rect.origin.y - captionMargin - captionLabel!.frame.size.height
        }
        let x = floor((self.bounds.size.width - captionLabel!.frame.size.width) / 2)
        
        captionLabel!.frame = CGRect(origin: CGPoint(x: x, y: y), size: captionLabel!.frame.size)
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.captionLabel!.alpha = 1.0
        })
        
        if (index == 0) {
            let center = CGPoint(x: floor(coachMark.rect.origin.x + (coachMark.rect.size.width / 2)), y: floor(coachMark.rect.origin.y + (coachMark.rect.size.height / 2)))
            let centerZero = CGRect(origin: center, size: CGSizeZero)
            setCutoutToRect(centerZero, shape: shape)
        }
        
        animateCutoutToRect(coachMark.rect, shape: shape)
        
        let continueLabelWidth = bounds.size.width
        
        if (continueLabelEnabled) {
            if (index == 0) {
                continueLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.size.height - 30, width: continueLabelWidth, height: 30))
                continueLabel!.font = UIFont.boldSystemFontOfSize(13.0)
                continueLabel!.textAlignment = NSTextAlignment.Center
                continueLabel!.text = "Tap to continue"
                continueLabel!.alpha = 0.0
                continueLabel!.backgroundColor = UIColor.whiteColor()
                addSubview(continueLabel!)
                UIView.animateWithDuration(animationDuration, delay: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.continueLabel!.alpha = 1.0 }, completion: nil)
            } else if let _ = continueLabel {
                continueLabel!.removeFromSuperview()
                continueLabel = nil
            }
        }
    }
    
    private func cleanUp() {
        self.delegate?.coachMarksViewWillCleanUp?(self)
        
        UIView.animateWithDuration(animationDuration, animations: { self.alpha = 0.0 }, completion: {
            (finished: Bool) in
            self.removeFromSuperview()
            self.delegate?.coachMarksViewDidCleanUp?(self)
        })
    }
    
    internal override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.delegate?.coachMarksViewDidNavigateToIndex?(self, index: markIndex)
    }
}

enum CutoutShape {
    case Circle
    case Square
    case RoundedRect
    
    func bezierPath(rect: CGRect) -> UIBezierPath {
        switch self {
        case .Circle:
            return UIBezierPath(ovalInRect: rect)
        case .Square:
            return UIBezierPath(rect: rect)
        case .RoundedRect:
            return UIBezierPath(roundedRect: rect, cornerRadius: 3.0)
        }
    }
}
