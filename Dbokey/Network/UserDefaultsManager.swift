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
        case email
        case password
        case nick
        case phoneNum
        case birthDay
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
    var email: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.email.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.email.rawValue)
        }
    }
    var password: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.password.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.password.rawValue)
        }
    }
    var nick: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.nick.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.nick.rawValue)
        }
    }
    var phoneNum: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.phoneNum.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.phoneNum.rawValue)
        }
    }
    var birthDay: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKey.birthDay.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.birthDay.rawValue)
        }
    }
}
