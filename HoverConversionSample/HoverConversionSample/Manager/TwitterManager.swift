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
    fileprivate let screenNames: [String] = [
        "tim_cook",
        "SwiftLang",
        "BacktotheFuture",
        "realmikefox",
        "marty_suzuki"
    ]
    
    fileprivate(set) var tweets: [String : [TWTRTweet]] = [:]
    fileprivate(set) var users: [TWTRUser] = []
    
    fileprivate lazy var client = TWTRAPIClient()
    
    func sortUsers() {
        let result = users.flatMap { user -> (TWTRUser, TWTRTweet)? in
            guard let tweet = tweets[user.screenName]?.first else {
                return nil
            }
            return (user, tweet)
        }
        let sortedResult = result.sorted { $0.0.1.createdAt.timeIntervalSince1970 > $0.1.1.createdAt.timeIntervalSince1970 }
        users = sortedResult.flatMap { $0.0 }
    }
    
    func fetchUsersTimeline(_ completion: @escaping (() -> ())) {
        let group = DispatchGroup()
        screenNames.forEach {
            group.enter()
            fetchUserTimeline(screenName: $0) {
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    func fetchUserTimeline(screenName: String, completion: @escaping (() -> ())) {
        let request = StatusesUserTimelineRequest(screenName: screenName, maxId: nil, count: 1)
        client.sendTwitterRequest(request) { [weak self] in
            switch $0.result {
            case .success(let tweets):
                guard let userTweets = self?.tweets[screenName] else {
                    self?.tweets[screenName] = tweets
                    completion()
                    return
                }
                self?.tweets[screenName] = Array([userTweets, tweets].joined())
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
    
    func fetchUsers(_ completion: @escaping (() -> ())) {
        let request = UsersLookUpRequest(screenNames: screenNames)
        client.sendTwitterRequest(request) { [weak self] in
            switch $0.result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print(error)
            }
            completion()
        }
    }
}
