//
//  Network.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Alamofire
import Foundation

public class Network {
    
    private let baseURL: URL
    private let sessionManager = SessionManager()
    
    public init(with url: URL) {
        self.baseURL = url
    }
    
    public func request<T: Request>(_ request: T, completion: @escaping (Swift.Result<Response<T>, Error>) -> Void) {
        
        let requestURL = createURLRequest(with: request)
        
        sessionManager.request(requestURL).responseJSON { [weak self] response in
            self?.handleResponse(response, completion: completion)
        }
    }
    
    public func upload<T: MultipartRequest>(_ request: T, completion: @escaping (Swift.Result<Response<T>, Error>) -> Void) {
        sessionManager.upload(multipartFormData: { (multipartData) in
            request.multiparts.forEach { value in
                if let value = value as? MultipartFileData {
                    multipartData.append(value.data, withName: value.key, fileName: value.fileName, mimeType: value.mimeType)
                } else {
                    multipartData.append(value.data, withName: value.key)
                }
            }
        }, to: baseURL.appendingPathComponent(request.endpoint), headers: request.headers, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { [weak self] response in
                    self?.handleResponse(response, completion: completion)
                })
            case .failure(let encodingError):
                completion(.failure(encodingError))
            }
        })
    }
    
    public func download(endpoint: String, to destinationURL: URL, completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationURL, [.removePreviousFile])
        }
        
        sessionManager.download(baseURL.appendingPathComponent(endpoint), to: destination).response { response in
            if let responseError = response.error {
                completion(.failure(responseError))
                return
            }
            if let destinationURL = response.destinationURL {
                completion(.success(destinationURL))
            }
        }
    }
    
    public func cancelAllTasks() {
        sessionManager.session.getAllTasks(completionHandler: { tasks in
            tasks.forEach { $0.cancel() }
        })
    }
    
    private func handleResponse<T: Request>(_ response: DataResponse<Any>, completion: @escaping (Swift.Result<Response<T>, Error>) -> Void) {
        if let data = response.data, let statusCode = response.response?.statusCode, response.error == nil {
            let responseObject = try? JSONDecoder().decode(ServerResponse<T>.self, from: data)
            let result = Response<T>(data: responseObject?.data, statusCode: statusCode)
            completion(.success(result))
        } else {
            completion(.failure(response.error!))
        }
    }
    
    private func createURLRequest<T: Request>(with req: T) -> URLRequest {
        
        var request: URLRequest!
        let url = baseURL.appendingPathComponent(req.endpoint)
        
        switch req.queryType {
        case .json:
            request = URLRequest(url: url)
            
            if let params = req.parameters {
                do {
                    let body = try? JSONSerialization.data(withJSONObject: params, options: [])
                    request.httpBody = body
                }
            }
        case .path:
            var query = ""
            
            req.parameters?.forEach { key, value in
                query = query + "\(key)=\(value)&"
            }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.query = query
            request = URLRequest(url: components.url!)
        }
          
        request.allHTTPHeaderFields = req.headers
        request.httpMethod = req.method.rawValue

        return request
    }
}
