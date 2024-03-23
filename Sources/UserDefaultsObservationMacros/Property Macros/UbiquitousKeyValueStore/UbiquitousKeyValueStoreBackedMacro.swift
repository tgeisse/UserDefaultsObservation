//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/15/24.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct UbiquitousKeyValueStoreBackedMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        return []
    }
    
}


