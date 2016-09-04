//
//  HCContentable.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit
import MisterFusion

public protocol HCViewControllable {
    var navigationView: HCNavigationView! { get set }
    var tableView: UITableView! { get set }
    func addViews()
}

extension HCViewControllable where Self: UIViewController {
    public func addViews() {
        view.addLayoutSubview(navigationView, andConstraints:
            navigationView.Top,
            navigationView.Right,
            navigationView.Left,
            navigationView.Height |=| HCNavigationView.Height
        )
        
        view.addLayoutSubview(tableView, andConstraints:
            tableView.Top |==| navigationView.Bottom,
            tableView.Right,
            tableView.Left,
            tableView.Bottom
        )
    }
}

public protocol HCViewContentable: HCViewControllable {
    weak var scrollDelegate: HCContentViewControllerScrollDelegate? { get set }
}
