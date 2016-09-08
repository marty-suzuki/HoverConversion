//
//  TWTRRequestable.swift
//  HoverConversionSample
//
//  Created by 鈴木大貴 on 2016/09/08.
//  Copyright © 2016年 szk-atmosphere. All rights reserved.
//

import Foundation
import TwitterKit

protocol TWTRRequestable {
    associatedtype ResponseType
    associatedtype ParseResultType
    var method: TWTRHTTPMethod { get }
    var baseURL: NSURL? { get }
    var path: String { get }
    var URL: NSURL? { get }
    var parameters: [NSObject : AnyObject]? { get }
    static func parseData(data: NSData) -> TWTRResult<ParseResultType>
    static func decode(data: NSData) -> TWTRResult<ResponseType>
}

extension TWTRRequestable {
    var baseURL: NSURL? {
        return NSURL(string: "https://api.twitter.com")
    }
    
    var URL: NSURL? {
        return NSURL(string: path, relativeToURL: baseURL)
    }
    
    static func parseData(data: NSData) -> TWTRResult<ParseResultType> {
        do {
            let anyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            guard let object = anyObject as? ParseResultType else {
                return .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            }
            return .Success(object)
        } catch let error as NSError {
            return .Failure(error)
        }
    }
}

protocol TWTRGetRequestable: TWTRRequestable {}
extension TWTRGetRequestable {
    var method: TWTRHTTPMethod {
        return .GET
    }
}
