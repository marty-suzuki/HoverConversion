//
//  NextHeaderView.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/13.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import UIKit
import HoverConversion
import TwitterKit
import MisterFusion

class NextHeaderView: HCNextHeaderView {
    var user: TWTRUser? {
        didSet {
            guard let user = user else { return }
            setupViews()
            
            titleLabel.numberOfLines = 2
            let attributedText = NSMutableAttributedString()
            attributedText.appendAttributedString(NSAttributedString(string: user.name + "\n", attributes: [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
                NSForegroundColorAttributeName : UIColor.whiteColor()
                ]))
            attributedText.appendAttributedString(NSAttributedString(string: "@" + user.screenName, attributes: [
                NSFontAttributeName : UIFont.systemFontOfSize(16),
                NSForegroundColorAttributeName : UIColor(white: 1, alpha: 0.6)
                ]))
            titleLabel.attributedText = attributedText
            
            guard let url = NSURL(string: user.profileImageLargeURL) else { return }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                guard let data = NSData(contentsOfURL: url) else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    guard let image = UIImage(data: data) else { return }
                    self.iconImageView.image = image
                }
            }
        }
    }
    
    let iconImageView: UIImageView = UIImageView(frame: .zero)
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.bounds.size.height / 2
    }
    
    private func setupViews() {
        addLayoutSubview(iconImageView, andConstraints:
            iconImageView.Top |+| 8,
            iconImageView.Left |+| 8,
            iconImageView.Bottom |-| 8,
            iconImageView.Width |==| iconImageView.Height
        )
        
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        iconImageView.layer.masksToBounds = true
        
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.Top |+| 4,
            titleLabel.Right |-| 4,
            titleLabel.Left |==| iconImageView.Right |+| 16,
            titleLabel.Bottom |-| 4
        )
        
        backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }
}
