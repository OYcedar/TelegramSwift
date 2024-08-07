//
//  AdditionalSettings.swift
//  Telegram
//
//  Created by keepcoder on 13/11/2017.
//  Copyright © 2017 Telegram. All rights reserved.
//


import Cocoa
import Postbox
import SwiftSignalKit
import TelegramCore


public struct AdditionalSettings: Codable, Equatable {
    public let useTouchId: Bool
    public let previewChats: Bool
    public let alwaysDarkMode: Bool?
    public static var defaultSettings: AdditionalSettings {
        return AdditionalSettings(useTouchId: false, previewChats: false, alwaysDarkMode: false)
    }
    
    public init(useTouchId: Bool, previewChats: Bool, alwaysDarkMode: Bool?) {
        self.useTouchId = useTouchId
        self.previewChats = previewChats
        self.alwaysDarkMode = alwaysDarkMode
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        self.useTouchId = try container.decode(Bool.self, forKey: "ti")
        self.previewChats = try container.decodeIfPresent(Bool.self, forKey: "pc") ?? false
        self.alwaysDarkMode = try container.decodeIfPresent(Bool.self, forKey: "adm")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encode(self.useTouchId, forKey: "ti")
        try container.encode(self.previewChats, forKey: "pc")
        try container.encodeIfPresent(self.alwaysDarkMode, forKey: "adm")
    }
    
    
    public static func ==(lhs: AdditionalSettings, rhs: AdditionalSettings) -> Bool {
        return lhs.useTouchId == rhs.useTouchId && lhs.previewChats == rhs.previewChats && lhs.alwaysDarkMode == rhs.alwaysDarkMode
    }
    
    public func withUpdatedTouchId(_ useTouchId: Bool) -> AdditionalSettings {
        return AdditionalSettings(useTouchId: useTouchId, previewChats: previewChats, alwaysDarkMode: alwaysDarkMode)
    }
    public func withUpdatedPreviewChats(_ previewChats: Bool) -> AdditionalSettings {
        return AdditionalSettings(useTouchId: useTouchId, previewChats: previewChats, alwaysDarkMode: alwaysDarkMode)
    }
    public func withUpdatedAlwaysDarkMode(_ alwaysDarkMode: Bool?) -> AdditionalSettings {
        return AdditionalSettings(useTouchId: useTouchId, previewChats: previewChats, alwaysDarkMode: alwaysDarkMode)
    }
}

public func updateAdditionalSettingsInteractively(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (AdditionalSettings) -> AdditionalSettings) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction -> Void in
        transaction.updateSharedData(ApplicationSharedPreferencesKeys.additionalSettings, { entry in
            let currentSettings: AdditionalSettings
            if let entry = entry?.get(AdditionalSettings.self) {
                currentSettings = entry
            } else {
                currentSettings = AdditionalSettings.defaultSettings
            }
            return PreferencesEntry(f(currentSettings))
        })
    }
}

public func additionalSettings(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<AdditionalSettings, NoError> {
    return accountManager.sharedData(keys: [ApplicationSharedPreferencesKeys.additionalSettings]) |> map { view in
        return view.entries[ApplicationSharedPreferencesKeys.additionalSettings]?.get(AdditionalSettings.self) ?? AdditionalSettings.defaultSettings
    }
}

