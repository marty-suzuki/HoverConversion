//
//  HCNavigationController.swift
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

public class HCNavigationController: UINavigationController {
    private struct Const {
        private static let QueueLabel = "jp.marty-suzuki.HoverConversion.SynchronizationQueue"
        static let SynchronizationQueue = dispatch_queue_create(QueueLabel, DISPATCH_QUEUE_SERIAL)
        static func performBlock(block: () -> ()) {
            dispatch_async(SynchronizationQueue) {
                dispatch_sync(dispatch_get_main_queue(), block)
            }
        }
    }
        
    enum SwipeType {
        case Edge, Pan, None
        var threshold: CGFloat {
            switch self {
            case .Edge: return 0.3
            case .Pan: return 0.01
            case .None: return 0
            }
        }
    }
    
    private let interactiveTransition = UIPercentDrivenInteractiveTransition()
    let interactiveEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    let interactivePanGestureRecognizer = UIPanGestureRecognizer()
    
    private var isPaning = false
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        interactivePopGestureRecognizer?.enabled = false
        
        interactiveEdgePanGestureRecognizer.edges = .Left
        interactiveEdgePanGestureRecognizer.addTarget(self, action: #selector(HCNavigationController.handleInteractiveEdgePanGesture(_:)))
        interactiveEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(interactiveEdgePanGestureRecognizer)
        
        interactivePanGestureRecognizer.addTarget(self, action: #selector(HCNavigationController.handleInteractivePanGesture(_:)))
        interactivePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(interactivePanGestureRecognizer)
    }
    
    func interactiveEdgePanGestureRecognizerMakesToFail(gesture gesture: UIGestureRecognizer) {
        gesture.requireGestureRecognizerToFail(interactiveEdgePanGestureRecognizer)
    }
    
    func interactivePanGestureRecognizerMakesToFail(gesture gesture: UIGestureRecognizer) {
        gesture.requireGestureRecognizerToFail(interactivePanGestureRecognizer)
    }
    
    func handleInteractiveEdgePanGesture(edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        handlePanGesture(edgePanGestureRecognizer, swipeType: .Edge)
    }
    
    func handleInteractivePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        handlePanGesture(panGestureRecognizer, swipeType: .Pan)
    }
    
    private func handlePanGesture(gesture: UIPanGestureRecognizer, swipeType: SwipeType) {
        let translation = gesture.translationInView(view)
        let velocity = gesture.velocityInView(view)
        let percentage = min(1, max(0, translation.x / view.bounds.size.width))
        
        switch gesture.state {
        case .Began:
            Const.performBlock {
                if self.viewControllers.count < 2 { return }
                self.isPaning = true
                self.popViewControllerAnimated(true)
            }
        case .Changed:
            Const.performBlock {
                self.interactiveTransition.updateInteractiveTransition(percentage)
            }
        case .Ended, .Failed, .Possible, .Cancelled:
            Const.performBlock {
                self.isPaning = false
                if 0 < velocity.x && swipeType.threshold < percentage {
                    self.interactiveTransition.finishInteractiveTransition()
                } else {
                    self.interactiveTransition.cancelInteractiveTransition()
                }
            }
        }
    }
}

extension HCNavigationController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isPaning ? interactiveTransition : nil
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer where
               gestureRecognizer === interactivePanGestureRecognizer &&
               gestureRecognizer.velocityInView(navigationController?.view).x < 0 {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === interactivePanGestureRecognizer &&
           otherGestureRecognizer === interactiveEdgePanGestureRecognizer {
            return true
        }
        return false
    }
}
