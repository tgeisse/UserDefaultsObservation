//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/24/24.
//

import SwiftSyntax

extension PatternBindingListSyntax.Element {
    var asDefaultValue: DeclSyntax {
        """
        let defaultValue\(raw: self.typeAnnotation == nil ? "" : "\(self.typeAnnotation!)")\(raw: self.initializer == nil ? " = nil" : "\(self.initializer!)")
        """
    }
}
