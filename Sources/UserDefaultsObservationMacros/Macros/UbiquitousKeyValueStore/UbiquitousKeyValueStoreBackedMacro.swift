//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/15/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

internal enum ChangeReasonAction: String {
    case defaultValue
    case cachedValue
    case cloudValue
    case ignore
}

public struct UbiquitousKeyValueStoreBackedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
              binding.accessorBlock == nil,
              let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        else { return [] }
        
        var key: TokenSyntax? = nil
        var userDefaultKey: TokenSyntax? = nil
        var onStoreServerChange: ChangeReasonAction = .ignore
        var onInitialSyncChange: ChangeReasonAction = .ignore
        var onAccountChange: ChangeReasonAction = .ignore
        
        for arg in arguments {
            switch arg.label?.text {
            case "key":
                key = arg.getString()
            case "userDefaultKey":
                userDefaultKey = arg.getString()
            case "onStoreServerChange":
                guard let rawValue = arg.getMemberIdentifier() else { continue }
                guard let parsed = ChangeReasonAction(rawValue: rawValue) else { continue }
                onStoreServerChange = parsed
            case "onInitialSyncChange":
                guard let rawValue = arg.getMemberIdentifier() else { continue }
                guard let parsed = ChangeReasonAction(rawValue: rawValue) else { continue }
                onInitialSyncChange = parsed
            case "onAccountChange":
                guard let rawValue = arg.getMemberIdentifier() else { continue }
                guard let parsed = ChangeReasonAction(rawValue: rawValue) else { continue }
                onAccountChange = parsed
            default: continue
            }
        }
        
        if userDefaultKey == nil {
            userDefaultKey = key
        }
        
        guard let key = key, let userDefaultKey = userDefaultKey else {
            // TODO: This should produce an error informing the user of the fix
            return []
        }
        
        let getAccessor: AccessorDeclSyntax =
            """
            get {
                access(keyPath: \\.\(identifier))
                \(binding.asDefaultValue)
                UbiquitousKeyValueStoreUtility.shared.registerUpdateCallback(forKey: \"\(key)\") { [weak self] event in
                    guard let self = self else {
                        throw UbiquitousKeyValueStoreError.SelfReferenceRemoved
                    }
            
                    switch event {
                    case NSUbiquitousKeyValueStoreServerChange:
                        \(changeActionDeclSyntax(identifier: identifier, uKvsKey: key, userDefaultKey: userDefaultKey, action: onStoreServerChange))
                    case NSUbiquitousKeyValueStoreInitialSyncChange:
                        \(changeActionDeclSyntax(identifier: identifier, uKvsKey: key, userDefaultKey: userDefaultKey, action: onInitialSyncChange))
                    case NSUbiquitousKeyValueStoreAccountChange:
                        \(changeActionDeclSyntax(identifier: identifier, uKvsKey: key, userDefaultKey: userDefaultKey, action: onAccountChange))
                    default: return
                    }
                }
                return UserDefaultsWrapper.getValue(\"\(key)\", defaultValue, _$userDefaultStore)
            }
            """
        
        let setAccessor: AccessorDeclSyntax =
            """
            set {
                withMutation(keyPath: \\.\(identifier)) {
                    UserDefaultsWrapper.setValue(\"\(userDefaultKey)\", newValue, _$userDefaultStore)
                    UbiquitousKeyValueStoreWrapper.set(newValue, forKey: \"\(key)\")
                }
            }
            """
        
        return  [
            getAccessor,
            setAccessor
        ]
    }
    
    
    private static func changeActionDeclSyntax(identifier: IdentifierPatternSyntax ,uKvsKey: TokenSyntax, userDefaultKey: TokenSyntax, action: ChangeReasonAction) -> DeclSyntax {
        return switch action {
        case .defaultValue:
            "self.\(identifier) = defaultValue"
        case .cachedValue:
            "self.\(identifier) = UserDefaultsWrapper.getValue(\"\(userDefaultKey)\", defaultValue, self._$userDefaultStore)"
        case .cloudValue:
            """
            let cloudValue = NSUbiquitousKeyValueStore.default.object(forKey: \"\(uKvsKey)\")
            self.\(identifier) = UbiquitousKeyValueStoreWrapper.castAnyValue(cloudValue, defaultValue: defaultValue)
            """
        case .ignore:
            "return"
        }
    }
}


