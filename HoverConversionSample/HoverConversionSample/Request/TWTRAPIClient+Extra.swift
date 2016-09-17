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
    case success(T)
    case failure(NSError)
}

struct TWTRResponse<T> {
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Data?
    let result: TWTRResult<T>
}

enum TWTRHTTPMethod: String {
    case GET = "GET"
}

extension TWTRAPIClient {
    func sendTwitterRequest<T: TWTRRequestable>(_ request: T, completion: @escaping (TWTRResponse<T.ResponseType>) -> ()) {
        guard let URL = request.URL else {
            let error = NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil)
            completion(TWTRResponse(request: nil, response: nil, data: nil, result: .failure(error)))
            return
        }
        let absoluteString = URL.absoluteString
        var error: NSError?
        let request = urlRequest(withMethod: request.method.rawValue, url: absoluteString, parameters: request.parameters, error: &error)
        if let error = error {
            completion(TWTRResponse(request: request, response: nil, data: nil, result: .failure(error)))
            return
        }
        sendTwitterRequest(request) {
            let result: TWTRResult<T.ResponseType>
            if let error = $0.2 {
                result = .failure(error as NSError)
            } else if let data = $0.1 {
                switch T.decode(data) {
                case .success(let decodeData):
                    result = .success(decodeData)
                case .failure(let error):
                    result = .failure(error)
                }
            } else {
                result = .failure(NSError(domain: TWTRAPIErrorDomain, code: -9999, userInfo: nil))
            }
            completion(TWTRResponse(request: request, response: $0.0 as? HTTPURLResponse, data: $0.1, result: result))
        }
    }
}
