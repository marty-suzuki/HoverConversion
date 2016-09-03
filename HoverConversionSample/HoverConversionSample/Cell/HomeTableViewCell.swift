//
//  HomeTableViewCell.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/04.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import UIKit
import TwitterKit

class HomeTableViewCell: UITableViewCell {
    static let Height: CGFloat = 80
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var latestTweetLabel: UILabel!
    
    var userValue: (TWTRUser, TWTRTweet)? {
        didSet {
            guard let value = userValue else { return }
            let user = value.0
            if let url = NSURL(string: user.profileImageLargeURL) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    guard let data = NSData(contentsOfURL: url) else { return }
                    dispatch_async(dispatch_get_main_queue()) {
                        guard let image = UIImage(data: data) else { return }
                        self.iconImageView.image = image
                    }
                }
            }
            userNameLabel.text = user.name
            screenNameLabel.text = "@" + user.screenName
            latestTweetLabel.text = value.1.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
