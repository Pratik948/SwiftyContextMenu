//
//  RadialSubMenu.swift
//  SwiftyContextMenu
//
//  Created by Pratik Jamariya on 25/02/21.
//

import UIKit

// Using @objc here because we want to specify @optional methods which
// you can only do on classes, which you specify with the @objc modifier
@objc public protocol RadialSubMenuDelegate {
    @objc optional func subMenuDidOpen(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidHighlight(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidActivate(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidUnhighlight(_ subMenu: RadialSubMenu)
    @objc optional func subMenuDidClose(_ subMenu: RadialSubMenu)
}

open class RadialSubMenu: UIView {
    
    enum State {
        case closed, opening, opened, highlighted, unhighlighted, activated, closing
    }

    open var delegate: RadialSubMenuDelegate?
    var origPosition         = CGPoint.zero
    var currPosition         = CGPoint.zero
    
    var openDelay            = 0.0
    var closeDelay           = 0.0
    
    var closeDuration        = 0.1
    var openSpringSpeed      = 12.0
    var openSpringBounciness = 6.0
    
    var state: State = .closed {
        didSet {
            if oldValue == state { return }
            switch state {
                case .unhighlighted:
                    delegate?.subMenuDidUnhighlight?(self)
                    state = .opened
                case .opened:
                    delegate?.subMenuDidOpen?(self)
                case .highlighted:
                    delegate?.subMenuDidHighlight?(self)
                case .activated:
                    delegate?.subMenuDidActivate?(self)
                case .closed:
                    delegate?.subMenuDidClose?(self)
                default:
                    break
            }
        }
    }
    private static let imageViewTag = 1919191919191919 //Random Tag for UIImageView
    var imageView: UIImageView? {
        viewWithTag(RadialSubMenu.imageViewTag) as? UIImageView
    }
   
    // MARK - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        origPosition = self.center
        alpha = 1
        
    }
    
    convenience public init(imageView: UIImageView) {
        self.init(frame: imageView.frame)
        imageView.isUserInteractionEnabled = true
        imageView.tag = Self.imageViewTag
        addSubview(imageView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK - Main interface
    
    func openAt(_ position: CGPoint, fromPosition: CGPoint, delay: Double) {
        
        state = .opening
        openDelay = delay
        currPosition = position
        origPosition = fromPosition
        
        center = origPosition
        
        openAnimation()
    }
    
    func openAt(_ position: CGPoint, fromPosition: CGPoint) {
        openAt(position, fromPosition: fromPosition, delay: 0)
    }
    
    func close(_ delay: Double) {
        
        state = .closing
        closeDelay = delay
        closeAnimation()
    }
    
    func close() {
        close(0)
    }
    
    func highlight() {
        state = .highlighted
    }
    
    func unhighlight() {
        state = .unhighlighted
    }
    
    func activate(_ delay: Double) {
        closeDelay = delay
        state = .activated
        closeAnimation()
    }
    
    func activate() {
        activate(0)
    }
    
    // MARK - Animations
    
    func openAnimation() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 5,
                       options: .curveLinear) {
            self.frame.origin = self.currPosition
            self.alpha = 1.0
        } completion: { (finished) in
            self.state = .opened
            self.layoutSubviews()
        }
    }
    
    func closeAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.frame.origin = self.origPosition
            self.alpha = 0.0
        } completion: { (finished) in
            self.state = .closed
        }
    }
}

