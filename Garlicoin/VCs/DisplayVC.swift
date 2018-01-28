//
//  DisplayVC.swift
//  Garlicoin
//
//  Created by Marcus Ng on 1/25/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftSoup
import SwiftyJSON

class DisplayVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coinsLbl: UILabel!
//    @IBOutlet weak var QRCodeBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    let refreshControl = UIRefreshControl()
    let imageView = UIImageView()
    
    var address: String?
//    var showQRCode: Bool = false
    var timestamps = [String]()
    var amounts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 0.992, green: 0.892, blue: 0.536, alpha: 1.0)
        tableView.addSubview(refreshControl)
        
        if let walletAddress = UserDefaults.standard.string(forKey: "WalletAddress") {
            address = walletAddress
            addressLbl.text = "\(walletAddress)"
            if let grlc = UserDefaults.standard.double(forKey: "GRLC") as? Double {
                coinsLbl.text = String(describing: grlc)
                if let usdPrice = UserDefaults.standard.double(forKey: "Price") as? Double {
                    let price: Double = grlc * usdPrice
                    valueLbl.text = formattedUSD(usd: price)
                    priceLbl.text = formattedUSD(usd: usdPrice)
                }
            }
        }

        update { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func copyAddressBtnPressed(_ sender: Any) {
        guard let wAddress = address else { return }
        let alert = UIAlertController(title: "Copy Wallet Address", message: wAddress, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            UIPasteboard.general.string = wAddress
            let confirm = UIAlertController(title: "Success", message: "You copied your wallet address", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            })
            confirm.addAction(ok)
            self.present(confirm, animated: true, completion: nil)
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (_) in
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
//    @IBAction func QRCodeBtnPressed(_ sender: Any) {
//        if !showQRCode {
//            let QRURL = URL(string: "http://explorer.grlc-bakery.fun/qr/\(address!)")
//            imageView.kf.setImage(with: QRURL)
//            imageView.frame = CGRect(x: self.view.frame.width / 1.5, y: self.view.frame.height / 1.5, width: 151, height: 151)
//            self.QRCodeBtn.setTitle("Hide QR Code", for: .normal)
//            self.showQRCode = true
//            view.addSubview(imageView)
//        } else {
//            imageView.removeFromSuperview()
//            QRCodeBtn.setTitle("Show QR Code", for: .normal)
//
//            showQRCode = false
//        }
//    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Saved Wallet Address", message: "Are you sure?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            UserDefaults.standard.removeObject(forKey: "WalletAddress")
            self.performSegue(withIdentifier: TO_SEARCH, sender: nil)
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (_) in
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func refreshData(_ sender: Any) {
        // Fetch Weather Data
        update { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func update(completionHandler: @escaping (_ success: Bool) -> ()) {
        var ctr = 0
        if address != nil {
            // Balance
            balanceUpdate { (success) in
                if success {
                    let coins = UserDefaults.standard.double(forKey: "GRLC")
                    self.coinsLbl.text = String(describing: coins)
                } else {
                    let coins = UserDefaults.standard.double(forKey: "GRLC")
                    self.coinsLbl.text = String(describing: coins)
                }
                ctr += 1
                if ctr == 3 {
                    completionHandler(true)
                    return
                }
            }
            // Transactions
            getTransactions(completionHandler: { (success) in
                if success {
                    self.tableView.reloadData()
                }
                ctr += 1
                if ctr == 3 {
                    completionHandler(true)
                    return
                }
            })
            // Price
            PriceService.instance.getPriceUSD(completionHandler: { (usdPrice, success)  in
                if success {
                    if let grlc = UserDefaults.standard.double(forKey: "GRLC") as? Double {
                        let price: Double = grlc * usdPrice
                        self.valueLbl.text = self.formattedUSD(usd: price)
                    }
                }
                ctr += 1
                if ctr == 3 {
                    completionHandler(true)
                    return
                }
            })
        }
    }
    
    func balanceUpdate(completionHandler: @escaping (_ success: Bool) -> ()) {
        let balanceURL = "https://explorer.grlc-bakery.fun/ext/getbalance/\(address!)"
        Alamofire.request(balanceURL).responseJSON(completionHandler: { (response) in
            if let value = response.result.value {
                let json = JSON(value)
                if json["error"] != JSON.null {
                    completionHandler(false)
                    return
                }
                UserDefaults.standard.set(json.double, forKey: "GRLC")
                completionHandler(true)
            }
        })
    }
    
    func getTransactions(completionHandler: @escaping (_ success: Bool) -> ()) {
        let transactionsURL = URL(string: "https://explorer.grlc-bakery.fun/address/\(address!)")

        Alamofire.request(transactionsURL!).responseString { (response) in
            if let HTML = response.result.value {
                // Parse HTML transactions
                do {
                    self.timestamps = []
                    self.amounts = []
                    
                    var tCtr = 0
                    var aCtr = 0
                    
                    let els: Elements = try SwiftSoup.parse(HTML).select("table")
                    for table: Element in els.array() {
                        let transactionElements = try table.getElementsByTag("td")
                        
//                        print(transactionElements.array())
                        for transaction: Element in transactionElements.array() {

                            if tCtr < 5 || aCtr < 5 {
                                let data: String = try! transaction.text()
                                if data.first == "+" || data.first == "-" {
                                    self.amounts.append(data)
                                    aCtr += 1
                                } else if data.contains(" ") {
                                    self.timestamps.append(data)
                                    tCtr += 1
                                }
                            } else {
                                break
                            }
                        }
                    }
                    completionHandler(true)
                    return
                } catch {
                    print("Error fetching transactions")
                    completionHandler(true)
                }
            }
        }
    }
    
    func updatePrice() {
        if let grlc = UserDefaults.standard.double(forKey: "GRLC") as? Double {
            if let priceUSD = UserDefaults.standard.double(forKey: "Price") as? Double {
                valueLbl.text = String(describing: grlc * priceUSD)
                priceLbl.text = String(describing: priceUSD)
            }
        }
    }
    
    func formattedUSD(usd: Double) -> String {
        let formatted = String(format: "$%.2f", usd)
        return formatted
    }
    
}

extension DisplayVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timestamps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as? TransactionCell else { return UITableViewCell() }
//        print(timestamps)
//        print(amounts)
        cell.configure(timestamp: timestamps[indexPath.row], amount: amounts[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TRANSACTIONS"
    }
    
}
