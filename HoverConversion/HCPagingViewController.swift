//
//  HCPagingViewController.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit
import MisterFusion

public class HCPagingViewController: UIViewController {
    public enum Position: Int {
        case Upper = 1, Center = 0, Lower = 2
    }
    
    public var viewControllers: [Position : UIViewController?] = [
        .Upper : nil,
        .Center : nil,
        .Lower : nil
    ]

    private let containerViews: [Position : UIView] = [
        .Upper : UIView(),
        .Center : UIView(),
        .Lower : UIView()
    ]
    
    public private(set) var centerIndexPath: NSIndexPath? = NSIndexPath(forRow: 1, inSection: 0)
    public private(set) var contentDataList: [AnyObject] = [0,1,2]
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addContainerViews()
        
        guard let centerIndexPath  = centerIndexPath else { return }
        
        if centerIndexPath.row > 0 {
            let upperView = containerViews[.Upper]!
            let vc = HCContentViewController()
            upperView.addLayoutSubview(vc.view, andConstraints:
                vc.view.Top, vc.view.Right, vc.view.Left, vc.view.Bottom
            )
            viewControllers[.Upper] = vc
        }
        
        let centerView = containerViews[.Center]!
        let vc = HCContentViewController()
        centerView.addLayoutSubview(vc.view, andConstraints:
            vc.view.Top, vc.view.Right, vc.view.Left, vc.view.Bottom
        )
        viewControllers[.Center] = vc
        
        if centerIndexPath.row + 1 < contentDataList.count {
            let lowerView = containerViews[.Lower]!
            let vc = HCContentViewController()
            lowerView.addLayoutSubview(vc.view, andConstraints:
                vc.view.Top, vc.view.Right, vc.view.Left, vc.view.Bottom
            )
            viewControllers[.Lower] = vc
        }
    }
    
    private func addContainerViews() {
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
