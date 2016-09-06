//
//  HCNavigationView.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import MisterFusion

public protocol HCNavigationViewDelegate: class {
    func navigationView(navigationView: HCNavigationView, didTapLeftButton button: UIButton)
    func navigationView(navigationView: HCNavigationView, didTapRightButton button: UIButton)
}

public class HCNavigationView: UIView {
    public struct ButtonPosition: OptionSetType {
        static let Right = ButtonPosition(rawValue: 1 << 0)
        static let Left = ButtonPosition(rawValue: 1 << 1)
        
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    public static let Height: CGFloat = 64
    
    public var leftButton: UIButton?
    public let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(16)
        return label
    }()
    public var rightButton: UIButton?
    
    weak var delegate: HCNavigationViewDelegate?
    
    public convenience init() {
        self.init(buttonPosition: [])
    }
    
    public init(buttonPosition: ButtonPosition) {
        super.init(frame: .zero)
        if buttonPosition.contains(.Left) {
            let leftButton = UIButton(type: .Custom)
            addLayoutSubview(leftButton, andConstraints:
                leftButton.Left,
                leftButton.Bottom,
                leftButton.Width |==| leftButton.Height,
                leftButton.Height |==| 44
            )
            leftButton.setTitle("‹", forState: .Normal)
            leftButton.titleLabel?.font = .systemFontOfSize(40)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDown(_:)), forControlEvents: .TouchDown)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragExit(_:)), forControlEvents: .TouchDragExit)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragEnter(_:)), forControlEvents: .TouchDragEnter)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchUpInside(_:)), forControlEvents: .TouchUpInside)
            self.leftButton = leftButton
        }
        if buttonPosition.contains(.Right) {
            let rightButton = UIButton(type: .Custom)
            addLayoutSubview(rightButton, andConstraints:
                rightButton.Right,
                rightButton.Bottom,
                rightButton.Width |==| rightButton.Height,
                rightButton.Height |==| 44
            )
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDown(_:)), forControlEvents: .TouchDown)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragExit(_:)), forControlEvents: .TouchDragExit)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragEnter(_:)), forControlEvents: .TouchDragEnter)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchUpInside(_:)), forControlEvents: .TouchUpInside)
            self.rightButton = rightButton
        }
        
        var constraints: [MisterFusion] = []
        if let leftButton = leftButton {
            constraints += [leftButton.Right |==| titleLabel.Left]
        } else {
            constraints += [titleLabel.Left |+| 44]
        }
        
        if let rightButton = rightButton {
            constraints += [rightButton.Left |==| titleLabel.Right]
        } else {
            constraints += [titleLabel.Right |-| 44]
        }
        constraints += [
            titleLabel.Height |==| 44,
            titleLabel.Bottom
        ]
        addLayoutSubview(titleLabel, andConstraints: constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTouchUpInside(sender: UIButton) {
        sender.alpha = 1
        if sender == leftButton {
            delegate?.navigationView(self, didTapLeftButton: sender)
        } else if sender == rightButton {
            delegate?.navigationView(self, didTapRightButton: sender)
        }
    }
    
    func didTouchDown(sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func didTouchDragExit(sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func didTouchDragEnter(sender: UIButton) {
        sender.alpha = 1
    }
}
