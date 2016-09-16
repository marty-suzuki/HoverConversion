//
//  HCDefaultAnimatedTransitioning.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

class HCDefaultAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    private struct Const {
        static let DefaultDuration: NSTimeInterval = 0.25
        static let RootDuration: NSTimeInterval = 0.4
        static let Scaling: CGFloat = 0.95
    }
    
    let operation: UINavigationControllerOperation
    private let alphaView = UIView()
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        guard
            let toVC = transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromVC = transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)
        else {
            return 0
        }
        switch (fromVC, toVC) {
        case (_ as HCPagingViewController, _ as HCRootViewController): return Const.RootDuration
        case (_ as HCRootViewController, _ as HCPagingViewController): return Const.RootDuration
        default: return Const.DefaultDuration
        }
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView()
        containerView.backgroundColor = .blackColor()
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        alphaView.frame = containerView.bounds
        
        switch operation {
        case .Pop: popAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .Push: pushAnimation(transitionContext, toVC: toVC, fromVC: fromVC, containerView: containerView)
        case .None: transitionContext.completeTransition(true)
        }
    }
    
    private func popAnimation(transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.insertSubview(alphaView, belowSubview: fromVC.view)
        
        if let pagingVC = fromVC as? HCPagingViewController, rootVC = toVC as? HCRootViewController {
            let indexPath = pagingVC.currentIndexPath
            //pagingVC.homeViewTalkContainerView.backgroundColor = .whiteColor()
            if rootVC.tableView?.cellForRowAtIndexPath(indexPath) == nil {
                //rootVC.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: pagingVC.scrollDirection, animated: false)
            }
            rootVC.tableView?.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
        alphaView.alpha = 1
        toVC.view.frame = containerView.bounds
        toVC.view.transform = CGAffineTransformMakeScale(Const.Scaling, Const.Scaling)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
            toVC.view.transform = CGAffineTransformIdentity
            fromVC.view.frame.origin.x = containerView.bounds.size.width
            self.alphaView.alpha = 0
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled()
            if canceled {
                toVC.view.removeFromSuperview()
            } else {
                fromVC.view.removeFromSuperview()
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
        
        toVC.view.frame = containerView.bounds
        toVC.view.frame.origin.x = containerView.bounds.size.width
        alphaView.alpha = 0
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
            fromVC.view.transform = CGAffineTransformMakeScale(Const.Scaling, Const.Scaling)
            self.alphaView.alpha = 1
            toVC.view.frame.origin.x = 0
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled()
            if canceled {
                toVC.view.removeFromSuperview()
            }
            
            self.alphaView.removeFromSuperview()
            fromVC.view.transform = CGAffineTransformIdentity
            
            transitionContext.completeTransition(!canceled)
        }
    }
}
