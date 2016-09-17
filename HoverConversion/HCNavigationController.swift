//
//  HCNavigationController.swift
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

open class HCNavigationController: UINavigationController {
    fileprivate struct Const {
        fileprivate static let queueLabel = "jp.marty-suzuki.HoverConversion.SynchronizationQueue"
        static let synchronizationQueue = DispatchQueue(label: queueLabel, attributes: [])
        static func performBlock(_ block: @escaping () -> ()) {
            synchronizationQueue.async {
                DispatchQueue.main.sync(execute: block)
            }
        }
    }
        
    enum SwipeType {
        case edge, pan, none
        var threshold: CGFloat {
            switch self {
            case .edge: return 0.3
            case .pan: return 0.01
            case .none: return 0
            }
        }
    }
    
    fileprivate let interactiveTransition = UIPercentDrivenInteractiveTransition()
    let interactiveEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    let interactivePanGestureRecognizer = UIPanGestureRecognizer()
    
    fileprivate var isPaning = false
    
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        interactivePopGestureRecognizer?.isEnabled = false
        
        interactiveEdgePanGestureRecognizer.edges = .left
        interactiveEdgePanGestureRecognizer.addTarget(self, action: #selector(HCNavigationController.handleInteractiveEdgePanGesture(_:)))
        interactiveEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(interactiveEdgePanGestureRecognizer)
        
        interactivePanGestureRecognizer.addTarget(self, action: #selector(HCNavigationController.handleInteractivePanGesture(_:)))
        interactivePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(interactivePanGestureRecognizer)
    }
    
    func interactiveEdgePanGestureRecognizerMakesToFail(gesture: UIGestureRecognizer) {
        gesture.require(toFail: interactiveEdgePanGestureRecognizer)
    }
    
    func interactivePanGestureRecognizerMakesToFail(gesture: UIGestureRecognizer) {
        gesture.require(toFail: interactivePanGestureRecognizer)
    }
    
    func handleInteractiveEdgePanGesture(_ edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        handlePanGesture(edgePanGestureRecognizer, swipeType: .edge)
    }
    
    func handleInteractivePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        handlePanGesture(panGestureRecognizer, swipeType: .pan)
    }
    
    fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer, swipeType: SwipeType) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let percentage = min(1, max(0, translation.x / view.bounds.size.width))
        
        switch gesture.state {
        case .began:
            Const.performBlock {
                if self.viewControllers.count < 2 { return }
                self.isPaning = true
                self.popViewController(animated: true)
            }
        case .changed:
            Const.performBlock {
                self.interactiveTransition.update(percentage)
            }
        case .ended, .failed, .possible, .cancelled:
            Const.performBlock {
                self.isPaning = false
                if 0 < velocity.x && swipeType.threshold < percentage {
                    self.interactiveTransition.finish()
                } else {
                    self.interactiveTransition.cancel()
                }
            }
        }
    }
}

extension HCNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isPaning ? interactiveTransition : nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //TODO: initial frame
        switch (fromVC, toVC, isPaning) {
        case (_ as HCRootViewController, _ as HCPagingViewController, _):
            return HCRootAnimatedTransitioning(operation: operation)
        case (_ as HCPagingViewController, _ as HCRootViewController, false):
            return HCRootAnimatedTransitioning(operation: operation)
        default:
            return HCDefaultAnimatedTransitioning(operation: operation)
        }
    }
}

extension HCNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer ,
               gestureRecognizer === interactivePanGestureRecognizer &&
               gestureRecognizer.velocity(in: navigationController?.view).x < 0 {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === interactivePanGestureRecognizer &&
           otherGestureRecognizer === interactiveEdgePanGestureRecognizer {
            return true
        }
        return false
    }
}
