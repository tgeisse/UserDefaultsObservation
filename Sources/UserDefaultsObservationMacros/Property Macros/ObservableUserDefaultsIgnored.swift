//
//  File.swift
//  
//
//  Created by Taylor Geisse on 7/9/23.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct ObservableUserDefaultsIgnoredMacros: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}
