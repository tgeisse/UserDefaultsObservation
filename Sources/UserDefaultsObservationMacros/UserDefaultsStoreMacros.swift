//
//  File.swift
//  
//
//  Created by Taylor Geisse on 7/9/23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct UserDefaultsStoreMacros: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        return []
    }
}


