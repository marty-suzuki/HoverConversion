//
//  UserTimelineViewController.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/05.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import UIKit
import HoverConversion
import TwitterKit

class UserTimelineViewController: HCContentViewController {
    var user: TWTRUser?
    
    private var tweets: [TWTRTweet] = []
    private var hasNext = true
    private let client = TWTRAPIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: "TWTRTweetTableViewCell")
        tableView.dataSource = self
        loadTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadTweets() {
        guard let user = user where hasNext else { return }
        let oldestTweetId = tweets.last?.tweetID
        client.loadUserTimeline(screenName: user.screenName, maxId: oldestTweetId, count: nil) { [weak self] in
            if let error = $1 {
                print(error)
                self?.hasNext = false
                return
            }
            guard let tweets = $0 else {
                self?.hasNext = false
                return
            }
            if tweets.count < 1 {
                self?.hasNext = false
                return
            }
            let filterdTweets = tweets.filter { $0.tweetID != oldestTweetId }
            let sortedTweets = filterdTweets.sort { $0.0.createdAt.timeIntervalSince1970 > $0.1.createdAt.timeIntervalSince1970 }
            self?.tweets += sortedTweets
            self?.tableView.reloadData()
        }
    }
}

extension UserTimelineViewController {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard indexPath.row < tweets.count else { return 0 }
        let tweet = tweets[indexPath.row]
        let width = UIScreen.mainScreen().bounds.size.width
        return TWTRTweetTableViewCell.heightForTweet(tweet, style: .Compact, width: width, showingActions: false)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row + 2 == tweets.count {
            loadTweets()
        }
    }
}

extension UserTimelineViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("TWTRTweetTableViewCell") as? TWTRTweetTableViewCell else {
            return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
        }
        cell.configureWithTweet(tweets[indexPath.row])
        return cell
    }
}