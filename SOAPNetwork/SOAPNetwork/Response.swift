//
//  Response.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Foundation

public struct Response<T: Request> {
    public let data: T.responseObject?
    public let statusCode: Int
}

struct ServerResponse<T: Request>: Decodable {
    let status: String
    let data: T.responseObject
    let message: String?
}

public protocol ResponseMessage: Decodable {
    var message: String { get }
}

public struct Message: ResponseMessage {
    public var message: String
}
