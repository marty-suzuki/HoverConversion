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
        navigationView.titleLabel.textColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeTableViewCell")
        title = "Following List"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let group = DispatchGroup()
        group.enter()
        twitterManager.fetchUsersTimeline {
            group.leave()
        }
        group.enter()
        twitterManager.fetchUsers {
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            self.twitterManager.sortUsers()
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showPagingViewContoller(indexPath: IndexPath) {
        let vc = HCPagingViewController(indexPath: indexPath)
        vc.dataSource = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if twitterManager.tweets.count == twitterManager.users.count {
            return twitterManager.users.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = twitterManager.users[(indexPath as NSIndexPath).row]
        guard let tweet = twitterManager.tweets[user.screenName]?.first else {
            return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
        cell.userValue = (user, tweet)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HomeTableViewCell.Height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        showPagingViewContoller(indexPath: indexPath)
    }
}

extension HomeViewController: HCPagingViewControllerDataSource {
    func pagingViewController(_ viewController: HCPagingViewController, viewControllerFor indexPath: IndexPath) -> HCContentViewController? {
        guard 0 <= indexPath.row && indexPath.row < twitterManager.users.count else { return nil }
        let vc = UserTimelineViewController()
        vc.user = twitterManager.users[indexPath.row]
        return vc
    }
    
    func pagingViewController(_ viewController: HCPagingViewController, nextHeaderViewFor indexPath: IndexPath) -> HCNextHeaderView? {
        guard 0 <= indexPath.row && indexPath.row < twitterManager.users.count else { return nil }
        let view = NextHeaderView()
        view.user = twitterManager.users[indexPath.row]
        return view
    }
}
