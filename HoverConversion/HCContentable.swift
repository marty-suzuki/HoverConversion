//
//  HCContentable.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit
import MisterFusion

public protocol HCContentable {
    var navigationView: HCNavigationView { get }
    var tableView: UITableView { get }
    func addViews()
}

extension HCContentable where Self: UIViewController {
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