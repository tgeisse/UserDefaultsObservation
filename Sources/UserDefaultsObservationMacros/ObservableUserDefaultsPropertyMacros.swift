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
        //return ["get { \(raw: declaration.debugDescription) } "]
        
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
            //  let initializer = binding.initializer?.as(InitializerClauseSyntax.self),
              binding.accessor == nil
        else { return [] }
        
        if "\(property.bindingKeyword)".contains("var") == false {
            throw ObservableUserDefaultsError.varValueRequired
        }
        
        let fieldName = IdentifierPatternSyntax(identifier: .init(stringLiteral: "\(identifier.trimmed)"))
        
        let getAccessor: AccessorDeclSyntax =
            """
            get {
                access(keyPath: \\.\(identifier))
                let defaultValue\(raw: binding.typeAnnotation == nil ? "" : "\(binding.typeAnnotation!)")\(raw: binding.initializer == nil ? " = nil" : "\(binding.initializer!)")
                return UserDefaultsWrapper.getValue(\"\(fieldName)\", defaultValue)
            }
            """
        
        let setAccessor: AccessorDeclSyntax =
            """
            set {
                withMutation(keyPath: \\.\(identifier)) {
                    UserDefaultsWrapper.setValue(\"\(fieldName)\", newValue)
                }
            }
            """
        
        return [
            getAccessor,
            setAccessor
        ]
    }
}
