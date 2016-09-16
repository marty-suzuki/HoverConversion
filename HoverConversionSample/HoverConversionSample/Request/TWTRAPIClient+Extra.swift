//
//  TWTRAPIClient+Extra.swift
//  HoverConversionSample
//
//  Created by Taiki Suzuki on 2016/09/04.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import Foundation
import TwitterKit

enum TWTRResult<T> {
    case Success(T)
    case Failure(NSError)
}

struct TWTRResponse<T> {
    let request: NSURLRequest?
    let response: NSHTTPURLResponse?
    let data: NSData?
    let result: TWTRResult<T>
}

enum TWTRHTTPMethod: String {
    case GET = "GET"
}

extension TWTRAPIClient {
    func sendTwitterRequest<T: TWTRRequestable>(request: T, completion: (TWTRResponse<T.ResponseType>) -> ()) {
        guard let URL = request.URL, absoluteString = URL.absoluteString else {
            let error = NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil)
            completion(TWTRResponse(request: nil, response: nil, data: nil, result: .Failure(error)))
            return
        }
        var error: NSError?
        let request = URLRequestWithMethod(request.method.rawValue, URL: absoluteString, parameters: request.parameters, error: &error)
        if let error = error {
            completion(TWTRResponse(request: request, response: nil, data: nil, result: .Failure(error)))
            return
        }
        sendTwitterRequest(request) { [weak request] in
            let result: TWTRResult<T.ResponseType>
            if let error = $0.2 {
                result = .Failure(error)
            } else if let data = $0.1 {
                switch T.decode(data) {
                case .Success(let decodeData):
                    result = .Success(decodeData)
                case .Failure(let error):
                    result = .Failure(error)
                }
            } else {
                result = .Failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            }
            completion(TWTRResponse(request: request, response: $0.0 as? NSHTTPURLResponse, data: $0.1, result: result))
        }
    }
}
