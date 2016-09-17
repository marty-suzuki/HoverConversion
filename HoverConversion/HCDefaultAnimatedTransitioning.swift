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
    fileprivate struct Const {
        static let defaultDuration: TimeInterval = 0.25
        static let rootDuration: TimeInterval = 0.4
        static let scaling: CGFloat = 0.95
    }
    
    let operation: UINavigationControllerOperation
    fileprivate let alphaView = UIView()
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
        super.init()
    }
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard
            let toVC = transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)
        else {
            return 0
        }
        switch (fromVC, toVC) {
        case (_ as HCPagingViewController, _ as HCRootViewController): return Const.rootDuration
        case (_ as HCRootViewController, _ as HCPagingViewController): return Const.rootDuration
        default: return Const.defaultDuration
        }
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
        case .none: transitionContext.completeTransition(true)
        }
    }
    
    fileprivate func popAnimation(_ transitionContext: UIViewControllerContextTransitioning, toVC: UIViewController, fromVC: UIViewController, containerView: UIView) {
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.insertSubview(alphaView, belowSubview: fromVC.view)
        
        if let pagingVC = fromVC as? HCPagingViewController, let rootVC = toVC as? HCRootViewController {
            let indexPath = pagingVC.currentIndexPath
            //pagingVC.homeViewTalkContainerView.backgroundColor = .whiteColor()
            if rootVC.tableView?.cellForRow(at: indexPath as IndexPath) == nil {
                //rootVC.tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: pagingVC.scrollDirection, animated: false)
            }
            rootVC.tableView?.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)
        }
        
        alphaView.alpha = 1
        toVC.view.frame = containerView.bounds
        toVC.view.transform = CGAffineTransform(scaleX: Const.scaling, y: Const.scaling)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            toVC.view.transform = CGAffineTransform.identity
            fromVC.view.frame.origin.x = containerView.bounds.size.width
            self.alphaView.alpha = 0
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled
            if canceled {
                toVC.view.removeFromSuperview()
            } else {
                fromVC.view.removeFromSuperview()
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
        
        toVC.view.frame = containerView.bounds
        toVC.view.frame.origin.x = containerView.bounds.size.width
        alphaView.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: {
            fromVC.view.transform = CGAffineTransform(scaleX: Const.scaling, y: Const.scaling)
            self.alphaView.alpha = 1
            toVC.view.frame.origin.x = 0
        }) { finished in
            let canceled = transitionContext.transitionWasCancelled
            if canceled {
                toVC.view.removeFromSuperview()
            }
            
            self.alphaView.removeFromSuperview()
            fromVC.view.transform = CGAffineTransform.identity
            
            transitionContext.completeTransition(!canceled)
        }
    }
}
