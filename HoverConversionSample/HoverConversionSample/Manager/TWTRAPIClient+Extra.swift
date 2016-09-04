//
//  TWTRAPIClient+Extra.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/04.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRAPIClient {
    typealias TWTRLoadUsersCompletion = ([TWTRUser]?, NSError?) -> Void
    func loadUsers(screenNames screenNames: [String], completion: TWTRLoadUsersCompletion) {
        var error: NSError?
        let screenNameValue: String = screenNames.joinWithSeparator(",")
        let parameter: [NSObject : AnyObject] = [
            "screen_name" : screenNameValue,
            "include_entities" : "true"
        ]
        let urlString = "https://api.twitter.com/1.1/users/lookup.json"
        let urlRequest = URLRequestWithMethod("GET", URL: urlString, parameters: parameter, error: &error)
        sendTwitterRequest(urlRequest) { (response, users: [TWTRUser]?, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let users = users else {
                completion(nil, NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
                return
            }
            completion(users, nil)
        }
    }
    
    func loadUserTimeline(screenName screenName: String, maxId: String?, count: Int?, completion: TWTRLoadTweetsCompletion) {
        var error: NSError?
        var parameter: [NSObject : AnyObject] = [
            "screen_name" : screenName
        ]
        if let maxId = maxId {
            parameter["max_id"] = maxId
        }
        if let count = count {
            parameter["count"] = String(count)
        }
        let urlString = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let urlRequest = URLRequestWithMethod("GET", URL: urlString, parameters: parameter, error: &error)
        sendTwitterRequest(urlRequest) { (response, tweets: [TWTRTweet]?, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let tweets = tweets else {
                completion(nil, NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
                return
            }
            completion(tweets, nil)
        }
    }
}

private enum TWTRResult<T> {
    case Success(T)
    case Failure(NSError)
}

extension TWTRAPIClient {
    private func sendTwitterRequest<T: TWTRJSONConvertible>(request: NSURLRequest, completion: (NSURLResponse?, T?, NSError?) -> Void) {
        sendTwitterRequest(request) { [weak self] in
            let result: TWTRResult<[NSObject : AnyObject]> = self?.parseData($0.1, error: $0.2)
                ?? .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            switch result {
            case .Failure(let error):
                completion($0.0, nil, error)
            case .Success(let dictionary):
                guard let object = T(JSONDictionary: dictionary) else {
                    completion($0.0, nil, NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
                    return
                }
                completion($0.0, object, nil)
            }
        }
    }
    
    private func sendTwitterRequest<T: TWTRJSONConvertible>(request: NSURLRequest, completion: (NSURLResponse?, [T]?, NSError?) -> Void) {
        sendTwitterRequest(request) { [weak self] in
            let result: TWTRResult<[[NSObject : AnyObject]]>? = self?.parseData($0.1, error: $0.2)
            switch result ?? .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil)) {
            case .Failure(let error):
                completion($0.0, nil, error)
            case .Success(let dictionaries):
                let objects: [T] = dictionaries.flatMap { T(JSONDictionary: $0) }
                completion($0.0, objects, nil)
            }
        }
    }
    
    private func parseData<T>(data: NSData?, error: NSError?) -> TWTRResult<T> {
        if let error = error {
            return .Failure(error)
        }
        guard let data = data else {
            return .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
        }
        do {
            let anyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            guard let object = anyObject as? T else {
                return .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            }
            return .Success(object)
        } catch let error as NSError {
            return .Failure(error)
        }
    }
}