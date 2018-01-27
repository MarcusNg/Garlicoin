//
//  TransactionCell.swift
//  Garlicoin
//
//  Created by Marcus Ng on 1/25/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    func configure(timestamp: String, amount: String) {
        timestampLbl.text = "\(timestamp) GMT"
        let newAmount = amount.replacingOccurrences(of: " ", with: "")
        amountLbl.text = newAmount
        if newAmount.first == "+" {
            amountLbl.textColor = #colorLiteral(red: 0.09426554507, green: 0.8067692361, blue: 0.193761537, alpha: 1)
        } else if newAmount.first == "-" {
            amountLbl.textColor = #colorLiteral(red: 0.8176951142, green: 0.1114536269, blue: 0.1201557995, alpha: 1)
        }
    }
}
