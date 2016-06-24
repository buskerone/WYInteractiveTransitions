//
//  WYInteractiveTransitions.swift
//  WYInteractiveTransitions
//
//  Created by Wang Yu on 6/5/15.
//  Copyright (c) 2015 Yu Wang. All rights reserved.
//

import UIKit

public enum WYTransitoinType {
    case Push
    case Zoom
    case Up
    case Swing
    case ScaleAndRotate
    case HalfRotation
    case NewZoom
}

public class WYInteractiveTransitions: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    
    public func configureTransition(toViewController: UIViewController, panEnable handGestureEnable: Bool?=true, type transitionType: WYTransitoinType, duration: NSTimeInterval?=nil) {
        if let duration = duration {
            self.durationTransition = duration
        } else { self.durationTransition = 0.5 }
        self.transitionType = transitionType
        self.toViewController = toViewController
        self.toViewController?.transitioningDelegate = self
        self.toViewController?.modalPresentationStyle = .FullScreen
        if handGestureEnable == true {
            let panEdgeGesture = UIPanGestureRecognizer(target: self, action: #selector(WYInteractiveTransitions.handlePanGesture(_:)))
            toViewController.view.addGestureRecognizer(panEdgeGesture)
        }
    }
    
    private var presenting = true
    private var gestureEnable = true
    private var handIn = false
    private var transitionType = WYTransitoinType.Up
    private var toViewController: UIViewController?
    var durationTransition = 0.5
    
    private func clip(x: CGFloat) -> CGFloat { if x < 0 { return 0 } else { return x } }
    
    var initialTouchPoint = CGPointZero
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if let toView = toViewController {
            //            let translation: CGPoint = gesture.translationInView(toView.view)
            let location = gesture.locationInView(toView.view)
            let velocity = gesture.velocityInView(toView.view)
            
            switch gesture.state {
            case .Began:
                self.handIn = true
                toView.modalPresentationStyle = UIModalPresentationStyle.Custom
                toView.dismissViewControllerAnimated(true, completion: nil)
                initialTouchPoint = location
            case .Changed:
                let animationRatio: CGFloat = (clip(location.x - initialTouchPoint.x)) / (toView.view.bounds.width)
                self.updateInteractiveTransition(animationRatio)
            case .Ended, .Cancelled, .Failed:
                self.handIn = false
                if velocity.x > 0 {
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition()
                }
            default: break
            }
            
        }
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromView = fromVC.view
        let toView = toVC.view
        let duration = self.transitionDuration(transitionContext)
        
        let completeTransition: () -> () = {
            let isCancelled = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!isCancelled)
        }
        
        switch transitionType {
        case WYTransitoinType.Push:
            let moveToLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
            let moveToRight = CGAffineTransformMakeTranslation(container.frame.width, 0)
            toView.transform = self.presenting ? moveToRight : moveToLeft
            container.addSubview(toView)
            container.addSubview(fromView)
            UIView.animateWithDuration(0.5, animations: {
                fromView.transform = self.presenting ? moveToLeft : moveToRight
                toView.transform = CGAffineTransformIdentity
                }, completion: { (finished) in
                    completeTransition()
            })
        case WYTransitoinType.Up:
            if presenting {
                toView.frame = container.bounds
                toView.transform = CGAffineTransformMakeTranslation(0, container.frame.size.height)
                container.addSubview(fromView)
                container.addSubview(toView)
                UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    fromView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    fromView.alpha = 0.5
                    toView.transform = CGAffineTransformIdentity
                    }, completion: { (finished) -> Void in
                        completeTransition()
                })
            } else {
                let transfrom = toView.transform
                toView.transform = CGAffineTransformIdentity
                toView.frame = container.bounds
                toView.transform = transfrom
                
                container.addSubview(toView)
                container.addSubview(fromView)
                UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    fromView.transform = CGAffineTransformMakeTranslation(0, fromView.frame.size.height)
                    toView.transform = CGAffineTransformIdentity
                    toView.alpha = 1
                    }, completion: { (finished) -> Void in
                        completeTransition()
                })
            }
            
        case WYTransitoinType.Zoom:
            if presenting {
                container.addSubview(fromView)
                container.addSubview(toView)
                toView.alpha = 0
                toView.transform = CGAffineTransformMakeScale(2, 2)
                UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                    fromView.alpha = 0
                    toView.transform = CGAffineTransformIdentity
                    toView.alpha = 1
                    }, completion: { (finished) -> Void in
                        completeTransition()
                })
            } else {
                container.addSubview(toView)
                container.addSubview(fromView)
                UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    fromView.transform = CGAffineTransformMakeScale(2, 2)
                    fromView.alpha = 0
                    toView.transform = CGAffineTransformMakeScale(1, 1)
                    toView.alpha = 1
                    }, completion: { (finished) -> Void in
                        completeTransition()
                        
                })
            }
            
        case WYTransitoinType.Swing:
            let offScreenRight = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            let offScreenLeft = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            toView.transform = self.presenting ? offScreenRight : offScreenLeft
            
            toView.layer.anchorPoint = CGPoint(x:0, y:0)
            fromView.layer.anchorPoint = CGPoint(x:0, y:0)
            toView.layer.position = CGPoint(x:0, y:0)
            fromView.layer.position = CGPoint(x:0, y:0)
            container.addSubview(toView)
            container.addSubview(fromView)
            let duration = self.transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                fromView.transform = self.presenting ? offScreenLeft : offScreenRight
                toView.transform = CGAffineTransformIdentity
                }, completion: { finished in
                    completeTransition()
            })
            
        case WYTransitoinType.ScaleAndRotate:
            if presenting {
                toView.frame = container.bounds
                toView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                container.addSubview(fromView)
                container.addSubview(toView)
                
                UIView.animateWithDuration(duration, animations: {
                    toView.transform = CGAffineTransformMakeRotation(1/3 * CGFloat(M_PI*2))
                    toView.transform = CGAffineTransformMakeRotation(2/3 * CGFloat(M_PI*2))
                    toView.transform = CGAffineTransformMakeRotation(3/3 * CGFloat(M_PI*2))
                    toView.transform = CGAffineTransformMakeScale(1, 1)
                    
                    fromView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) in
                        completeTransition()
                })
            }
            else {
                let transform = toView.transform
                toView.transform = CGAffineTransformIdentity
                toView.frame = container.bounds
                toView.transform = transform
                
                container.addSubview(toView)
                container.addSubview(fromView)
                
                UIView.animateWithDuration(duration, animations: {
                    fromView.transform = CGAffineTransformMakeRotation(-1/3 * CGFloat(M_PI*2))
                    fromView.transform = CGAffineTransformMakeRotation(-2/3 * CGFloat(M_PI*2))
                    fromView.transform = CGAffineTransformMakeRotation(-3/3 * CGFloat(M_PI*2))
                    fromView.transform = CGAffineTransformMakeScale(0.01, 0.01)
                    
                    toView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) in
                        completeTransition()
                        fromView.removeFromSuperview()
                })
            }
            
        case WYTransitoinType.HalfRotation:
            
            if presenting {
                toView.frame = container.bounds
                
                
                container.addSubview(fromView)
                container.addSubview(toView)
                
                UIView.animateWithDuration(duration, animations: {
                    toView.transform = CGAffineTransformMakeScale(2, 2)
                    toView.transform = CGAffineTransformMakeTranslation(-256, -256)
                    toView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    fromView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) in
                        completeTransition()
                })
            }
            else {
                let transform = toView.transform
                toView.frame = container.bounds
                toView.transform = transform
                
                container.addSubview(toView)
                container.addSubview(fromView)
                
                UIView.animateWithDuration(duration, animations: {
                    fromView.transform = CGAffineTransformMakeScale(2, 2)
                    fromView.transform = CGAffineTransformMakeTranslation(-256, -256)
                    fromView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    fromView.alpha = 0
                    toView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) in
                        completeTransition()
                        fromView.removeFromSuperview()
                })
            }
            
        case WYTransitoinType.NewZoom:
            
            if presenting {
                let snapshotView = toView.resizableSnapshotViewFromRect(toView.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
                snapshotView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                snapshotView.center = fromView.center
                container.addSubview(snapshotView)
                
                toView.alpha = 0.0
                container.addSubview(toView)
                
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 20.0, options: [],
                                           animations: { () -> Void in
                                            snapshotView.transform = CGAffineTransformIdentity
                    }, completion: { (finished) -> Void in
                        snapshotView.removeFromSuperview()
                        toView.alpha = 1.0
                        transitionContext.completeTransition(finished)
                })
            }
            else {
                let snapshotView = fromView.resizableSnapshotViewFromRect(fromView.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
                snapshotView.center = toView.center
                container.addSubview(snapshotView)
                
                fromView.alpha = 0.0
                
                let toViewControllerSnapshotView = toView.resizableSnapshotViewFromRect(toView.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
                container.insertSubview(toViewControllerSnapshotView, belowSubview: snapshotView)
                
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    snapshotView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                    snapshotView.alpha = 0.0
                }) { (finished) -> Void in
                    toViewControllerSnapshotView.removeFromSuperview()
                    snapshotView.removeFromSuperview()
                    fromView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
            }
            
        }
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return durationTransition
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        toViewController = presenting
        self.presenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if handIn == true {
            return self
        } else { return nil }
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
