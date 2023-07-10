//
// Created by Taylor Geisse, June 22nd, 2023
//
//

import Foundation

// MARK: - Macro definitions

/// A macro that transforms properties to UserDefaults backed variables.
/// Unless marked with @ObservationIgnored, each property will be stored and retrieved
/// from UserDefaults. Marking a variable with @ObservationIgnored will not allow it
/// to be observed and will not store it in UserDefaults.
@attached(member, names: named(_$observationRegistrar), named(_$userDefaultStore), named(access), named(withMutation), named(getValue), named(setValue), named(UserDefaultsWrapper))
@attached(memberAttribute)
@attached(conformance)
public macro ObservableUserDefaults() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsMacros")

@attached(accessor)
public macro ObservableUserDefaultsProperty(_ key: String) = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsPropertyMacros")

@attached(accessor)
public macro ObservableUserDefaultsIgnored() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsIgnoredMacros")

@attached(accessor)
public macro ObservableUserDefaultsStore() = #externalMacro(module: "UserDefaultsObservationMacros", type: "UserDefaultsStoreMacros")


