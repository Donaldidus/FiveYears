//
//  UserSettings+UserDefaults.swift
//  FiveYears
//
//  Created by Jan B on 10.05.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import Foundation

/// A struct with all available settings the user is able to change.
struct UserSettings {
    
    var fontSize: Int?
    
    var rainEnabled: Bool?
    
    var autoreloadEnabled: Bool?
    
    var loginEmail: String?
    
    var loginPassword: String?
    
    var lastViewedMemory: String?
    
}


/// Struct defining the keys for every setting to access in UserDefaults.
struct UserSettingsKeys {
    static let fontSize = "fontSize"
    static let rainEnabled = "rainEnabled"
    static let autoreloadEnabled = "autoreloadEnabled"
    static let loginEmail = "loginEmail"
    static let loginPassword = "loginPassword"
    static let lastViewedMemory = "lastViewedMemory"
}

// Extending UserDefaults to easily save, delete and get the user settings.
extension UserDefaults {
    func save(usersettings settings: UserSettings) {
        if let size = settings.fontSize {
            set(size, forKey: UserSettingsKeys.fontSize)
        }
        if let rain = settings.rainEnabled {
            set(rain, forKey: UserSettingsKeys.rainEnabled)
        }
        if let auto = settings.autoreloadEnabled {
            set(auto, forKey: UserSettingsKeys.autoreloadEnabled)
        }
        if let mail = settings.loginEmail {
            set(mail, forKey: UserSettingsKeys.loginEmail)
        }
        if let pswd = settings.loginPassword {
            set(pswd, forKey: UserSettingsKeys.loginPassword)
        }
        if let memory = settings.lastViewedMemory {
            set(memory, forKey: UserSettingsKeys.lastViewedMemory)
        }
        synchronize()
    }
    
    func deleteSettings() {
        removeObject(forKey: UserSettingsKeys.fontSize)
        removeObject(forKey: UserSettingsKeys.rainEnabled)
        removeObject(forKey: UserSettingsKeys.autoreloadEnabled)
        removeObject(forKey: UserSettingsKeys.loginEmail)
        removeObject(forKey: UserSettingsKeys.loginPassword)
        removeObject(forKey: UserSettingsKeys.lastViewedMemory)
        synchronize()
    }
    
    func getUserSettings() -> UserSettings {
        var settings = UserSettings()
        if let size = object(forKey: UserSettingsKeys.fontSize) as? Int {
            settings.fontSize = size
        }
        if let rain = object(forKey: UserSettingsKeys.rainEnabled) as? Bool {
            settings.rainEnabled = rain
        }
        if let auto = object(forKey: UserSettingsKeys.autoreloadEnabled) as? Bool {
            settings.autoreloadEnabled = auto
        }
        if let mail = object(forKey: UserSettingsKeys.loginEmail) as? String {
            settings.loginEmail = mail
        }
        if let pswd = object(forKey: UserSettingsKeys.loginPassword) as? String {
            settings.loginPassword = pswd
        }
        if let memory = object(forKey: UserSettingsKeys.lastViewedMemory) as? String {
            settings.lastViewedMemory = memory
        }
        return settings
    }
}
