//
//  HCRootViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

open class HCRootViewController: UIViewController, HCViewControllable {

    open var tableView: UITableView! = UITableView()
    open var navigatoinContainerView: UIView! = UIView()
    open var navigationView: HCNavigationView! = HCNavigationView()
    
    open override var title: String? {
        didSet {
            navigationView?.titleLabel.text = title
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addViews()
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
