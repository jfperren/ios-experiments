//
//  LocalizationKey.swift
//  LocalizationTest
//
//  Created by Julien Perrenoud on 2/27/17.
//  Copyright © 2017 BuddyHopp. All rights reserved.
//

import Foundation

protocol LocalizationKey {

    var rawValue: String { get }
    var parameters: [String: String] { get }
    
    static func getRawValue(key: LocalizationKey) -> String
    static func getParameters(key: LocalizationKey) -> [String: String]
    
}

extension LocalizationKey {
    
    var rawValue: String {
        return Self.getRawValue(key: self)
    }
    
    var parameters: [String: String] {
        return Self.getParameters(key: self)
    }
}
