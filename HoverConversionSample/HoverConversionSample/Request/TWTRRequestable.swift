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
    associatedtype ResponseType: TWTRResponsable
    var method: TWTRHTTPMethod { get }
    var baseURL: NSURL? { get }
    var path: String { get }
    var URL: NSURL? { get }
    var parameters: [NSObject : AnyObject]? { get }
}

extension TWTRRequestable {
    var baseURL: NSURL? {
        return NSURL(string: "https://api.twitter.com")
    }
    var URL: NSURL? {
        return NSURL(string: path, relativeToURL: baseURL)
    }
}

protocol TWTRGetRequestable: TWTRRequestable {}
extension TWTRGetRequestable {
    var method: TWTRHTTPMethod {
        return .GET
    }
}

protocol TWTRResponsable {
    associatedtype ParseResultType
    static func decode(data: NSData) -> Self?
    static func parseData(data: NSData) -> ParseResultType?
}

extension TWTRResponsable {
    static func parseData(data: NSData) -> ParseResultType? {
        do {
            let anyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            guard let object = anyObject as? ParseResultType else {
                print("failed cast")
                return nil
            }
            return object
        } catch {
            print("catch")
            return nil
        }
    }
}