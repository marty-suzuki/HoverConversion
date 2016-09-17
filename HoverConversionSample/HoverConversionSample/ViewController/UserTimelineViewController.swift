//
//  UserTimelineViewController.swift
//  HoverConversionSample
//
//  Created by Taiki Suzuki on 2016/09/05.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import HoverConversion
import TwitterKit

class UserTimelineViewController: HCContentViewController {
    var user: TWTRUser?
    
    fileprivate var tweets: [TWTRTweet] = []
    fileprivate var hasNext = true
    fileprivate let client = TWTRAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationView.backgroundColor = UIColor(red: 85 / 255, green: 172 / 255, blue: 238 / 255, alpha: 1)
        
        if let user = user {
            navigationView.titleLabel.numberOfLines = 2
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: user.name + "\n", attributes: [
                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14),
                NSForegroundColorAttributeName : UIColor.white
            ]))
            attributedText.append(NSAttributedString(string: "@" + user.screenName, attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 12),
                NSForegroundColorAttributeName : UIColor(white: 1, alpha: 0.6)
            ]))
            navigationView.titleLabel.attributedText = attributedText
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "TWTRTweetTableViewCell")
        tableView.dataSource = self
        loadTweets()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadTweets() {
        guard let user = user , hasNext else { return }
        let oldestTweetId = tweets.first?.tweetID
        let request = StatusesUserTimelineRequest(screenName: user.screenName, maxId: oldestTweetId, count: nil)
        client.sendTwitterRequest(request) { [weak self] in
            switch $0.result {
            case .success(let tweets):
                if tweets.count < 1 {
                    self?.hasNext = false
                    return
                }
                let filterdTweets = tweets.filter { $0.tweetID != oldestTweetId }
                let sortedTweets = filterdTweets.sorted { $0.0.createdAt.timeIntervalSince1970 < $0.1.createdAt.timeIntervalSince1970 }
                guard let storedTweets = self?.tweets else { return }
                self?.tweets = sortedTweets + storedTweets
                self?.tableView.reloadData()
                if let tweets = self?.tweets {
                    let indexPath = IndexPath(row: tweets.count - 2, section: 0)
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            case .failure(let error):
                print(error)
                self?.hasNext = false
            }
        }
    }
}

extension UserTimelineViewController {
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard (indexPath as NSIndexPath).row < tweets.count else { return 0 }
        let tweet = tweets[(indexPath as NSIndexPath).row]
        let width = UIScreen.main.bounds.size.width
        return TWTRTweetTableViewCell.height(for: tweet, style: .compact, width: width, showingActions: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row < 1 {
            //loadTweets()
        }
    }
}

extension UserTimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TWTRTweetTableViewCell") as? TWTRTweetTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        }
        cell.configure(with: tweets[(indexPath as NSIndexPath).row])
        return cell
    }
}
