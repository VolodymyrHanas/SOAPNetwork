//
//  Network.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Alamofire
import SWXMLHash
import Foundation

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
            self.handle(response, for: request, with: completion)
        })
    }
    
    public func cancelAllTasks() {
        session.session.getAllTasks(completionHandler: { tasks in
            tasks.forEach { $0.cancel() }
        })
    }
    
    private func handle<T: Request>(_ response: AFDataResponse<Data?>, for request: T, with completion: @escaping (Result<Response<T>, Error>) -> Void) {
        
        if let error = response.error {
            completion(.failure(error))
        }
        
        if let data = response.data {
            let xml = SWXMLHash.parse(data)
            
            if let responseBody = try? xml.byKey("SOAP-ENV:Envelope").byKey("SOAP-ENV:Body").byKey(request.responseKey) {
                
                var responseObject: T.responseObject?
                
                if let jsonData = responseBody["return"].element?.text.data(using: .utf8) {
                    responseObject = try? JSONDecoder().decode(T.responseObject.self, from: jsonData)
                } else {
                    responseObject = try? T.responseObject.deserialize(responseBody)
                }
                
                completion(.success(Response(data: responseObject, statusCode: response.response?.statusCode ?? 0)))
                
            } else {
                let failBody = xml["SOAP-ENV:Envelope"]["SOAP-ENV:Fault"]
                completion(.failure(try! SOAPError.deserialize(failBody)))
            }
        }
    }
    
    private func createURLRequest<T: Request>(with req: T) -> URLRequest {
        
        var request = URLRequest(url: baseURL)
        
        request.httpBody = req.body.data(using: .utf8)
        
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
