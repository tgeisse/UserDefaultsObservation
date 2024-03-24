//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/23/24.
//

import SwiftSyntax

internal extension MemberBlockItemSyntax {
    var isUserDefaultsStoreVariable: Bool {
        guard let attributeName = decl.as(VariableDeclSyntax.self)?
                                    .attributes.first?.as(AttributeSyntax.self)?
                                    .attributeName.as(IdentifierTypeSyntax.self)?
                                    .name.trimmedDescription
        else { return false }
        
        return attributeName == MacroIdentifiers.ObservableUserDefaultsStore.rawValue
    }
}
