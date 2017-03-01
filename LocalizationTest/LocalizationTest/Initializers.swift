//
//  Initializers.swift
//  LocalizationTest
//
//  Created by Julien Perrenoud on 2/10/17.
//  Copyright © 2017 BuddyHopp. All rights reserved.
//

import Foundation

extension String {
    
    init(key: LocalizationKey) {

        // Replace parameters with correct value.
        
        var string = NSLocalizedString(key.rawValue, comment: "")
        
        for (parameter, value) in key.parameters {
            string = string.replacingOccurrences(of: "{{\(parameter)}}", with: value)
        }
        
        self = string
    }
}

//extension NSAttributedString {
//    
//    convenience init(key: String.Key, parameters: [String.Parameter: String] = [:]) {
//        
//        // Same thing but will also parse Bold and Links automatically.
//        
//        self.init(string: String(key: key, parameters: parameters))
//    }
//}
