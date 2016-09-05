//
//  HCPagingViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
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
        addContainerViews()
    }
    
    private func setupViewControllers() {
        setupViewController(index: currentIndex - 1, position: .Upper)
        setupViewController(index: currentIndex, position: .Center)
        setupViewController(index: currentIndex + 1, position: .Lower)
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
//        if (centerIndexPath.row >= talkList.count - 1) {
//            return
//        }
//        
//        scrollDirection = .Bottom
        let value = offset.y - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let headerHeight = HCNavigationView.Height
        
        isPaging = true
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        
//        nextTalkButton?.setNeedsLayout()
//        nextTalkButton?.layoutIfNeeded()
//        nextTalkButtonBottomConstraint?.constant = -view.bounds.size.height + (headerHeight * 2)
        
        let relativeDuration = NSTimeInterval(0.25)
        UIView.animateKeyframesWithDuration(Const.NextAnimationDuration, delay: 0, options: .CalculationModeLinear, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1.0 - relativeDuration) {
                self.viewControllers[.Lower]??.view.frame.origin.y = -self.view.bounds.size.height + headerHeight
                self.viewControllers[.Center]??.view.frame.origin.y = -self.view.bounds.size.height + value + headerHeight
                self.viewControllers[.Center]??.navigationView?.frame.origin.y = self.view.bounds.size.height - value - headerHeight
                
//                self.nextHeaderView?.alpha = 0
//                
//                self.nextTalkButton?.setNeedsLayout()
//                self.nextTalkButton?.layoutIfNeeded()
//                self.nextTalkButton?.alpha = 0
            }
            
            UIView.addKeyframeWithRelativeStartTime(1.0 - relativeDuration, relativeDuration: relativeDuration) {
                self.viewControllers[.Lower]??.view.frame.origin.y = -self.view.bounds.size.height
                self.viewControllers[.Center]??.view.frame.origin.y = -self.view.bounds.size.height + value
            }
        }) { _ in
            self.viewControllers[.Upper]??.view.removeFromSuperview()
            self.viewControllers[.Center]??.view.removeFromSuperview()
            self.viewControllers[.Lower]??.view.removeFromSuperview()
            
            if let lowerView = self.viewControllers[.Lower]??.view {
                self.addView(lowerView, to: .Center)
            }
            
            if let centerView = self.viewControllers[.Center]??.view {
                self.addView(centerView, to: .Upper)
            }
            
            //self.centerViewController?.delegate = nil
            
            self.viewControllers[.Upper]??.willMoveToParentViewController(self)
            self.viewControllers[.Upper]??.removeFromParentViewController()
            
            let exchangeViewController = self.viewControllers[.Center]
            self.viewControllers[.Center] = self.viewControllers[.Lower]
            self.viewControllers[.Upper] = exchangeViewController
            self.viewControllers[.Lower] = nil
            
            self.currentIndex += 1
            if let newViewController = self.dataSource?.pagingViewController(self, viewControllerFor: self.currentIndex + 1) {
                self.addViewController(newViewController, to: .Lower)
                self.viewControllers[.Lower] = newViewController
            }
            
//            self.centerViewController?.delegate = self
//            self.centerViewController?.setupViewController()
//            self.centerViewController?.view.frame = self.centerContainerView.bounds
            
            if self.viewControllers[.Upper]??.tableView?.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height {
                if scrollView.contentSize.height > scrollView.bounds.size.height {
                    self.viewControllers[.Upper]??.tableView?.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height), animated: false)
                } else {
                    self.viewControllers[.Upper]??.tableView?.setContentOffset(.zero, animated: false)
                }
            }
//            self.upperViewController?.setNavigationContainerViewOffset(.zero)
//            self.upperViewController?.resetInputContentViewPosition()
            self.viewControllers[.Upper]??.tableView?.reloadData()
            
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
    private func isCenterViewController(viewContoller: HCContentViewController) -> Bool {
        guard let centerViewController = viewControllers[.Center] else { return false }
        return viewContoller == centerViewController
    }
    
    public func contentViewController(viewController: HCContentViewController, scrollViewDidScroll scrollView: UIScrollView) {
        guard isCenterViewController(viewController) else { return }
        
        let offset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewSize = scrollView.bounds.size
        if contentSize.height - scrollViewSize.height <= offset.y {
            guard let lowerViewController = viewControllers[.Lower] else { return }
            let delta = offset.y - (contentSize.height - scrollViewSize.height)
            lowerViewController?.view.frame.origin.y = min(0, -delta)
        } else if offset.y < 0 {
            guard let upperViewController = viewControllers[.Upper] else { return }
            let delta = max(0, -offset.y)
            upperViewController?.view.frame.origin.y = delta
            viewController.navigationView.frame.origin.y = delta
        } else {
            guard
                let lowerViewController = viewControllers[.Lower],
                let upperViewController = viewControllers[.Upper]
            else { return }
            lowerViewController?.view.frame.origin.y = 0
            upperViewController?.view.frame.origin.y = 0
            viewController.navigationView.frame.origin.y = 0
        }
        
        if isDragging { return }
        if scrollView.contentSize.height > scrollView.bounds.size.height {
            if offset.y < -Const.FireDistance {
                //moveToPrevious(scrollView, offset: offset)
            } else if offset.y > (scrollView.contentSize.height + Const.FireDistance) - scrollView.bounds.size.height {
                moveToNext(scrollView, offset: offset)
            }
        } else {
            if offset.y < -Const.FireDistance {
                //moveToPrevious(scrollView, offset: offset)
            } else if offset.y > Const.FireDistance {
                moveToNext(scrollView, offset: CGPoint(x: offset.x, y: offset.y + (scrollView.contentSize.height - scrollView.bounds.size.height)))
            }
        }
    }
    
    public func contentViewController(viewController: HCContentViewController, scrollViewWillBeginDragging scrollView: UIScrollView) {
        guard isCenterViewController(viewController) else { return }
        isDragging = true
    }
    
    public func contentViewController(viewController: HCContentViewController, scrollViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard isCenterViewController(viewController) else { return }
        isDragging = false
    }
}
