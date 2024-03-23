//
// Created by Taylor Geisse, June 22nd, 2023
//
//

import Foundation

// MARK: - Macro definitions

/** 
 A macro that transforms properties to UserDefaults backed variables.
 */
@attached(member, names: named(_$observationRegistrar), named(_$userDefaultStore), named(access), named(withMutation), named(getValue), named(setValue), named(UserDefaultsWrapper))
@attached(memberAttribute)
@attached(extension, conformances: Observable)
public macro ObservableUserDefaults() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsMacros")

@available(*, deprecated, message: "Use new format")
@attached(accessor)
public macro ObservableUserDefaultsProperty(_ key: String) = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsPropertyMacros")

@attached(peer)
public macro ObservableUserDefaultsIgnored() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsIgnoredMacros")

@attached(peer)
public macro ObservableUserDefaultsStore() = #externalMacro(module: "UserDefaultsObservationMacros", type: "UserDefaultsStoreMacros")

@attached(peer)
public macro CloudStore(key: String, 
                        onStoreServerChange: UbiquitousKeyValueStoreChangeReasonAction = .cloudValue,
                        onInitialSyncChange: UbiquitousKeyValueStoreChangeReasonAction = .cloudValue,
                        onAccountChange: UbiquitousKeyValueStoreChangeReasonAction = .userDefaultsValue)
= #externalMacro(module: "UserDefaultsObservationMacros", type: "UbiquitousKeyValueStoreBackedMacro")
