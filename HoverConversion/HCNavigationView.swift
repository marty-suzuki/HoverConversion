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
    func navigationView(_ navigationView: HCNavigationView, didTapLeftButton button: UIButton)
    func navigationView(_ navigationView: HCNavigationView, didTapRightButton button: UIButton)
}

open class HCNavigationView: UIView {
    public struct ButtonPosition: OptionSet {
        static let right = ButtonPosition(rawValue: 1 << 0)
        static let left = ButtonPosition(rawValue: 1 << 1)
        
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    open static let height: CGFloat = 64
    
    open var leftButton: UIButton?
    open let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    open var rightButton: UIButton?
    
    weak var delegate: HCNavigationViewDelegate?
    
    public convenience init() {
        self.init(buttonPosition: [])
    }
    
    public init(buttonPosition: ButtonPosition) {
        super.init(frame: .zero)
        if buttonPosition.contains(.left) {
            let leftButton = UIButton(type: .custom)
            addLayoutSubview(leftButton, andConstraints:
                leftButton.left,
                leftButton.bottom,
                leftButton.width |==| leftButton.height,
                leftButton.height |==| 44
            )
            leftButton.setTitle("‹", for: UIControlState())
            leftButton.titleLabel?.font = .systemFont(ofSize: 40)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDown(_:)), for: .touchDown)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragExit(_:)), for: .touchDragExit)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragEnter(_:)), for: .touchDragEnter)
            leftButton.addTarget(self, action: #selector(HCNavigationView.didTouchUpInside(_:)), for: .touchUpInside)
            self.leftButton = leftButton
        }
        if buttonPosition.contains(.right) {
            let rightButton = UIButton(type: .custom)
            addLayoutSubview(rightButton, andConstraints:
                rightButton.right,
                rightButton.bottom,
                rightButton.width |==| rightButton.height,
                rightButton.height |==| 44
            )
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDown(_:)), for: .touchDown)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragExit(_:)), for: .touchDragExit)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchDragEnter(_:)), for: .touchDragEnter)
            rightButton.addTarget(self, action: #selector(HCNavigationView.didTouchUpInside(_:)), for: .touchUpInside)
            self.rightButton = rightButton
        }
        
        var constraints: [MisterFusion] = []
        if let leftButton = leftButton {
            constraints += [leftButton.right |==| titleLabel.left]
        } else {
            constraints += [titleLabel.left |+| 44]
        }
        
        if let rightButton = rightButton {
            constraints += [rightButton.left |==| titleLabel.right]
        } else {
            constraints += [titleLabel.right |-| 44]
        }
        constraints += [
            titleLabel.height |==| 44,
            titleLabel.bottom
        ]
        addLayoutSubview(titleLabel, andConstraints: constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTouchUpInside(_ sender: UIButton) {
        sender.alpha = 1
        if sender == leftButton {
            delegate?.navigationView(self, didTapLeftButton: sender)
        } else if sender == rightButton {
            delegate?.navigationView(self, didTapRightButton: sender)
        }
    }
    
    func didTouchDown(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func didTouchDragExit(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func didTouchDragEnter(_ sender: UIButton) {
        sender.alpha = 1
    }
}
