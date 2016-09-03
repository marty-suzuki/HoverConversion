//
//  TwitterManager.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/03.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterManager {
    private let screenNames: [String] = [
        "BacktotheFuture",
        "realmikefox"
    ]
    
    private(set) var tweets: [String : [TWTRTweet]] = [:]
    private(set) var users: [TWTRUser] = []
    
    private lazy var client = TWTRAPIClient()
    
    func fetchUsersTimeline(completion: (() -> ())) {
        let group = dispatch_group_create()
        screenNames.forEach {
            dispatch_group_enter(group)
            fetchUserTimeline(screenName: $0) {
                dispatch_group_leave(group)
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    func fetchUserTimeline(screenName screenName: String, completion: (() -> ())) {
        client.loadUserTimeline(screenName: screenName, sinceId: nil, count: 1) { (tweets, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let tweets = tweets else  {
                completion()
                return
            }
            
            guard let userTweets = self.tweets[screenName] else {
                self.tweets[screenName] = tweets
                completion()
                return
            }
            self.tweets[screenName] = Array([userTweets, tweets].flatten())
            completion()
        }
    }
    
    func fetchUsers(completion: (() -> ())) {
        client.loadUsers(screenNames: screenNames) { (users, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let users = users else  {
                completion()
                return
            }
            self.users = users
            completion()
        }
    }
}