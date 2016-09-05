//
//  HCRootViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

public class HCRootViewController: UIViewController, HCViewControllable {

    public var tableView: UITableView! = UITableView()
    public var navigatoinContainerView: UIView! = UIView()
    public var navigationView: HCNavigationView! = HCNavigationView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addViews()
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
