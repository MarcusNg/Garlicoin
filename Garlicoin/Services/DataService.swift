//
//  DataService.swift
//  Garlicoin
//
//  Created by Marcus Ng on 1/27/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DataService {
    
    static let instance = DataService()
    
    func getPriceUSD(completionHandler: @escaping (_ price: Double, _ success: Bool) -> ()) {
        Alamofire.request(PRICE_URL).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    completionHandler(0, false)
                    return
                }
                if let priceUSD = Double(json[0]["price_usd"].string!) {
                    defaults?.set(priceUSD, forKey: "Price")
                    completionHandler(priceUSD, true)
                }
            }
        }
    }
    
    func balanceUpdate(address: String, completionHandler: @escaping (_ balance: Double, _ success: Bool) -> ()) {
        let balanceURL = "https://explorer.grlc-bakery.fun/ext/getbalance/\(address)"
        Alamofire.request(balanceURL).responseJSON(completionHandler: { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    completionHandler(0, false)
                    return
                }
                defaults?.set(json.double, forKey: "GRLC")
                completionHandler(json.double!, true)
            }
        })
    }
    
}
