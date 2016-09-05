//
//  TwitterManager.swift
//  HoverConversionSample
//
//  Created by Taiki Suzuki on 2016/09/03.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterManager {
    private let screenNames: [String] = [
        "tim_cook",
        "SwiftLang",
        "BacktotheFuture",
        "realmikefox",
        "marty_suzuki"
    ]
    
    private(set) var tweets: [String : [TWTRTweet]] = [:]
    private(set) var users: [TWTRUser] = []
    
    private lazy var client = TWTRAPIClient()
    
    func sortUsers() {
        let result = users.flatMap { user -> (TWTRUser, TWTRTweet)? in
            guard let tweet = tweets[user.screenName]?.first else {
                return nil
            }
            return (user, tweet)
        }
        let sortedResult = result.sort { $0.0.1.createdAt.timeIntervalSince1970 > $0.1.1.createdAt.timeIntervalSince1970 }
        users = sortedResult.flatMap { $0.0 }
    }
    
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
        client.loadUserTimeline(screenName: screenName, maxId: nil, count: 1) { (tweets, error) in
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