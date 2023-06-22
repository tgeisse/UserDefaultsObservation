//
//  ObservableUserDefaultsMacros.swift
//
//
//  Created by Taylor Geisse, June 22nd, 2023
//

import SwiftSyntax
import SwiftSyntaxMacros

private extension DeclSyntaxProtocol {
    var isObservableStoredProperty: Bool {
        guard let property = self.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifer = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            return false
        }
        
        if let hasAttribute = property.attributes?.as(AttributeListSyntax.self)?.first?.as(AttributeSyntax.self)?.attributeName {
            if hasAttribute.trimmedDescription == "ObservationIgnored" {
                return false
            }
        }
        
        return binding.accessor == nil && identifer.text != "_$observationRegistrar"
    }
}

public struct ObservableUserDefaultsMacros {}

extension ObservableUserDefaultsMacros: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let identifier = declaration.asProtocol(IdentifiedDeclSyntax.self) else { return [] }
        
        let className = IdentifierPatternSyntax(identifier: .init(stringLiteral: "\(identifier.identifier.trimmed)"))
        
        let registrar: DeclSyntax =
            """
            let _$observationRegistrar = ObservationRegistrar()
            """
        
        let accessFunction: DeclSyntax =
            """
            internal nonisolated func access<Member>(
                keyPath: KeyPath<\(className), Member>
            ) {
              _$observationRegistrar.access(self, keyPath: keyPath)
            }
            """
        
        let withMutationFunction: DeclSyntax =
            """
            internal nonisolated func withMutation<Member, T>(
              keyPath: KeyPath<\(className), Member>,
              _ mutation: () throws -> T
            ) rethrows -> T {
              try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
            }
            """
        
        let userDefaultWrapper: DeclSyntax =
            """
            private struct UserDefaultsWrapper<Value> {
                static nonisolated func getValue(_ key: String, _ defaultValue: Value) -> Value
                where Value: RawRepresentable
                {
                    let key = \"\(className)_\\(key)\"
                    guard let rawValue = UserDefaults.standard.object(forKey: key) as? Value.RawValue else { return defaultValue }
                    return Value(rawValue: rawValue) ?? defaultValue
                }
                        
                static nonisolated func getValue<R>(_ key: String, _ defaultValue: Value) -> Value
                where Value == R?, R: RawRepresentable
                {
                    let key = \"\(className)_\\(key)\"
                    guard let rawValue = UserDefaults.standard.object(forKey: key) as? R.RawValue else { return defaultValue }
                    return R(rawValue: rawValue) ?? defaultValue
                }
                
                static nonisolated func getValue(_ key: String, _ defaultValue: Value) -> Value
                where Value: UserDefaultsPropertyListValue
                {
                    let key = \"\(className)_\\(key)\"
                    return UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
                }
                
                static nonisolated func getValue<R>(_ key: String, _ defaultValue: Value) -> Value
                where Value == R?, R: UserDefaultsPropertyListValue
                {
                    let key = \"\(className)_\\(key)\"
                    return UserDefaults.standard.object(forKey: key) as? R ?? defaultValue
                }
                
                static nonisolated func setValue(_ key: String, _ newValue: Value)
                where Value: RawRepresentable
                {
                    let key = \"\(className)_\\(key)\"
                    UserDefaults.standard.set(newValue.rawValue, forKey: key)
                }
            
                static nonisolated func setValue<R>(_ key: String, _ newValue: Value)
                where Value == R?, R: RawRepresentable
                {
                    let key = \"\(className)_\\(key)\"
                    UserDefaults.standard.set(newValue?.rawValue, forKey: key)
                }
            
                static nonisolated func setValue(_ key: String, _ newValue: Value)
                where Value: UserDefaultsPropertyListValue
                {
                    let key = \"\(className)_\\(key)\"
                    UserDefaults.standard.set(newValue, forKey: key)
                }
            
                static nonisolated func setValue<R>(_ key: String, _ newValue: Value)
                where Value == R?, R: UserDefaultsPropertyListValue
                {
                    let key = \"\(className)_\\(key)\"
                    UserDefaults.standard.set(newValue, forKey: key)
                }
            }
            """
        
        /*
        let rawRepGetValue: DeclSyntax =
            """
            internal nonisolated func getValue<Value>(_ key: String, _ defaultValue: Value) -> Value
            where Value: RawRepresentable
            {
                guard let rawValue = UserDefaults.standard.object(forKey: key) as? Value.RawValue else { return defaultValue }
                return Value(rawValue: rawValue) ?? defaultValue
            }
            """
        
        let rawRepOptGetValue: DeclSyntax =
            """
            internal nonisolated func getValue<Value, R>(_ key: String, _ defaultValue: Value) -> Value
            where Value == R?, R: RawRepresentable
            {
                guard let rawValue = UserDefaults.standard.object(forKey: key) as? R.RawValue else { return defaultValue }
                return R(rawValue: rawValue) ?? defaultValue
            }
            """
        
        let supportedGetValue: DeclSyntax =
            """
            internal nonisolated func getValue<Value>(_ key: String, _ defaultValue: Value) -> Value
            where Value: UserDefaultsPropertyListValue
            {
                UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
            }
            """
        
        let supportedOptGetValue: DeclSyntax =
            """
            internal nonisolated func getValue<Value, R>(_ key: String, _ defaultValue: Value) -> Value
            where Value == R?, R: UserDefaultsPropertyListValue
            {
                UserDefaults.standard.object(forKey: key) as? R ?? defaultValue
            }
            """
        
        let rawRepSetValue: DeclSyntax =
            """
            internal nonisolated func setValue<Value>(_ key: String, _ newValue: Value)
            where Value: RawRepresentable
            {
                UserDefaults.standard.set(newValue.rawValue, forKey: key)
            }
            """
        
        let rawRepOptSetValue: DeclSyntax =
            """
            internal nonisolated func setValue<Value, R>(_ key: String, _ newValue: Value)
            where Value == R?, R: RawRepresentable
            {
                UserDefaults.standard.set(newValue?.rawValue, forKey: key)
            }
            """
        
        let supportedSetValue: DeclSyntax =
            """
            internal nonisolated func setValue<Value>(_ key: String, _ newValue: Value)
            where Value: UserDefaultsPropertyListValue
            {
                UserDefaults.standard.set(newValue, forKey: key)
            }
            """
        
        let supportedOptSetValue: DeclSyntax =
            """
            internal nonisolated func setValue<Value, R>(_ key: String, _ newValue: Value)
            where Value == R?, R: UserDefaultsPropertyListValue
            {
                UserDefaults.standard.set(newValue, forKey: key)
            }
            """
         */
        
        return [
            registrar,
            accessFunction,
            withMutationFunction,/*
            rawRepGetValue,
            rawRepOptGetValue,
            supportedGetValue,
            supportedOptGetValue,
            rawRepSetValue,
            rawRepOptSetValue,
            supportedSetValue,
            supportedOptSetValue,*/
            userDefaultWrapper
        ]
    }
}

extension ObservableUserDefaultsMacros: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        if member.isObservableStoredProperty == false { return [] }
        
        return [
            AttributeSyntax(
                attributeName: SimpleTypeIdentifierSyntax(name: .identifier("ObservableUserDefaultsProperty"))
            )
        ]
    }
}

extension ObservableUserDefaultsMacros: ConformanceMacro {
    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingConformancesOf declaration: Declaration,
        in context: Context
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
        return [ ("Observable", nil) ]
    }
}
