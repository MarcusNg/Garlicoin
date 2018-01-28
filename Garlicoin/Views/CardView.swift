//
//  CardView.swift
//  Journal
//
//  Created by Marcus Ng on 1/2/18.
//  Copyright © 2018 Marcus Ng. All rights reserved.
//

import UIKit

class CardView: UIView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.8
        super.awakeFromNib()
    }

}
