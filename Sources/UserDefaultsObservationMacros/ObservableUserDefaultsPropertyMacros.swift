//
//  File.swift
//  
//
//  Created by Taylor Geisse on 6/22/23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct ObservableUserDefaultsPropertyMacros: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
//        return ["get { \(raw: node.debugDescription) } "]
        
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
            //  let initializer = binding.initializer?.as(InitializerClauseSyntax.self),
              binding.accessor == nil,
              let key = node.as(AttributeSyntax.self)?
                            .argument?.as(TupleExprElementListSyntax.self)?.first?
                            .expression.as(StringLiteralExprSyntax.self)?
                            .segments.first?.as(StringSegmentSyntax.self)?.content
        else { return [] }
        
        if "\(property.bindingKeyword)".contains("var") == false {
            throw ObservableUserDefaultsError.varValueRequired
        }
        
        let getAccessor: AccessorDeclSyntax =
            """
            get {
                access(keyPath: \\.\(identifier))
                let defaultValue\(raw: binding.typeAnnotation == nil ? "" : "\(binding.typeAnnotation!)")\(raw: binding.initializer == nil ? " = nil" : "\(binding.initializer!)")
                return UserDefaultsWrapper.getValue(\"\(key)\", defaultValue, _$userDefaultStore)
            }
            """
        
        let setAccessor: AccessorDeclSyntax =
            """
            set {
                withMutation(keyPath: \\.\(identifier)) {
                    UserDefaultsWrapper.setValue(\"\(key)\", newValue, _$userDefaultStore)
                }
            }
            """
        
        return [
            getAccessor,
            setAccessor
        ]
    }
}
