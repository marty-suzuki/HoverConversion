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
    typealias ResponseType = StatusesUserTimelineResponse
    
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
}

struct StatusesUserTimelineResponse: TWTRResponsable {
    typealias ParseResultType = [[String : NSObject]]
    
    let tweets: [TWTRTweet]
    
    static func decode(data: NSData) -> StatusesUserTimelineResponse? {
        guard let array = parseData(data) else {
            return nil
        }
        return StatusesUserTimelineResponse(tweets: array.flatMap { TWTRTweet(JSONDictionary: $0) })
    }
}