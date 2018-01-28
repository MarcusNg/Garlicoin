//
//  RoundedButton.swift
//  Dog
//
//  Created by Marcus Ng on 8/31/17.
//  Copyright © 2017 Marcus Ng. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
