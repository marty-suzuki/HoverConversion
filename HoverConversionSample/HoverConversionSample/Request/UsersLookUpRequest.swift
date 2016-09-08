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
    typealias ResponseType = [TWTRUser]
    typealias ParseResultType = [[String : NSObject]]
    
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
    
    static func decode(data: NSData) -> TWTRResult<ResponseType> {
        switch UsersLookUpRequest.parseData(data) {
        case .Success(let parsedData):
            return .Success(parsedData.flatMap { TWTRUser(JSONDictionary: $0) })
        case .Failure(let error):
            return .Failure(error)
        }
    }
}
