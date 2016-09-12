//
//  HCRootAnimatedTransitioning.swift
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

class HCRootAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private struct Const {
        static let Duration: NSTimeInterval = 0.3
        static let Scaling: CGFloat = 0.95
    }
    
    let operation: UINavigationControllerOperation
    private let alphaView = UIView()
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return Const.Duration
    }
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView()
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        containerView.backgroundColor = .blackColor()
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        alphaView.frame = containerView.bounds
        
        switch operation {
        case .Pop: popAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .Push: pushAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .None:
            transitionContext.completeTransition(true)
            break
        }
    }
    
    private func popAnimation(transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.insertSubview(alphaView, belowSubview: fromVC.view)
        
        var initialFrame: CGRect?
        if let rootVC = toVC as? HCRootViewController, pagingVC = fromVC as? HCPagingViewController {
            let indexPath = pagingVC.currentIndexPath
            if rootVC.tableView?.cellForRowAtIndexPath(indexPath) == nil {
                rootVC.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: pagingVC.scrollDirection, animated: false)
            }
            
            if let cell = rootVC.tableView?.cellForRowAtIndexPath(indexPath) {
                if let nullableVC = pagingVC.viewControllers[.Center], centeVC = nullableVC {
                    centeVC.cellImageView.frame = cell.bounds
                    centeVC.cellImageView.image = cell.screenshot()
                }
                
                if let superview = rootVC.view,
                   let point = cell.superview?.convertPoint(cell.frame.origin, toView: superview) {
                    var selectedCellFrame: CGRect = .zero
                    selectedCellFrame.origin = point
                    selectedCellFrame.size = cell.bounds.size
                    initialFrame = selectedCellFrame
                }
            }
            
            rootVC.tableView?.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
        
        fromVC.view.clipsToBounds = true
        alphaView.alpha = 1
        toVC.view.transform = CGAffineTransformMakeScale(Const.Scaling, Const.Scaling)
        
        UIView.animateKeyframesWithDuration(transitionDuration(transitionContext) , delay: 0, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.25) {
                (fromVC as? HCPagingViewController)?.viewControllers[.Center]??.cellImageView.alpha = 1
            }
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.25) {
                (fromVC as? HCPagingViewController)?.containerViews[.Center]?.alpha = 0
            }
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1) {
                if let initialFrame = initialFrame {
                    fromVC.view.frame = initialFrame
                }
                fromVC.view.layoutIfNeeded()
                toVC.view.transform = CGAffineTransformIdentity
                self.alphaView.alpha = 0
            }
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled()
            if canceled {
                toVC.view.removeFromSuperview()
            } else {
                fromVC.view.removeFromSuperview()
                fromVC.view.clipsToBounds = false
            }
            
            toVC.view.transform = CGAffineTransformIdentity
            self.alphaView.removeFromSuperview()
            
            if let pagingVC = fromVC as? HCPagingViewController, rootVC = toVC as? HCRootViewController {
                let indexPath = pagingVC.currentIndexPath
                rootVC.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
            }
            transitionContext.completeTransition(!canceled)
        }
    }
    
    private func pushAnimation(transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.addSubview(alphaView)
        containerView.addSubview(toVC.view)
        
        toVC.view.clipsToBounds = true
        
        var earlyAlphaAnimation = false
        if let rootVC = fromVC as? HCRootViewController, pagingVC = toVC as? HCPagingViewController {
            let indexPath = pagingVC.currentIndexPath
            if let cell = rootVC.tableView?.cellForRowAtIndexPath(indexPath) {
                if let nullableVC = pagingVC.viewControllers[.Center], centeVC = nullableVC {
                    centeVC.cellImageView.frame = cell.bounds
                    centeVC.cellImageView.image = cell.screenshot()
                }
                if let superview = rootVC.view,
                   let point = cell.superview?.convertPoint(cell.frame.origin, toView: superview) {
                    var selectedCellFrame: CGRect = .zero
                    selectedCellFrame.origin = point
                    selectedCellFrame.size = cell.bounds.size
                    toVC.view.frame = selectedCellFrame
                }
                if let superview = rootVC.view,
                   let point = cell.superview?.convertPoint(cell.frame.origin, toView: superview) where point.y < containerView.bounds.size.height / 3 {
                    earlyAlphaAnimation = true
                }
            }
        }
        alphaView.alpha = 0
        
        let relativeStartTime = earlyAlphaAnimation ? 0 : 0.25
        UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1) {
                toVC.view.frame = containerView.bounds
                fromVC.view.transform = CGAffineTransformMakeScale(Const.Scaling, Const.Scaling)
                self.alphaView.alpha = 1
            }
            UIView.addKeyframeWithRelativeStartTime(relativeStartTime, relativeDuration: 0.5) {
                (toVC as? HCPagingViewController)?.viewControllers[.Center]??.cellImageView.alpha = 0
            }
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled()
            if canceled {
                toVC.view.removeFromSuperview()
                toVC.view.clipsToBounds = false
            }
            
            self.alphaView.removeFromSuperview()
            fromVC.view.transform = CGAffineTransformIdentity
            
            transitionContext.completeTransition(!canceled)
        }
    }
}