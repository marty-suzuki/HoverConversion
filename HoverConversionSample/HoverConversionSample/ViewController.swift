//
//  ViewController.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/07/18.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import UIKit
import HoverConversion

class ViewController: HCRootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let vc = HCPagingViewController()
//        view.addSubview(vc.view)
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let vc = HCPagingViewController()
        //navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

