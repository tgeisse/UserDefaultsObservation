//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/12/24.
//

import Foundation

// MARK: - NSUbiquitousKeyValueStore Wrapper
public struct UbiquitousKeyValueStoreWrapper<Value> {
    private init() {}
    
    public static nonisolated func castAnyValue(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value: RawRepresentable, Value.RawValue: UserDefaultsPropertyListValue
    {
        guard let anyValue = anyValue, let rawValue = anyValue as? Value.RawValue else {
            return defaultValue
        }
        return Value(rawValue: rawValue) ?? defaultValue
    }
    
    public static nonisolated func castAnyValue<R>(_ anyValue: Any?, defaultValue: Value) -> Value
    where Value == R?, R: RawRepresentable, R.RawValue: UserDefaultsPropertyListValue
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
    
    
    // MARK: - Set values on NSUbiquitousKeyValueStore
    public static nonisolated func set(_ newValue: Value, forKey key: String)
    where Value: RawRepresentable, Value.RawValue: UserDefaultsPropertyListValue
    {
        NSUbiquitousKeyValueStore.default.set(newValue.rawValue, forKey: key)
    }
    
    public static nonisolated func set<R>(_ newValue: Value, forKey key: String)
    where Value == R?, R: RawRepresentable, R.RawValue: UserDefaultsPropertyListValue
    {
        NSUbiquitousKeyValueStore.default.set(newValue?.rawValue, forKey: key)
    }
    
    public static nonisolated func set(_ newValue: Value, forKey key: String)
    where Value: UserDefaultsPropertyListValue
    {
        NSUbiquitousKeyValueStore.default.set(newValue, forKey: key)
    }

    public static nonisolated func set<R>(_ newValue: Value, forKey key: String)
    where Value == R?, R: UserDefaultsPropertyListValue
    {
        NSUbiquitousKeyValueStore.default.set(newValue, forKey: key)
    }
}

