//
//  HCContentViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

public protocol HCContentViewControllerScrollDelegate: class {
    func contentViewController(_ viewController: HCContentViewController, scrollViewWillBeginDragging scrollView: UIScrollView)
    func contentViewController(_ viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView)
    func contentViewController(_ viewController: HCContentViewController, scrollViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func contentViewController(_ viewController: HCContentViewController, handlePanGesture gesture: UIPanGestureRecognizer)
}

public struct PagableHandler {
    public enum Direction {
        case prev, next
    }
    
    private var values: [Direction : Bool] = [
        .prev : true,
        .next : true
    ]
    
    public subscript(direction: Direction) -> Bool {
        get {
            return values[direction] ?? false
        }
        set {
            values[direction] = newValue
        }
    }
}

open class HCContentViewController: UIViewController, HCViewContentable {
    
    open var tableView: UITableView! = UITableView()
    open var navigatoinContainerView: UIView! = UIView()
    open var navigationView: HCNavigationView! = HCNavigationView(buttonPosition: .left)
    let cellImageView = UIImageView(frame: .zero)
    
    open weak var scrollDelegate: HCContentViewControllerScrollDelegate?
    open var canPaging: PagableHandler = PagableHandler()
    
    open override var title: String? {
        didSet {
            navigationView?.titleLabel.text = title
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        addViews()
        tableView.delegate = self
        view.addSubview(cellImageView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HCContentViewController.handleNavigatoinContainerViewPanGesture(_:)))
        navigatoinContainerView.addGestureRecognizer(panGestureRecognizer)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func navigationView(_ navigationView: HCNavigationView, didTapLeftButton button: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func handleNavigatoinContainerViewPanGesture(_ gesture: UIPanGestureRecognizer) {
        scrollDelegate?.contentViewController(self, handlePanGesture: gesture)
    }
}

extension HCContentViewController: UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.contentViewController(self, scrollViewWillBeginDragging: scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.contentViewController(self, scrollViewDidScroll: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.contentViewController(self, scrollViewDidEndDragging: scrollView, willDecelerate: decelerate)
    }
}
