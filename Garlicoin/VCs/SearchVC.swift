//
//  SearchVC.swift
//  Garlicoin
//
//  Created by Marcus Ng on 1/25/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchVC: UIViewController {

    @IBOutlet weak var addressTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func searchAddressBtnPressed(_ sender: Any) {
        guard let address = addressTF.text, address != ""  else { return }
        let URL = "https://explorer.grlc-bakery.fun/ext/getbalance/\(address)"
        Alamofire.request(URL).responseJSON(completionHandler: { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    let alert = UIAlertController(title: "Error", message: "There was a problem finding this wallet address. Please try again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                UserDefaults.standard.set(address, forKey: "WalletAddress")
                UserDefaults.standard.set(json.double, forKey: "GRLC")
                
                PriceService.instance.getPriceUSD(completionHandler: { (price, success) in
                    if success {
                        self.performSegue(withIdentifier: TO_DISPLAY, sender: nil)
                    }
                })
                
            }
        })
    }
    

}
