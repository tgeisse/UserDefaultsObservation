//
//  File.swift
//  
//
//  Created by Taylor Geisse on 3/23/24.
//

import Foundation

internal extension Collection where Element: RawRepresentable & Equatable {
    func contains<RawType>(_ element: RawType) -> Bool where RawType == Element.RawValue {
        guard let elementIsMacroIdentifier = Element(rawValue: element) else {
            return false
        }
        return self.contains(elementIsMacroIdentifier)
    }
}
