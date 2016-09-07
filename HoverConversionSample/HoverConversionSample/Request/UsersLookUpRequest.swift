//
//  UsersLookUpRequest.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/08.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import Foundation
import TwitterKit

struct UsersLookUpRequest: TWTRGetRequestable {
    typealias ResponseType = UsersLookUpResponse
    
    let path: String = "/1.1/users/lookup.json"
    
    let screenNames: [String]
    
    var parameters: [NSObject : AnyObject]? {
        let screenNameValue: String = screenNames.joinWithSeparator(",")
        let parameters: [NSObject : AnyObject] = [
            "screen_name" : screenNameValue,
            "include_entities" : "true"
        ]
        return parameters
    }
}

struct UsersLookUpResponse: TWTRResponsable {
    typealias ParseResultType = [[String : NSObject]]
    
    let users: [TWTRUser]
    
    static func decode(data: NSData) -> UsersLookUpResponse? {
        guard let array = parseData(data) else {
            return nil
        }
        return UsersLookUpResponse(users: array.flatMap { TWTRUser(JSONDictionary: $0) })
    }
}