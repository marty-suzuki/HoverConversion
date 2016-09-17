//
//  HomeTableViewCell.swift
//  HoverConversionSample
//
//  Created by Taiki Suzuki on 2016/09/04.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import TwitterKit

class HomeTableViewCell: UITableViewCell, IconImageViewLoadable {
    static let Height: CGFloat = 80
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var latestTweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var userValue: (TWTRUser, TWTRTweet)? {
        didSet {
            guard let value = userValue else { return }
            let user = value.0
            if let url = URL(string: user.profileImageLargeURL) {
                loadImage(url)
            }
            userNameLabel.text = user.name
            screenNameLabel.text = "@" + user.screenName
            let tweet = value.1
            latestTweetLabel.text = tweet.text
            timestampLabel.text = tweet.createdAt.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = iconImageView.bounds.size.height / 2
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = UIColor.lightGray.cgColor
        iconImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
