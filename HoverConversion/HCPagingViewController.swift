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
    func pagingViewController(viewController: HCPagingViewController, viewControllerFor indexPath: NSIndexPath) -> HCContentViewController?
    func pagingViewController(viewController: HCPagingViewController, nextHeaderViewFor indexPath: NSIndexPath) -> HCNextHeaderView?
}

public class HCPagingViewController: UIViewController {
    private struct Const {
        static let FireDistance: CGFloat = 180
        static let BottomTotalSpace = HCNavigationView.Height
        static let NextAnimationDuration: NSTimeInterval = 0.4
        static let PreviousAnimationDuration: NSTimeInterval = 0.3
        static private func calculateRudderBanding(distance: CGFloat, constant: CGFloat, dimension: CGFloat) -> CGFloat {
            return (1 - (1 / ((distance * constant / dimension) + 1))) * dimension
        }
    }
    
    public private(set) var viewControllers: [HCPagingPosition : HCContentViewController?] = [
        .Upper : nil,
        .Center : nil,
        .Lower : nil
    ]

    let containerViews: [HCPagingPosition : UIView] = [
        .Upper : UIView(),
        .Center : UIView(),
        .Lower : UIView()
    ]
    
    private var containerViewsAdded: Bool = false
    var currentIndexPath: NSIndexPath
    public private(set) var isPaging: Bool = false
    private var isDragging: Bool = false
    private var isPanning = false
    private var beginningContentOffset: CGPoint = .zero
    private(set) var scrollDirection: UITableViewScrollPosition = .None
    
    private var _alphaView: UIView?
    private var alphaView: UIView {
        let alphaView: UIView
        if let _alphaView = _alphaView {
            alphaView = _alphaView
        } else {
            alphaView = createAlphaViewAndAddSubview(containerViews[.Center])
            _alphaView = alphaView
        }
        return alphaView
    }
    
    private var nextHeaderView: HCNextHeaderView?
    
    public weak var dataSource: HCPagingViewControllerDataSource? {
        didSet {
            addContainerViews()
            setupViewControllers()
        }
    }
    
    public init(indexPath: NSIndexPath) {
        self.currentIndexPath = indexPath
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
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return viewController(.Center)?.preferredStatusBarStyle() ?? .Default
    }
    
    private func createAlphaViewAndAddSubview(view: UIView?) -> UIView {
        let alphaView = UIView()
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view?.addLayoutSubview(alphaView, andConstraints:
            alphaView.Top, alphaView.Left, alphaView.Bottom, alphaView.Right
        )
        alphaView.userInteractionEnabled = false
        alphaView.alpha = 0
        return alphaView
    }
    
    private func clearAlphaView() {
        _alphaView?.removeFromSuperview()
        _alphaView = nil
    }
    
    private func clearNextHeaderView() {
        nextHeaderView?.removeFromSuperview()
        nextHeaderView = nil
    }
    
    private func setScrollsTop() {
        viewControllers.forEach { $0.1?.tableView?.scrollsToTop = $0.0 == .Center }
    }
    
    private func viewController(position: HCPagingPosition) -> HCContentViewController? {
        guard let nullableViewController = viewControllers[position] else { return nil }
        return nullableViewController
    }
    
    private func setupViewControllers() {
        setupViewController(indexPath: currentIndexPath.rowPlus(-1), position: .Upper)
        setupViewController(indexPath: currentIndexPath, position: .Center)
        setupViewController(indexPath: currentIndexPath.rowPlus(1), position: .Lower)
        setScrollsTop()
        let tableView = viewController(.Center)?.tableView
        if let _ = viewController(.Lower) {
            tableView?.contentInset.bottom = Const.BottomTotalSpace
            tableView?.scrollIndicatorInsets.bottom = Const.BottomTotalSpace
        } else {
            tableView?.contentInset.bottom = 0
            tableView?.scrollIndicatorInsets.bottom = 0
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupViewController(indexPath indexPath: NSIndexPath, position: HCPagingPosition) {
        if indexPath.row < 0 || indexPath.section < 0 { return }
        guard
            var vc = dataSource?.pagingViewController(self, viewControllerFor: indexPath)
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
        guard let _ = viewController(.Lower) where viewController(.Center)?.canPaging == true else { return }

        scrollDirection = .Bottom
        let value = offset.y - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let headerHeight = HCNavigationView.Height
        
        isPaging = true
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        let relativeDuration = NSTimeInterval(0.25)
        let lowerViewController = viewController(.Lower)
        let centerViewController = viewController(.Center)
        UIView.animateKeyframesWithDuration(Const.NextAnimationDuration, delay: 0, options: .CalculationModeLinear, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1.0 - relativeDuration) {
                lowerViewController?.view.frame.origin.y = -self.view.bounds.size.height + headerHeight
                centerViewController?.view.frame.origin.y = -self.view.bounds.size.height + value + headerHeight
                centerViewController?.navigationView?.frame.origin.y = self.view.bounds.size.height - value - headerHeight
                self.nextHeaderView?.alpha = 0
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
            
            centerViewController?.scrollDelegate = nil
            
            upperViewController?.willMoveToParentViewController(self)
            upperViewController?.removeFromParentViewController()
            
            let nextCenterVC = lowerViewController
            let nextUpperVC = centerViewController
            self.viewControllers[.Center] = nextCenterVC
            self.viewControllers[.Upper] = nextUpperVC
            self.viewControllers[.Lower] = nil
            
            self.currentIndexPath = self.currentIndexPath.rowPlus(1)
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndexPath.rowPlus(1)) {
                self.addViewController(newViewController, to: .Lower)
                self.viewControllers[.Lower] = newViewController
                nextCenterVC?.tableView.contentInset.bottom = Const.BottomTotalSpace
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = Const.BottomTotalSpace
            } else {
                nextCenterVC?.tableView.contentInset.bottom = 0
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 0
            }
            
            nextCenterVC?.scrollDelegate = self
            
            if nextUpperVC?.tableView?.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {
                if scrollView.contentSize.height > scrollView.bounds.size.height {
                    nextUpperVC?.tableView?.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: false)
                } else {
                    nextUpperVC?.tableView?.setContentOffset(.zero, animated: false)
                }
            }

            nextUpperVC?.tableView?.reloadData()
            self.setNeedsStatusBarAppearanceUpdate()
            
            self.setScrollsTop()
            self.clearAlphaView()
            self.clearNextHeaderView()
            
            self.isPaging = false
        }
    }
    
    func moveToPrevious(scrollView: UIScrollView, offset: CGPoint) {
        guard let _ = viewController(.Upper) where viewController(.Center)?.canPaging == true else { return }

        scrollDirection = .Top
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
            
            if let upperView = upperViewController?.view {
                self.addView(upperView, to: .Center)
            }
            
            if let centerView = centerViewController?.view {
                self.addView(centerView, to: .Lower)
            }
            
            centerViewController?.scrollDelegate = nil
            
            lowerViewController?.willMoveToParentViewController(self)
            lowerViewController?.removeFromParentViewController()
            
            let nextCenterVC = upperViewController
            let nextLowerVC = centerViewController
            self.viewControllers[.Center] = nextCenterVC
            self.viewControllers[.Lower] = nextLowerVC
            self.viewControllers[.Upper] = nil
            
            self.currentIndexPath = self.currentIndexPath.rowPlus(-1)
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndexPath.rowPlus(-1)) {
                self.addViewController(newViewController, to: .Upper)
                self.viewControllers[.Upper] = newViewController
            }
            if let _ = nextLowerVC {
                nextCenterVC?.tableView.contentInset.bottom = Const.BottomTotalSpace
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = Const.BottomTotalSpace
            } else {
                nextCenterVC?.tableView.contentInset.bottom = 0
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = 0
            }
            
            nextCenterVC?.scrollDelegate = self
            nextLowerVC?.tableView?.reloadData()
            self.setNeedsStatusBarAppearanceUpdate()
            
            self.setScrollsTop()
            self.clearAlphaView()
            self.clearNextHeaderView()
            
            self.isPaging = false
        }
    }
}

extension HCPagingViewController: HCContentViewControllerScrollDelegate {
    public func contentViewController(viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if isPanning { return }
        
        guard viewController == self.viewController(.Center) else { return }
        
        let offset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewSize = scrollView.bounds.size
        if contentSize.height - scrollViewSize.height <= offset.y {
            guard let lowerViewController = self.viewController(.Lower) else { return }
            let delta = offset.y - (contentSize.height - scrollViewSize.height)
            lowerViewController.view.frame.origin.y = min(0, -delta)
            let value: CGFloat = scrollView.bottomBounceSize
            if value > Const.BottomTotalSpace {
                let alpha = min(1, max(0, (value - Const.BottomTotalSpace) / Const.FireDistance))
                alphaView.alpha = alpha
            }
            
            if let _ = self.nextHeaderView {
            } else if let view = self.viewController(.Lower)?.view,
                      let nhv = dataSource?.pagingViewController(self, nextHeaderViewFor: currentIndexPath.rowPlus(1)) {
                view.addLayoutSubview(nhv, andConstraints:
                    nhv.Top, nhv.Right, nhv.Left, nhv.Height |==| HCNavigationView.Height
                )
                self.nextHeaderView = nhv
            }
        } else if offset.y < 0 {
            guard
                let upperViewController = self.viewController(.Upper),
                let centerViewController = self.viewController(.Center)
            else { return }
            let delta = max(0, -offset.y)
            if currentIndexPath.row > 0 {
                let alpha = min(1, max(0, -offset.y / Const.FireDistance))
                alphaView.alpha = alpha
            }
            clearNextHeaderView()
            upperViewController.view.frame.origin.y = delta
            centerViewController.navigationView.frame.origin.y = delta
        } else {
            viewControllers[.Lower]??.view.frame.origin.y = 0
            viewControllers[.Upper]??.view.frame.origin.y = 0
            viewControllers[.Center]??.navigationView.frame.origin.y = 0
            
            clearAlphaView()
            clearNextHeaderView()
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
    
    public func contentViewController(viewController: HCContentViewController, handlePanGesture gesture: UIPanGestureRecognizer) {
        guard let centerViewController = self.viewController(.Center)
        where centerViewController == viewController && currentIndexPath.row > 0 && viewController.canPaging
        else { return }
        
        let translation = gesture.translationInView(view)
        let velocity = gesture.velocityInView(view)
        let tableView = viewController.tableView
        
        switch gesture.state {
        case .Began:
            isPanning = true
            beginningContentOffset = tableView.contentOffset
            
        case .Changed:
            let position = max(0, translation.y)
            let rudderBanding = Const.calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.height)
            
            let headerPosition = max(0, rudderBanding)
            if viewController.navigationView.frame.origin.y != headerPosition {
                viewController.navigationView.frame.origin.y = headerPosition
            }
            
           let tableViewOffset = beginningContentOffset.y - max(0, rudderBanding)
            tableView.setContentOffset(CGPoint(x: 0, y: tableViewOffset), animated: false)
            
            self.viewController(.Upper)?.view.frame.origin.y = headerPosition
            
            alphaView.alpha = min(1, (rudderBanding / Const.FireDistance))
            
        case .Cancelled, .Ended:
            if velocity.y  > 0 && translation.y > Const.FireDistance && currentIndexPath.row > 0 {
                isPanning = false
                let rudderBanding = Const.calculateRudderBanding(max(0, translation.y), constant: 0.55, dimension: view.frame.size.height)
                moveToPrevious(tableView, offset: CGPoint(x: 0, y: -rudderBanding))
            } else {
                UIView.animateWithDuration(0.25, animations: {
                    viewController.navigationView.frame.origin.y = 0
                    self.viewController(.Upper)?.view.frame.origin.y = 0
                    tableView.setContentOffset(self.beginningContentOffset, animated: false)
                    self.alphaView.alpha = 0
                }) { finished in
                    self.beginningContentOffset = .zero
                    self.isPanning = false
                }
            }
            
        case .Failed, .Possible:
            break
        }
    }
}
