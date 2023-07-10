//
//  File.swift
//  
//
//  Created by Taylor Geisse on 7/9/23.
//

import Foundation

// MARK: - UserDefautls Wrapper
public struct UserDefaultsWrapper<Value> {
    private init() {}
    
    public static nonisolated func getValue(_ key: String, _ defaultValue: Value, _ store: UserDefaults) -> Value
    where Value: RawRepresentable
    {
        guard let rawValue = store.object(forKey: key) as? Value.RawValue else {
            return defaultValue
        }
        return Value(rawValue: rawValue) ?? defaultValue
    }

    public static nonisolated func getValue<R>(_ key: String, _ defaultValue: Value, _ store: UserDefaults) -> Value
    where Value == R?, R: RawRepresentable
    {
        guard let rawValue = store.object(forKey: key) as? R.RawValue else {
            return defaultValue
        }
        return R(rawValue: rawValue) ?? defaultValue
    }

    public static nonisolated func getValue(_ key: String, _ defaultValue: Value, _ store: UserDefaults) -> Value
    where Value: UserDefaultsPropertyListValue
    {
        return store.object(forKey: key) as? Value ?? defaultValue
    }

    public static nonisolated func getValue<R>(_ key: String, _ defaultValue: Value, _ store: UserDefaults) -> Value
    where Value == R?, R: UserDefaultsPropertyListValue
    {
        return store.object(forKey: key) as? R ?? defaultValue
    }

    public static nonisolated func setValue(_ key: String, _ newValue: Value, _ store: UserDefaults)
    where Value: RawRepresentable
    {
        store.set(newValue.rawValue, forKey: key)
    }

    public static nonisolated func setValue<R>(_ key: String, _ newValue: Value, _ store: UserDefaults)
    where Value == R?, R: RawRepresentable
    {
        store.set(newValue?.rawValue, forKey: key)
    }

    public static nonisolated func setValue(_ key: String, _ newValue: Value, _ store: UserDefaults)
    where Value: UserDefaultsPropertyListValue
    {
        store.set(newValue, forKey: key)
    }

    public static nonisolated func setValue<R>(_ key: String, _ newValue: Value, _ store: UserDefaults)
    where Value == R?, R: UserDefaultsPropertyListValue
    {
        store.set(newValue, forKey: key)
    }
}
