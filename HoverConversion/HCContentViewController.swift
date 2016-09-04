//
//  HCContentViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit

public protocol HCContentViewControllerScrollDelegate: class {
    func contentViewController(viewController: HCContentViewController, scrollViewWillBeginDragging scrollView: UIScrollView)
    func contentViewController(viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView)
    func contentViewController(viewController: HCContentViewController, crollViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

public class HCContentViewController: UIViewController, HCViewContentable {
    
    public var tableView: UITableView! = UITableView()
    public var navigationView: HCNavigationView! = HCNavigationView()
    
    public weak var scrollDelegate: HCContentViewControllerScrollDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addViews()
        tableView.delegate = self
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

extension HCContentViewController: UITableViewDelegate {
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollDelegate?.contentViewController(self, scrollViewWillBeginDragging: scrollView)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollDelegate?.contentViewController(self, scrollViewDidScroll: scrollView)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.contentViewController(self, crollViewDidEndDragging: scrollView, willDecelerate: decelerate)
    }
}