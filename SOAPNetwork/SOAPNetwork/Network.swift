//
//  Network.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Alamofire
import SWXMLHash

public class Network {
    
    private let baseURL: URL
    private let session = Session()
    
    public var authorization: Authorization?
    
    public init(with url: URL) {
        self.baseURL = url
    }
    
    public func request<T: Request>(_ request: T, completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        let requestURL = createURLRequest(with: request)
        
        session.request(requestURL).response(completionHandler: { response in
            self.handle(response, with: completion)
        })
    }
    
    public func cancelAllTasks() {
        session.session.getAllTasks(completionHandler: { tasks in
            tasks.forEach { $0.cancel() }
        })
    }
    
    private func handle<T: Request>(_ response: AFDataResponse<Data?>,with completion: @escaping (Result<Response<T>, Error>) -> Void) {
        if let data = response.data, let statusCode = response.response?.statusCode, response.error == nil {
            let responseObject = try? JSONDecoder().decode(ServerResponse<T>.self, from: data)
            let result = Response<T>(data: responseObject?.data, statusCode: statusCode)
            completion(.success(result))
        } else {
            completion(.failure(response.error!))
        }
    }
    
    private func createURLRequest<T: Request>(with req: T) -> URLRequest {
        
        var request = URLRequest(url: baseURL)
        
        let body = try? JSONSerialization.data(withJSONObject: req.body, options: [])
        request.httpBody = body
        
        if let authorization = authorization {
            let loginString = String(format: "%@:%@", authorization.username, authorization.password)
            let loginData = loginString.data(using: .utf8)!
            let base64LoginString = loginData.base64EncodedString()
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        return request
    }
}
