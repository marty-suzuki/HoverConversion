//
//  HCPagingViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import MisterFusion

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

public enum HCPagingPosition: Int {
    case upper = 1, center = 0, lower = 2
}

public protocol HCPagingViewControllerDataSource : class {
    func pagingViewController(_ viewController: HCPagingViewController, viewControllerFor indexPath: IndexPath) -> HCContentViewController?
    func pagingViewController(_ viewController: HCPagingViewController, nextHeaderViewFor indexPath: IndexPath) -> HCNextHeaderView?
}

open class HCPagingViewController: UIViewController {
    fileprivate struct Const {
        static let fireDistance: CGFloat = 180
        static let bottomTotalSpace = HCNavigationView.height
        static let nextAnimationDuration: TimeInterval = 0.4
        static let previousAnimationDuration: TimeInterval = 0.3
        static fileprivate func calculateRudderBanding(_ distance: CGFloat, constant: CGFloat, dimension: CGFloat) -> CGFloat {
            return (1 - (1 / ((distance * constant / dimension) + 1))) * dimension
        }
    }
    
    open fileprivate(set) var viewControllers: [HCPagingPosition : HCContentViewController?] = [
        .upper : nil,
        .center : nil,
        .lower : nil
    ]

    let containerViews: [HCPagingPosition : UIView] = [
        .upper : UIView(),
        .center : UIView(),
        .lower : UIView()
    ]
    
    fileprivate var containerViewsAdded: Bool = false
    var currentIndexPath: IndexPath
    open fileprivate(set) var isPaging: Bool = false
    fileprivate var isDragging: Bool = false
    fileprivate var isPanning = false
    fileprivate var beginningContentOffset: CGPoint = .zero
    fileprivate(set) var scrollDirection: UITableViewScrollPosition = .none
    
    fileprivate var _alphaView: UIView?
    fileprivate var alphaView: UIView {
        let alphaView: UIView
        if let _alphaView = _alphaView {
            alphaView = _alphaView
        } else {
            alphaView = createAlphaViewAndAddSubview(containerViews[.center])
            _alphaView = alphaView
        }
        return alphaView
    }
    
    fileprivate var nextHeaderView: HCNextHeaderView?
    
    open weak var dataSource: HCPagingViewControllerDataSource? {
        didSet {
            addContainerViews()
            setupViewControllers()
        }
    }
    
    public init(indexPath: IndexPath) {
        self.currentIndexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        addContainerViews()
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return viewController(.center)?.preferredStatusBarStyle ?? .default
    }
    
    fileprivate func createAlphaViewAndAddSubview(_ view: UIView?) -> UIView {
        let alphaView = UIView()
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view?.addLayoutSubview(alphaView, andConstraints:
            alphaView.top, alphaView.left, alphaView.bottom, alphaView.right
        )
        alphaView.isUserInteractionEnabled = false
        alphaView.alpha = 0
        return alphaView
    }
    
    fileprivate func clearAlphaView() {
        _alphaView?.removeFromSuperview()
        _alphaView = nil
    }
    
    fileprivate func clearNextHeaderView() {
        nextHeaderView?.removeFromSuperview()
        nextHeaderView = nil
    }
    
    fileprivate func setScrollsTop() {
        viewControllers.forEach { $0.1?.tableView?.scrollsToTop = $0.0 == .center }
    }
    
    fileprivate func viewController(_ position: HCPagingPosition) -> HCContentViewController? {
        guard let nullableViewController = viewControllers[position] else { return nil }
        return nullableViewController
    }
    
    fileprivate func setupViewControllers() {
        setupViewController(indexPath: currentIndexPath.rowPlus(-1), position: .upper)
        setupViewController(indexPath: currentIndexPath, position: .center)
        setupViewController(indexPath: currentIndexPath.rowPlus(1), position: .lower)
        setScrollsTop()
        let tableView = viewController(.center)?.tableView
        if let _ = viewController(.lower) {
            tableView?.contentInset.bottom = Const.bottomTotalSpace
            tableView?.scrollIndicatorInsets.bottom = Const.bottomTotalSpace
        } else {
            tableView?.contentInset.bottom = 0
            tableView?.scrollIndicatorInsets.bottom = 0
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func setupViewController(indexPath: IndexPath, position: HCPagingPosition) {
        if (indexPath as NSIndexPath).row < 0 || (indexPath as NSIndexPath).section < 0 { return }
        guard
            let vc = dataSource?.pagingViewController(self, viewControllerFor: indexPath)
        else { return }
        addViewController(vc, to: position)
    }
    
    fileprivate func addViewController(_ viewController: HCContentViewController, to position: HCPagingPosition) {
        viewController.scrollDelegate = self
        addView(viewController.view, to: position)
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        viewControllers[position] = viewController
    }
    
    fileprivate func addView(_ view: UIView, to position: HCPagingPosition) {
        guard let containerView = containerViews[position] else { return }
        containerView.addLayoutSubview(view, andConstraints:
            view.top, view.right, view.left, view.bottom
        )
    }
    
    fileprivate func addContainerViews() {
        if containerViewsAdded { return }
        containerViewsAdded = true
        containerViews.sorted { $0.0.rawValue < $1.0.rawValue }.forEach {
            let misterFusion: MisterFusion
            switch $0.0 {
            case .upper: misterFusion = $0.1.bottom |==| view.top
            case .center: misterFusion = $0.1.top
            case .lower: misterFusion = $0.1.top |==| view.bottom
            }
            view.addLayoutSubview($0.1, andConstraints:
                misterFusion, $0.1.height, $0.1.left, $0.1.right
            )
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveToNext(_ scrollView: UIScrollView, offset: CGPoint) {
        guard let _ = viewController(.lower) , viewController(.center)?.canPaging[.next] == true else { return }

        scrollDirection = .bottom
        let value = offset.y - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let headerHeight = HCNavigationView.height
        
        isPaging = true
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        let relativeDuration = TimeInterval(0.25)
        let lowerViewController = viewController(.lower)
        let centerViewController = viewController(.center)
        UIView.animateKeyframes(withDuration: Const.nextAnimationDuration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0 - relativeDuration) {
                lowerViewController?.view.frame.origin.y = -self.view.bounds.size.height + headerHeight
                centerViewController?.view.frame.origin.y = -self.view.bounds.size.height + value + headerHeight
                centerViewController?.navigationView?.frame.origin.y = self.view.bounds.size.height - value - headerHeight
                self.nextHeaderView?.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 1.0 - relativeDuration, relativeDuration: relativeDuration) {
                lowerViewController?.view.frame.origin.y = -self.view.bounds.size.height
                centerViewController?.view.frame.origin.y = -self.view.bounds.size.height + value
            }
        }) { _ in
            let upperViewController = self.viewController(.upper)
            upperViewController?.view.removeFromSuperview()
            centerViewController?.view.removeFromSuperview()
            lowerViewController?.view.removeFromSuperview()
            
            if let lowerView = lowerViewController?.view {
                self.addView(lowerView, to: .center)
            }
            
            if let centerView = centerViewController?.view {
                self.addView(centerView, to: .upper)
            }
            
            centerViewController?.scrollDelegate = nil
            
            upperViewController?.willMove(toParentViewController: self)
            upperViewController?.removeFromParentViewController()
            
            let nextCenterVC = lowerViewController
            let nextUpperVC = centerViewController
            self.viewControllers[.center] = nextCenterVC
            self.viewControllers[.upper] = nextUpperVC
            self.viewControllers[.lower] = nil
            
            self.currentIndexPath = self.currentIndexPath.rowPlus(1)
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndexPath.rowPlus(1)) {
                self.addViewController(newViewController, to: .lower)
                self.viewControllers[.lower] = newViewController
                nextCenterVC?.tableView.contentInset.bottom = Const.bottomTotalSpace
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = Const.bottomTotalSpace
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
    
    func moveToPrevious(_ scrollView: UIScrollView, offset: CGPoint) {
        guard let _ = viewController(.upper) , viewController(.center)?.canPaging[.prev] == true else { return }

        scrollDirection = .top
        isPaging = true
        
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
        let upperViewController = viewController(.upper)
        let centerViewController = viewController(.center)
        UIView.animate(withDuration: Const.previousAnimationDuration, delay: 0, options: .curveLinear, animations: {
            upperViewController?.view.frame.origin.y = self.view.bounds.size.height
            centerViewController?.view.frame.origin.y = self.view.bounds.size.height + offset.y
        }) { finished in
            let lowerViewController = self.viewController(.lower)
            upperViewController?.view.removeFromSuperview()
            centerViewController?.view.removeFromSuperview()
            lowerViewController?.view.removeFromSuperview()
            
            if let upperView = upperViewController?.view {
                self.addView(upperView, to: .center)
            }
            
            if let centerView = centerViewController?.view {
                self.addView(centerView, to: .lower)
            }
            
            centerViewController?.scrollDelegate = nil
            
            lowerViewController?.willMove(toParentViewController: self)
            lowerViewController?.removeFromParentViewController()
            
            let nextCenterVC = upperViewController
            let nextLowerVC = centerViewController
            self.viewControllers[.center] = nextCenterVC
            self.viewControllers[.lower] = nextLowerVC
            self.viewControllers[.upper] = nil
            
            self.currentIndexPath = self.currentIndexPath.rowPlus(-1)
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndexPath.rowPlus(-1)) {
                self.addViewController(newViewController, to: .upper)
                self.viewControllers[.upper] = newViewController
            }
            if let _ = nextLowerVC {
                nextCenterVC?.tableView.contentInset.bottom = Const.bottomTotalSpace
                nextCenterVC?.tableView.scrollIndicatorInsets.bottom = Const.bottomTotalSpace
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
    public func contentViewController(_ viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if isPanning { return }
        
        guard viewController == self.viewController(.center) else { return }
        
        let offset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewSize = scrollView.bounds.size
        if contentSize.height - scrollViewSize.height <= offset.y {
            guard let lowerViewController = self.viewController(.lower) else { return }
            let delta = offset.y - (contentSize.height - scrollViewSize.height)
            lowerViewController.view.frame.origin.y = min(0, -delta)
            let value: CGFloat = scrollView.bottomBounceSize
            if value > Const.bottomTotalSpace {
                let alpha = min(1, max(0, (value - Const.bottomTotalSpace) / Const.fireDistance))
                alphaView.alpha = alpha
            }
            
            if let _ = self.nextHeaderView {
            } else if let view = self.viewController(.lower)?.view,
                      let nhv = dataSource?.pagingViewController(self, nextHeaderViewFor: currentIndexPath.rowPlus(1)) {
                view.addLayoutSubview(nhv, andConstraints:
                    nhv.top, nhv.right, nhv.left, nhv.height |==| HCNavigationView.height
                )
                self.nextHeaderView = nhv
            }
        } else if offset.y < 0 {
            guard
                let upperViewController = self.viewController(.upper),
                let centerViewController = self.viewController(.center)
            else { return }
            let delta = max(0, -offset.y)
            if (currentIndexPath as NSIndexPath).row > 0 {
                let alpha = min(1, max(0, -offset.y / Const.fireDistance))
                alphaView.alpha = alpha
            }
            clearNextHeaderView()
            upperViewController.view.frame.origin.y = delta
            centerViewController.navigationView.frame.origin.y = delta
        } else {
            viewControllers[.lower]??.view.frame.origin.y = 0
            viewControllers[.upper]??.view.frame.origin.y = 0
            viewControllers[.center]??.navigationView.frame.origin.y = 0
            
            clearAlphaView()
            clearNextHeaderView()
        }
        
        if isDragging { return }
        if scrollView.contentSize.height > scrollView.bounds.size.height {
            if offset.y < -Const.fireDistance {
                moveToPrevious(scrollView, offset: offset)
            } else if offset.y > (scrollView.contentSize.height + Const.fireDistance) - scrollView.bounds.size.height {
                moveToNext(scrollView, offset: offset)
            }
        } else {
            if offset.y < -Const.fireDistance {
                moveToPrevious(scrollView, offset: offset)
            } else if offset.y > Const.fireDistance {
                moveToNext(scrollView, offset: CGPoint(x: offset.x, y: offset.y + (scrollView.contentSize.height - scrollView.bounds.size.height)))
            }
        }
    }
    
    public func contentViewController(_ viewController: HCContentViewController, scrollViewWillBeginDragging scrollView: UIScrollView) {
        guard viewController == self.viewController(.center) else { return }
        isDragging = true
    }
    
    public func contentViewController(_ viewController: HCContentViewController, scrollViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard viewController == self.viewController(.center) else { return }
        isDragging = false
    }
    
    public func contentViewController(_ viewController: HCContentViewController, handlePanGesture gesture: UIPanGestureRecognizer) {
        guard let centerViewController = self.viewController(.center)
        , centerViewController == viewController && (currentIndexPath as NSIndexPath).row > 0 && viewController.canPaging[.prev]
        else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let tableView = viewController.tableView
        
        switch gesture.state {
        case .began:
            isPanning = true
            beginningContentOffset = (tableView?.contentOffset)!
            
        case .changed:
            let position = max(0, translation.y)
            let rudderBanding = Const.calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.height)
            
            let headerPosition = max(0, rudderBanding)
            if viewController.navigationView.frame.origin.y != headerPosition {
                viewController.navigationView.frame.origin.y = headerPosition
            }
            
           let tableViewOffset = beginningContentOffset.y - max(0, rudderBanding)
            tableView?.setContentOffset(CGPoint(x: 0, y: tableViewOffset), animated: false)
            
            self.viewController(.upper)?.view.frame.origin.y = headerPosition
            
            alphaView.alpha = min(1, (rudderBanding / Const.fireDistance))
            
        case .cancelled, .ended:
            if velocity.y  > 0 && translation.y > Const.fireDistance && (currentIndexPath as NSIndexPath).row > 0 {
                isPanning = false
                let rudderBanding = Const.calculateRudderBanding(max(0, translation.y), constant: 0.55, dimension: view.frame.size.height)
                moveToPrevious(tableView!, offset: CGPoint(x: 0, y: -rudderBanding))
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    viewController.navigationView.frame.origin.y = 0
                    self.viewController(.upper)?.view.frame.origin.y = 0
                    tableView?.setContentOffset(self.beginningContentOffset, animated: false)
                    self.alphaView.alpha = 0
                }, completion: { finished in
                    self.beginningContentOffset = .zero
                    self.isPanning = false
                }) 
            }
            
        case .failed, .possible:
            break
        }
    }
}
