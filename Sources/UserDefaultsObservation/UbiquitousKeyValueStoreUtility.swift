//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/12/24.
//

import Foundation

// MARK: - NSUbiquitousKeyValueStore Ex
public struct UbiquitousKeyValueStoreUtility<Value> {
    private init() {}
    
    public static nonisolated func castAnyValue(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value: RawRepresentable
    {
        guard let anyValue = anyValue, let rawValue = anyValue as? Value.RawValue else {
            return defaultValue
        }
        return Value(rawValue: rawValue) ?? defaultValue
    }
    
    public static nonisolated func castAnyValue<R>(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value == R?, R: RawRepresentable
    {
        guard let anyValue = anyValue, let rawValue = anyValue as? R.RawValue else {
            return defaultValue
        }
        return R(rawValue: rawValue) ?? defaultValue
    }
    
    public static nonisolated func castAnyValue(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value: UserDefaultsPropertyListValue
    {
        guard let anyValue = anyValue else { return defaultValue }
        return (anyValue as? Value) ?? defaultValue
    }
    
    public static nonisolated func castAnyValue<R>(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value == R?, R: UserDefaultsPropertyListValue
    {
        guard let anyValue = anyValue else { return defaultValue }
        return (anyValue as? R) ?? defaultValue
    }
}

