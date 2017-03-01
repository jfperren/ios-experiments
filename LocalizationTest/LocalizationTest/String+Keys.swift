// 
//  LocalizationTest/String+Keys.swift
//  LocalizableTest
//
//  Auto-generated by Julien Perrenoud on 2/28/2017 at 20:35
//  Copyright (c) 2017 BuddyHopp. All rights reserved. 
//

enum Strings: LocalizationKey {
  
    case singleLevel

    enum chat: LocalizationKey {
    
        case categoryTitle(category: String)
        case wrongInput(input: String, solution: String)

        enum topLevel: LocalizationKey {
        
            case test
        }
    }

    enum common: LocalizationKey {
    
        case cancel
        case ok

        enum special: LocalizationKey {
        
            case another(profile: String)
        }
    }

    enum other: LocalizationKey {
    
        case giuseppe(beautiful: String)
    }

    enum registration: LocalizationKey {
    
        case incorrectPassword
    }
}

// MARK: - Extensions
    
extension LocalizationKey {

    static func getRawValue(key: LocalizationKey) -> String {
        switch key {
        case Strings.chat.categoryTitle: return "chat.categoryTitle"
        case Strings.chat.topLevel.test: return "chat.topLevel.test"
        case Strings.chat.wrongInput: return "chat.wrongInput"
        case Strings.common.cancel: return "common.cancel"
        case Strings.common.ok: return "common.ok"
        case Strings.common.special.another: return "common.special.another"
        case Strings.other.giuseppe: return "other.giuseppe"
        case Strings.registration.incorrectPassword: return "registration.incorrectPassword"
        case Strings.singleLevel: return "singleLevel"
        default: return ""
        }
    }
    
    static func getParameters(key: LocalizationKey) -> [String: String] {
        switch key {
        case Strings.chat.categoryTitle(let category): return ["category": category]
        case Strings.chat.topLevel.test: return [:]
        case Strings.chat.wrongInput(let input, let solution): return ["input": input, "solution": solution]
        case Strings.common.cancel: return [:]
        case Strings.common.ok: return [:]
        case Strings.common.special.another(let profile): return ["profile": profile]
        case Strings.other.giuseppe(let beautiful): return ["beautiful": beautiful]
        case Strings.registration.incorrectPassword: return [:]
        case Strings.singleLevel: return [:]
        default: return [:]
        }
    }
}
