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
    func pagingViewController<T: UIViewController where T: HCViewContentable>(viewController: HCPagingViewController<T>, viewControllerFor index: Int) -> T?
}

public class HCPagingViewController<T: UIViewController where T: HCViewContentable>: UIViewController {
    public var viewControllers: [HCPagingPosition : T?] = [
        .Upper : nil,
        .Center : nil,
        .Lower : nil
    ]

    private let containerViews: [HCPagingPosition : UIView] = [
        .Upper : UIView(),
        .Center : UIView(),
        .Lower : UIView()
    ]
    
    private var containerViewsAdded = false
    private var currentIndex: Int
    
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
            let vc = dataSource?.pagingViewController(self, viewControllerFor: index),
            let containerView = containerViews[position]
        else { return }
        containerView.addLayoutSubview(vc.view, andConstraints:
            vc.view.Top, vc.view.Right, vc.view.Left, vc.view.Bottom
        )
        viewControllers[position] = vc
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
