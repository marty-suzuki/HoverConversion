//
//  HCRootViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit

public class HCRootViewController: UIViewController, HCContentable {

    public let tableView: UITableView = .init()
    public let navigationView: HCNavigationView = .init()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addViews()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
