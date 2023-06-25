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
@attached(member, names: named(_$observationRegistrar), named(access), named(withMutation), named(getValue), named(setValue), named(UserDefaultsWrapper))
@attached(memberAttribute)
@attached(conformance)
public macro ObservableUserDefaults() = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsMacros")

@attached(accessor)
public macro ObservableUserDefaultsProperty(_ key: String) = #externalMacro(module: "UserDefaultsObservationMacros", type: "ObservableUserDefaultsPropertyMacros")



// MARK: - Protocol indiciating supported types
public protocol UserDefaultsPropertyListValue {}

extension NSData: UserDefaultsPropertyListValue {}
extension Data: UserDefaultsPropertyListValue {}

extension NSString: UserDefaultsPropertyListValue {}
extension String: UserDefaultsPropertyListValue {}

extension NSURL: UserDefaultsPropertyListValue {}
extension URL: UserDefaultsPropertyListValue {}

extension NSDate: UserDefaultsPropertyListValue {}
extension Date: UserDefaultsPropertyListValue {}

extension NSNumber: UserDefaultsPropertyListValue {}
extension Bool: UserDefaultsPropertyListValue {}
extension Int: UserDefaultsPropertyListValue {}
extension Int8: UserDefaultsPropertyListValue {}
extension Int16: UserDefaultsPropertyListValue {}
extension Int32: UserDefaultsPropertyListValue {}
extension Int64: UserDefaultsPropertyListValue {}
extension UInt: UserDefaultsPropertyListValue {}
extension UInt8: UserDefaultsPropertyListValue {}
extension UInt16: UserDefaultsPropertyListValue {}
extension UInt32: UserDefaultsPropertyListValue {}
extension UInt64: UserDefaultsPropertyListValue {}
extension Double: UserDefaultsPropertyListValue {}
extension Float: UserDefaultsPropertyListValue {}

extension Array: UserDefaultsPropertyListValue where Element: UserDefaultsPropertyListValue {}
extension Dictionary: UserDefaultsPropertyListValue where Key == String, Value: UserDefaultsPropertyListValue {}
