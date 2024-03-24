//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/23/24.
//

import SwiftSyntax

internal extension DeclSyntaxProtocol {
    var shouldAddObservableAttribute: Bool {
        guard let property = self.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifer = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            return false
        }
        
        if let hasAttribute = property.attributes.as(AttributeListSyntax.self)?
                                      .first?.as(AttributeSyntax.self)?.attributeName.trimmedDescription {
            
            let skipAttributes = [MacroIdentifiers.ObservableUserDefaultsProperty,
                                  .ObservableUserDefaultsStore,
                                  .ObservalbeUserDefaultsIgnored,
                                  .CloudStore]
            
            if skipAttributes.contains(hasAttribute) {
                return false
            }
        }
        
        return binding.accessorBlock == nil && identifer.text != "_$observationRegistrar" && identifer.text != "_$userDefaultStore"
    }
}
