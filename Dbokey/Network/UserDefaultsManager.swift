//
//  UserDefaultsManager.swift
//  Dbokey
//
//  Created by 소정섭 on 8/16/24.
//

import Foundation

final class UserDefaultsManager {
    private enum UserDefaultsKey: String {
        case access
        case refresh
    }
    static let shared = UserDefaultsManager()
    private init() {}
    var token: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.access.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.access.rawValue)
        }
    }
    var refreshToken: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.refresh.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.refresh.rawValue)
        }
    }
}
