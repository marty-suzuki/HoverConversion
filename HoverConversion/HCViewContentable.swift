//
//  HCViewContentable.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import MisterFusion

public protocol HCViewControllable: HCNavigationViewDelegate {
    var navigationView: HCNavigationView! { get set }
    var navigatoinContainerView: UIView! { get set }
    var tableView: UITableView! { get set }
    func addViews()
}

extension HCViewControllable where Self: UIViewController {
    public func addViews() {
        navigationView.delegate = self
        view.addLayoutSubview(navigatoinContainerView, andConstraints:
            navigatoinContainerView.top,
            navigatoinContainerView.right,
            navigatoinContainerView.left,
            navigatoinContainerView.height |==| HCNavigationView.height
        )
        
        navigatoinContainerView.addLayoutSubview(navigationView, andConstraints:
            navigationView.top,
            navigationView.right,
            navigationView.left,
            navigationView.bottom
        )
        
        view.addLayoutSubview(tableView, andConstraints:
            tableView.top |==| navigatoinContainerView.bottom,
            tableView.right,
            tableView.left,
            tableView.bottom
        )
        view.bringSubview(toFront: navigatoinContainerView)
    }
    
    public func navigationView(_ navigationView: HCNavigationView, didTapLeftButton button: UIButton) {}
    public func navigationView(_ navigationView: HCNavigationView, didTapRightButton button: UIButton) {}
}

public protocol HCViewContentable: HCViewControllable {
    weak var scrollDelegate: HCContentViewControllerScrollDelegate? { get set }
}
