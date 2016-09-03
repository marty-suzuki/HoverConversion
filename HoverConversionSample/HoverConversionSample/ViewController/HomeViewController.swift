//
//  HomeViewController.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/07/18.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import UIKit
import HoverConversion
import TwitterKit

class HomeViewController: HCRootViewController {

    let twitterManager = TwitterManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let vc = HCPagingViewController()
//        view.addSubview(vc.view)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.registerNib(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let vc = HCPagingViewController()
        //navigationController?.pushViewController(vc, animated: true)
        
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
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}