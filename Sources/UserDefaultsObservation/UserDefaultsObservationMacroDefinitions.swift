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

@attached(accessor)
public macro UserDefaultsProperty(key: String) = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsPropertyMacros")

@attached(accessor)
public macro ObservableUserDefaultsProperty(_ key: String) = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsPropertyMacros")

@attached(peer)
public macro ObservableUserDefaultsIgnored() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsIgnoredMacros")

@attached(peer)
public macro UserDefaultsStore() = #externalMacro(module: "UserDefaultsObservationMacros", type: "UserDefaultsStoreMacros")

@attached(peer)
public macro ObservableUserDefaultsStore() = #externalMacro(module: "UserDefaultsObservationMacros", type: "UserDefaultsStoreMacros")

@attached(accessor)
public macro CloudProperty(key: String,
                           userDefaultKey: String = "defaultsSameAsKey",
                           onStoreServerChange: UbiquitousKeyValueStoreChangeReasonAction = .ignore,
                           onInitialSyncChange: UbiquitousKeyValueStoreChangeReasonAction = .ignore,
                           onAccountChange: UbiquitousKeyValueStoreChangeReasonAction = .ignore)
= #externalMacro(module: "UserDefaultsObservationMacros", type: "UbiquitousKeyValueStoreBackedMacro")
