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

protocol IconImageViewLoadable {
    var iconImageView: UIImageView! { get }
    func loadImage(_ url: URL)
}

extension IconImageViewLoadable {
    func loadImage(_ url: URL) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else { return }
                self.iconImageView.image = image
            }
        }
    }
}

class NextHeaderView: HCNextHeaderView, IconImageViewLoadable {
    var user: TWTRUser? {
        didSet {
            guard let user = user else { return }
            setupViews()
            
            titleLabel.numberOfLines = 2
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: user.name + "\n", attributes: [
                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18),
                NSForegroundColorAttributeName : UIColor.white
                ]))
            attributedText.append(NSAttributedString(string: "@" + user.screenName, attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 16),
                NSForegroundColorAttributeName : UIColor(white: 1, alpha: 0.6)
                ]))
            titleLabel.attributedText = attributedText
            
            guard let url = URL(string: user.profileImageLargeURL) else { return }
            loadImage(url)
        }
    }
    
    let iconImageView: UIImageView! = UIImageView(frame: .zero)
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
    
    fileprivate func setupViews() {
        addLayoutSubview(iconImageView, andConstraints:
            iconImageView.top |+| 8,
            iconImageView.left |+| 8,
            iconImageView.bottom |-| 8,
            iconImageView.width |==| iconImageView.height
        )
        
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.lightGray.cgColor
        iconImageView.layer.masksToBounds = true
        
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.top |+| 4,
            titleLabel.right |-| 4,
            titleLabel.left |==| iconImageView.right |+| 16,
            titleLabel.bottom |-| 4
        )
        
        backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }
}
