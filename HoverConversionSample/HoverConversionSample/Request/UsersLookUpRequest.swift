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
    
    var parameters: [AnyHashable: Any]? {
        let screenNameValue: String = screenNames.joined(separator: ",")
        let parameters: [AnyHashable: Any] = [
            "screen_name" : screenNameValue,
            "include_entities" : "true"
        ]
        return parameters
    }
    
    static func decode(_ data: Data) -> TWTRResult<ResponseType> {
        switch UsersLookUpRequest.parseData(data) {
        case .success(let parsedData):
            return .success(parsedData.flatMap { TWTRUser(jsonDictionary: $0) })
        case .failure(let error):
            return .failure(error)
        }
    }
}
