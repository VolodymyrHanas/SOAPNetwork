//
//  ViewController.swift
//  SOAPExample
//
//  Created by Volodymyr Hanas on 09.04.2020.
//  Copyright © 2020 Volodymyr Hanas. All rights reserved.
//

import UIKit
import SOAPNetwork
import SWXMLHash

class ViewController: UIViewController {
    
    let network = Network(with: URL(string: "http://194.44.223.214:10080/TourSoapTest/TourSoap.dll/soap/ITourSoup")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        network.authorization = Authorization(username: "1CUSER", password: "Robot1111111")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapTestButton(_ sender: Any) {
        let request = GetTourTypeRequest()
        network.request(request, completion: { (result) in
            switch result {
            case .success(let response):
                print(response.data)
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
}

struct GetTourTypeRequest: Request {
    typealias responseObject = ToursList
    var responseKey: String = "NS1:GetTourTypeResponse"
    var body: String = """
<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <GetTourType>
            <Login>1CUSER</Login>
            <Password>Robot1111111</Password>
            <FormatData>0</FormatData>
        </GetTourType>
      </soap:Body>
    </soap:Envelope>
"""
    
}

struct ToursList: Decodable, XMLIndexerDeserializable {
    let TOURTYPE: [Tour]
}

struct Tour: Decodable {
    let ID: Int
    let BACKGROUNDIMAGEURL: String
    let SUBIMAGEURL: String
    let NAME: String
    let SHOWINFIRSTPANEL: Int
    
}

