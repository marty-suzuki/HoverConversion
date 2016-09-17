//
//  HCRootAnimatedTransitioning.swift
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

class HCRootAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    fileprivate struct Const {
        static let duration: TimeInterval = 0.3
        static let scaling: CGFloat = 0.95
    }
    
    let operation: UINavigationControllerOperation
    fileprivate let alphaView = UIView()
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Const.duration
    }
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = .black
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        alphaView.frame = containerView.bounds
        
        switch operation {
        case .pop: popAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .push: pushAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .none:
            transitionContext.completeTransition(true)
            break
        }
    }
    
    fileprivate func popAnimation(_ transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.insertSubview(alphaView, belowSubview: fromVC.view)
        
        var initialFrame: CGRect?
        if let rootVC = toVC as? HCRootViewController, let pagingVC = fromVC as? HCPagingViewController {
            let indexPath = pagingVC.currentIndexPath
            if rootVC.tableView?.cellForRow(at: indexPath as IndexPath) == nil {
                rootVC.tableView?.scrollToRow(at: indexPath as IndexPath, at: pagingVC.scrollDirection, animated: false)
            }
            
            if let cell = rootVC.tableView?.cellForRow(at: indexPath as IndexPath) {
                if let nullableVC = pagingVC.viewControllers[.center], let centeVC = nullableVC {
                    centeVC.cellImageView.frame = cell.bounds
                    centeVC.cellImageView.image = cell.screenshot()
                }
                
                if let superview = rootVC.view,
                   let point = cell.superview?.convert(cell.frame.origin, to: superview) {
                    var selectedCellFrame: CGRect = .zero
                    selectedCellFrame.origin = point
                    selectedCellFrame.size = cell.bounds.size
                    initialFrame = selectedCellFrame
                }
            }
            
            rootVC.tableView?.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: .none)
        }
        
        fromVC.view.clipsToBounds = true
        alphaView.alpha = 1
        toVC.view.transform = CGAffineTransform(scaleX: Const.scaling, y: Const.scaling)
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext) , delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                (fromVC as? HCPagingViewController)?.viewControllers[.center]??.cellImageView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                (fromVC as? HCPagingViewController)?.containerViews[.center]?.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                if let initialFrame = initialFrame {
                    fromVC.view.frame = initialFrame
                }
                fromVC.view.layoutIfNeeded()
                toVC.view.transform = CGAffineTransform.identity
                self.alphaView.alpha = 0
            }
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled
            if canceled {
                toVC.view.removeFromSuperview()
            } else {
                fromVC.view.removeFromSuperview()
                fromVC.view.clipsToBounds = false
            }
            
            toVC.view.transform = CGAffineTransform.identity
            self.alphaView.removeFromSuperview()
            
            if let pagingVC = fromVC as? HCPagingViewController, let rootVC = toVC as? HCRootViewController {
                let indexPath = pagingVC.currentIndexPath
                rootVC.tableView?.deselectRow(at: indexPath as IndexPath, animated: true)
            }
            transitionContext.completeTransition(!canceled)
        }
    }
    
    fileprivate func pushAnimation(_ transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.addSubview(alphaView)
        containerView.addSubview(toVC.view)
        
        toVC.view.clipsToBounds = true
        
        var earlyAlphaAnimation = false
        if let rootVC = fromVC as? HCRootViewController, let pagingVC = toVC as? HCPagingViewController {
            let indexPath = pagingVC.currentIndexPath
            if let cell = rootVC.tableView?.cellForRow(at: indexPath as IndexPath) {
                if let nullableVC = pagingVC.viewControllers[.center], let centeVC = nullableVC {
                    centeVC.cellImageView.frame = cell.bounds
                    centeVC.cellImageView.image = cell.screenshot()
                }
                if let superview = rootVC.view,
                   let point = cell.superview?.convert(cell.frame.origin, to: superview) {
                    var selectedCellFrame: CGRect = .zero
                    selectedCellFrame.origin = point
                    selectedCellFrame.size = cell.bounds.size
                    toVC.view.frame = selectedCellFrame
                }
                if let superview = rootVC.view,
                   let point = cell.superview?.convert(cell.frame.origin, to: superview) , point.y < containerView.bounds.size.height / 3 {
                    earlyAlphaAnimation = true
                }
            }
        }
        alphaView.alpha = 0
        
        let relativeStartTime = earlyAlphaAnimation ? 0 : 0.25
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toVC.view.frame = containerView.bounds
                fromVC.view.transform = CGAffineTransform(scaleX: Const.scaling, y: Const.scaling)
                self.alphaView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: 0.5) {
                (toVC as? HCPagingViewController)?.viewControllers[.center]??.cellImageView.alpha = 0
            }
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled
            if canceled {
                toVC.view.removeFromSuperview()
                toVC.view.clipsToBounds = false
            }
            
            self.alphaView.removeFromSuperview()
            fromVC.view.transform = CGAffineTransform.identity
            
            transitionContext.completeTransition(!canceled)
        }
    }
}
