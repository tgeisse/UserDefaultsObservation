//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/25/24.
//

import SwiftSyntax

extension LabeledExprListSyntax.Element {
    func getString() -> TokenSyntax? {
        self.expression.as(StringLiteralExprSyntax.self)?
            .segments.as(StringLiteralSegmentListSyntax.self)?
            .first?.as(StringSegmentSyntax.self)?
            .content
    }
    
    func getMemberIdentifier() -> String? {
        self.expression.as(MemberAccessExprSyntax.self)?
            .declName.as(DeclReferenceExprSyntax.self)?
            .baseName
            .text
    }
}
