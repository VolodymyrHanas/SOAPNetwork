//
//  Request.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Alamofire
import SWXMLHash

public protocol Request {
    
    associatedtype responseObject: (Decodable & XMLIndexerDeserializable)
    
    var responseKey: String { get }
    var body: String { get }
}

public struct Authorization {
    let username: String
    let password: String
}
