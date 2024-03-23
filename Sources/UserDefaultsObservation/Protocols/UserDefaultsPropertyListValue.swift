//
//  File.swift
//  
//
//  Created by Taylor Geisse on 7/9/23.
//

import Foundation

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
