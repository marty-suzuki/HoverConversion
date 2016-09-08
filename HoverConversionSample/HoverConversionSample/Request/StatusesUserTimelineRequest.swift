//
//  StatusesUserTimelineRequest.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/08.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import Foundation
import TwitterKit

struct StatusesUserTimelineRequest: TWTRGetRequestable {
    typealias ResponseType = [TWTRTweet]
    typealias ParseResultType = [[String : NSObject]]
    
    let path: String = "/1.1/statuses/user_timeline.json"
    
    let screenName: String
    let maxId: String?
    let count: Int?
    
    var parameters: [NSObject : AnyObject]? {
        var parameters: [NSObject : AnyObject] = [
            "screen_name" : screenName
        ]
        if let maxId = maxId {
            parameters["max_id"] = maxId
        }
        if let count = count {
            parameters["count"] = String(count)
        }
        return parameters
    }
    
    static func decode(data: NSData) -> TWTRResult<ResponseType> {
        switch UsersLookUpRequest.parseData(data) {
        case .Success(let parsedData):
            return .Success(parsedData.flatMap { TWTRTweet(JSONDictionary: $0) })
        case .Failure(let error):
            return .Failure(error)
        }
    }
}
