//
//  extensions.swift
//  Polish Calculator
//
//  Created by Michael Perry on 2/12/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension UIColor {
    func inverse () -> UIColor {
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return self
    }
}