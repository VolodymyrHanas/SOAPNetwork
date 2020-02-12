//
//  Request.swift
//  SOAPNetwork
//
//  Created by Volodymyr Hanas on 2/12/20.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import Alamofire

public protocol Request {
    
    associatedtype responseObject: Decodable
    
    var body: String { get }
}
