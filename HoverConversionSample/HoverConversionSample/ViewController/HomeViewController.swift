//
//  HomeViewController.swift
//  HoverConversionSample
//
//  Created by Taiki Suzuki on 2016/07/18.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit
import HoverConversion
import TwitterKit

class HomeViewController: HCRootViewController {

    let twitterManager = TwitterManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationView.backgroundColor = UIColor(red: 85 / 255, green: 172 / 255, blue: 238 / 255, alpha: 1)
        navigationView.titleLabel.textColor = .whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.registerNib(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        title = "Following List"
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        twitterManager.fetchUsersTimeline {
            dispatch_group_leave(group)
        }
        dispatch_group_enter(group)
        twitterManager.fetchUsers {
            dispatch_group_leave(group)
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.twitterManager.sortUsers()
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showPagingViewContoller(index index: Int) {
        let vc = HCPagingViewController(index: index)
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if twitterManager.tweets.count == twitterManager.users.count {
            return twitterManager.users.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = twitterManager.users[indexPath.row]
        guard let tweet = twitterManager.tweets[user.screenName]?.first else {
            return tableView.dequeueReusableCellWithIdentifier("UITableViewCell")!
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTableViewCell") as! HomeTableViewCell
        cell.userValue = (user, tweet)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HomeTableViewCell.Height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        showPagingViewContoller(index: indexPath.row)
    }
}

extension HomeViewController: HCPagingViewControllerDataSource {
    func pagingViewController(viewController: HCPagingViewController, viewControllerFor index: Int) -> HCContentViewController? {
        guard 0 <= index && index < twitterManager.users.count else { return nil }
        let vc = UserTimelineViewController()
        vc.user = twitterManager.users[index]
        return vc
    }
}
