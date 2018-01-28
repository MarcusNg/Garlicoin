//
//  PriceService.swift
//  Garlicoin
//
//  Created by Marcus Ng on 1/27/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class PriceService {
    
    static let instance = PriceService()
    
    func getPriceUSD(completionHandler: @escaping (_ price: Double, _ success: Bool) -> ()) {
        Alamofire.request(PRICE_URL).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    completionHandler(0, false)
                    return
                }
                if let priceUSD = Double(json[0]["price_usd"].string!) {
                    UserDefaults.standard.set(priceUSD, forKey: "Price")
                    completionHandler(priceUSD, true)
                }
            }
        }
    }
    
}
