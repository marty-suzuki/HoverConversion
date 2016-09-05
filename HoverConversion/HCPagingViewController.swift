//
//  HCPagingViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import MisterFusion

public enum HCPagingPosition: Int {
    case Upper = 1, Center = 0, Lower = 2
}

public protocol HCPagingViewControllerDataSource : class {
    func pagingViewController(viewController: HCPagingViewController, viewControllerFor index: Int) -> HCContentViewController?
}

public class HCPagingViewController: UIViewController {
    private struct Const {
        static let FireDistance: CGFloat = 180
        static let NextAnimationDuration: NSTimeInterval = 0.4
        static let PreviousAnimationDuration: NSTimeInterval = 0.3
    }
    
    public private(set) var viewControllers: [HCPagingPosition : HCContentViewController?] = [
        .Upper : nil,
        .Center : nil,
        .Lower : nil
    ]

    private let containerViews: [HCPagingPosition : UIView] = [
        .Upper : UIView(),
        .Center : UIView(),
        .Lower : UIView()
    ]
    
    private var containerViewsAdded: Bool = false
    private var currentIndex: Int
    private var isDragging: Bool = false
    public private(set) var isPaging: Bool = false
    
    
    public weak var dataSource: HCPagingViewControllerDataSource? {
        didSet {
            addContainerViews()
            setupViewControllers()
        }
    }
    
    public init(index: Int) {
        self.currentIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        addContainerViews()
    }
    
    private func viewController(position: HCPagingPosition) -> HCContentViewController? {
        guard let nullableViewController = viewControllers[position] else { return nil }
        return nullableViewController
    }
    
    private func setupViewControllers() {
        setupViewController(index: currentIndex - 1, position: .Upper)
        setupViewController(index: currentIndex, position: .Center)
        setupViewController(index: currentIndex + 1, position: .Lower)
        let tableView = viewController(.Center)?.tableView
        if let _ = viewController(.Lower) {
            tableView?.contentInset.bottom = 64
            tableView?.scrollIndicatorInsets.bottom = 64
        } else {
            tableView?.contentInset.bottom = 0
            tableView?.scrollIndicatorInsets.bottom = 0
        }
    }
    
    private func setupViewController(index index: Int, position: HCPagingPosition) {
        if index < 0 { return }
        guard
            var vc = dataSource?.pagingViewController(self, viewControllerFor: index)
        else { return }
        addViewController(vc, to: position)
    }
    
    private func addViewController(viewController: HCContentViewController, to position: HCPagingPosition) {
        viewController.scrollDelegate = self
        addView(viewController.view, to: position)
        addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        viewControllers[position] = viewController
    }
    
    private func addView(view: UIView, to position: HCPagingPosition) {
        guard let containerView = containerViews[position] else { return }
        containerView.addLayoutSubview(view, andConstraints:
            view.Top, view.Right, view.Left, view.Bottom
        )
    }
    
    private func addContainerViews() {
        if containerViewsAdded { return }
        containerViewsAdded = true
        containerViews.sort { $0.0.rawValue < $1.0.rawValue }.forEach {
            let misterFusion: MisterFusion
            switch $0.0 {
            case .Upper: misterFusion = $0.1.Bottom |==| view.Top
            case .Center: misterFusion = $0.1.Top
            case .Lower: misterFusion = $0.1.Top |==| view.Bottom
            }
            view.addLayoutSubview($0.1, andConstraints:
                misterFusion, $0.1.Height, $0.1.Left, $0.1.Right
            )
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveToNext(scrollView: UIScrollView, offset: CGPoint) {
        guard let _ = viewController(.Lower) else { return }

//        scrollDirection = .Bottom
        let value = offset.y - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let headerHeight = HCNavigationView.Height
        
        isPaging = true
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
//        nextTalkButton?.setNeedsLayout()
//        nextTalkButton?.layoutIfNeeded()
//        nextTalkButtonBottomConstraint?.constant = -view.bounds.size.height + (headerHeight * 2)
        
        let relativeDuration = NSTimeInterval(0.25)
        
        let lowerViewController = viewController(.Lower)
        let centerViewController = viewController(.Center)
        UIView.animateKeyframesWithDuration(Const.NextAnimationDuration, delay: 0, options: .CalculationModeLinear, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1.0 - relativeDuration) {
                lowerViewController?.view.frame.origin.y = -self.view.bounds.size.height + headerHeight
                centerViewController?.view.frame.origin.y = -self.view.bounds.size.height + value + headerHeight
                centerViewController?.navigationView?.frame.origin.y = self.view.bounds.size.height - value - headerHeight
                
//                self.nextHeaderView?.alpha = 0
//                
//                self.nextTalkButton?.setNeedsLayout()
//                self.nextTalkButton?.layoutIfNeeded()
//                self.nextTalkButton?.alpha = 0
            }
            
            UIView.addKeyframeWithRelativeStartTime(1.0 - relativeDuration, relativeDuration: relativeDuration) {
                lowerViewController?.view.frame.origin.y = -self.view.bounds.size.height
                centerViewController?.view.frame.origin.y = -self.view.bounds.size.height + value
            }
        }) { _ in
            let upperViewController = self.viewController(.Upper)
            upperViewController?.view.removeFromSuperview()
            centerViewController?.view.removeFromSuperview()
            lowerViewController?.view.removeFromSuperview()
            
            if let lowerView = lowerViewController?.view {
                self.addView(lowerView, to: .Center)
            }
            
            if let centerView = centerViewController?.view {
                self.addView(centerView, to: .Upper)
            }
            
            //centerViewController?.delegate = nil
            
            upperViewController?.willMoveToParentViewController(self)
            upperViewController?.removeFromParentViewController()
            
            let nextCenterVC = lowerViewController
            let nextUpperVC = centerViewController
            self.viewControllers[.Center] = nextCenterVC
            self.viewControllers[.Upper] = nextUpperVC
            self.viewControllers[.Lower] = nil
            
            self.currentIndex += 1
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndex + 1) {
                self.addViewController(newViewController, to: .Lower)
                self.viewControllers[.Lower] = newViewController
                nextCenterVC?.tableView.contentInset.bottom = 64
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 64
            } else {
                nextCenterVC?.tableView.contentInset.bottom = 0
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 0
            }
            
//            centerViewController?.delegate = self
//            centerViewController?.setupViewController()
//            centerViewController?.view.frame = self.centerContainerView.bounds
            
            if nextUpperVC?.tableView?.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {
                if scrollView.contentSize.height > scrollView.bounds.size.height {
                    nextUpperVC?.tableView?.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: false)
                } else {
                    nextUpperVC?.tableView?.setContentOffset(.zero, animated: false)
                }
            }
//            upperViewController?.setNavigationContainerViewOffset(.zero)
//            upperViewController?.resetInputContentViewPosition()
            nextUpperVC?.tableView?.reloadData()
            
//            self.setScrollsTop()
//            
//            self.clearAlphaView()
//            self.clearNextHeaderView()
//            self.clearNextTalkButton()
            
            self.isPaging = false
        }
    }
    
    func moveToPrevious(scrollView: UIScrollView, offset: CGPoint) {
        guard let _ = viewController(.Upper) else { return }

        //scrollDirection = .Top
        isPaging = true
        
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        let upperViewController = viewController(.Upper)
        let centerViewController = viewController(.Center)
        UIView.animateWithDuration(Const.PreviousAnimationDuration, delay: 0, options: .CurveLinear, animations: {
            upperViewController?.view.frame.origin.y = self.view.bounds.size.height
            centerViewController?.view.frame.origin.y = self.view.bounds.size.height + offset.y
        }) { finished in
            let lowerViewController = self.viewController(.Lower)
            upperViewController?.view.removeFromSuperview()
            centerViewController?.view.removeFromSuperview()
            lowerViewController?.view.removeFromSuperview()
            
            //centerViewController?.clearCommentViewController()
            
            if let upperView = upperViewController?.view {
                self.addView(upperView, to: .Center)
            }
            
            if let centerView = centerViewController?.view {
                self.addView(centerView, to: .Lower)
            }
            
//            centerViewController?.delegate = nil
//            centerViewController?.talkController.finishWatching()
            
            lowerViewController?.willMoveToParentViewController(self)
            lowerViewController?.removeFromParentViewController()
            
            let nextCenterVC = upperViewController
            let nextLowerVC = centerViewController
            self.viewControllers[.Center] = nextCenterVC
            self.viewControllers[.Lower] = nextLowerVC
            self.viewControllers[.Upper] = nil
            
            self.currentIndex -= 1
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndex - 1) {
                self.addViewController(newViewController, to: .Upper)
                self.viewControllers[.Upper] = newViewController
            }
            if let _ = nextLowerVC {
                nextCenterVC?.tableView.contentInset.bottom = 64
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 64
            } else {
                nextCenterVC?.tableView.contentInset.bottom = 0
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 0
            }
            
//            self.centerViewController?.delegate = self
//            self.centerViewController?.setupViewController()
            
//            self.centerViewController?.view.frame = self.centerContainerView.bounds
//            self.lowerViewController?.view.frame = self.lowerContainerView.bounds
//            self.lowerViewController?.setNavigationContainerViewOffset(.zero)
            nextLowerVC?.tableView?.reloadData()
            
//            self.setScrollsTop()
//            
//            self.clearAlphaView()
//            self.clearNextHeaderView()
//            self.clearNextTalkButton()
            
            self.isPaging = false
        }
    }
}

extension HCPagingViewController: HCContentViewControllerScrollDelegate {
    public func contentViewController(viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView) {
        guard viewController == self.viewController(.Center) else { return }
        
        let offset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewSize = scrollView.bounds.size
        if contentSize.height - scrollViewSize.height <= offset.y {
            guard let lowerViewController = self.viewController(.Lower) else { return }
            let delta = offset.y - (contentSize.height - scrollViewSize.height)
            lowerViewController.view.frame.origin.y = min(0, -delta)
        } else if offset.y < 0 {
            guard
                let upperViewController = self.viewController(.Upper),
                let centerViewController = self.viewController(.Center)
            else { return }
            let delta = max(0, -offset.y)
            upperViewController.view.frame.origin.y = delta
            centerViewController.navigationView.frame.origin.y = delta
        } else {
            guard
                let lowerViewController = self.viewController(.Lower),
                let upperViewController = self.viewController(.Upper),
                let centerViewController = self.viewController(.Center)
            else { return }
            lowerViewController.view.frame.origin.y = 0
            upperViewController.view.frame.origin.y = 0
            centerViewController.navigationView.frame.origin.y = 0
        }
        
        if isDragging { return }
        if scrollView.contentSize.height > scrollView.bounds.size.height {
            if offset.y < -Const.FireDistance {
                moveToPrevious(scrollView, offset: offset)
            } else if offset.y > (scrollView.contentSize.height + Const.FireDistance) - scrollView.bounds.size.height {
                moveToNext(scrollView, offset: offset)
            }
        } else {
            if offset.y < -Const.FireDistance {
                moveToPrevious(scrollView, offset: offset)
            } else if offset.y > Const.FireDistance {
                moveToNext(scrollView, offset: CGPoint(x: offset.x, y: offset.y + (scrollView.contentSize.height - scrollView.bounds.size.height)))
            }
        }
    }
    
    public func contentViewController(viewController: HCContentViewController, scrollViewWillBeginDragging scrollView: UIScrollView) {
        guard viewController == self.viewController(.Center) else { return }
        isDragging = true
    }
    
    public func contentViewController(viewController: HCContentViewController, scrollViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard viewController == self.viewController(.Center) else { return }
        isDragging = false
    }
}
