//
//  TodayViewController.swift
//  TodayGarlicoinWidget
//
//  Created by Marcus Ng on 1/28/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class TodayVC: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var coinsLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceLbl.layer.masksToBounds = true
        coinsLbl.layer.masksToBounds = true
        valueLbl.layer.masksToBounds = true
        priceLbl.layer.cornerRadius = 5
        coinsLbl.layer.cornerRadius = 5
        valueLbl.layer.cornerRadius = 5
    }
    
    func getData(completionHandler: @escaping (_ balance: Double,_ usdPrice: Double,_ success: Bool) -> ()) {
        var ctr = 0
        var coins: Double = 0.0
        var price: Double = 0.0
        
        if let address = defaults?.value(forKey: "WalletAddress") as? String {
            let balanceURL = "https://explorer.grlc-bakery.fun/ext/getbalance/\(address)"
            Alamofire.request(balanceURL).responseJSON(completionHandler: { (response) in
                if let value = response.result.value {
                    let json = JSON(value)
                    if json["error"] != JSON.null {
                        completionHandler(0, 0, false)
                        return
                    }
                    defaults?.set(json.double, forKey: "GRLC")
                    coins = json.double!
                    ctr += 1
                    
                    if ctr == 2 {
                        completionHandler(coins, price, true)
                    }
                }
            })
        }
        
        Alamofire.request(PRICE_URL).responseJSON { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    completionHandler(0, 0, false)
                    return
                }
                if let priceUSD = Double(json[0]["price_usd"].string!) {
                    defaults?.set(priceUSD, forKey: "Price")
                    price = priceUSD
                    ctr += 1
                }
                
                if ctr == 2 {
                    completionHandler(coins, price, true)
                }
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        getData { (balance, usdPrice, success) in
            if success {
                let price: Double = balance * usdPrice
                self.coinsLbl.text = String(describing: balance)
                self.valueLbl.text = self.formattedUSD(usd: price)
                self.priceLbl.text = self.formattedUSD(usd: usdPrice)
                completionHandler(NCUpdateResult.newData)
            } else {
                let savedBalance = defaults?.value(forKey: "GRLC") as? Double
                let savedPrice = defaults?.value(forKey: "Price") as? Double
                let price: Double = savedBalance! * savedPrice!
                self.coinsLbl.text = String(describing: balance)
                self.valueLbl.text = self.formattedUSD(usd: price)
                self.priceLbl.text = self.formattedUSD(usd: savedPrice!)
                completionHandler(NCUpdateResult.noData)
            }
        }
    }
    
}
