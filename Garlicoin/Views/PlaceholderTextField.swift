//
//  PlaceholderTextField.swift
//  Dog
//
//  Created by Marcus Ng on 9/2/17.
//  Copyright © 2017 Marcus Ng. All rights reserved.
//

import UIKit

class PlaceholderTextField: UITextField {
    
    override func awakeFromNib() {
        let placeholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        self.attributedPlaceholder = placeholder
        super.awakeFromNib()
    }
    
}
