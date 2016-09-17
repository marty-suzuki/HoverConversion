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
    var baseURL: Foundation.URL? { get }
    var path: String { get }
    var URL: Foundation.URL? { get }
    var parameters: [AnyHashable: Any]? { get }
    static func parseData(_ data: Data) -> TWTRResult<ParseResultType>
    static func decode(_ data: Data) -> TWTRResult<ResponseType>
}

extension TWTRRequestable {
    var baseURL: Foundation.URL? {
        return Foundation.URL(string: "https://api.twitter.com")
    }
    
    var URL: Foundation.URL? {
        return Foundation.URL(string: path, relativeTo: baseURL)
    }
    
    static func parseData(_ data: Data) -> TWTRResult<ParseResultType> {
        do {
            let anyObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let object = anyObject as? ParseResultType else {
                return .failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            }
            return .success(object)
        } catch let error as NSError {
            return .failure(error)
        }
    }
}

protocol TWTRGetRequestable: TWTRRequestable {}
extension TWTRGetRequestable {
    var method: TWTRHTTPMethod {
        return .GET
    }
}
