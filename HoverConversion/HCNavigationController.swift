//
//  HCNavigationController.swift
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import UIKit

public class HCNavigationController: UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension HCNavigationController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //TODO: initial frame
        switch (fromVC, toVC) {
        case (_ as HCRootViewController, _ as HCPagingViewController):
            return HCRootAnimatedTransitioning(operation: operation)
        case (_ as HCPagingViewController, _ as HCRootViewController):
            return HCRootAnimatedTransitioning(operation: operation)
        default:
            return HCDefaultAnimatedTransitioning(operation: operation)
        }
    }
}
