//
//  UIViewControllerExtension.swift
//  Journal
//
//  Created by Marcus Ng on 1/2/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit
import StoreKit

extension UIViewController {
    
    // Hide keyboard on tap
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Format USD
    func formattedUSD(usd: Double) -> String {
        let formatted = String(format: "$%.2f", usd)
        return formatted
    }
    
    // Store Kit Review Request
    func requestReview() {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "Launches") != nil {
            if defaults.value(forKey: "Launches") as! Int >= 30 {
                defaults.set(0, forKey: "Launches")
                SKStoreReviewController.requestReview()
            }
        }
    }
    
}
