//
//  Response.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import SWXMLHash
import Foundation

public struct Response<T: Request> {
    public let data: T.responseObject?
    public let statusCode: Int
}

struct ServerResponse<T: Request>: Decodable {
    let status: String
    let data: T.responseObject
}

struct SOAPError: LocalizedError, XMLIndexerDeserializable {
    public var errorDescription: String?
    
    static func deserialize(_ element: XMLIndexer) throws -> SOAPError {
        return try SOAPError(errorDescription: element["faultstring"].value())
    }
}

