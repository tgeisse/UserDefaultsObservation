import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

// MARK: - Error Enumerator
public enum ObservableUserDefaultsError: Error, LocalizedError {
    case valueTypeNotSupported(String)
    case varValueRequired
    
    public var errorDescription: String? {
        switch self {
        case .varValueRequired: return "A 'var' declaration is required"
        case .valueTypeNotSupported(let type): return "\(type) is not supported"
        }
    }
}

@main
struct UserDefaultsObservationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableUserDefaultsMacros.self,
        ObservableUserDefaultsPropertyMacros.self,
        ObservableUserDefaultsIgnoredMacros.self,
        UserDefaultsStoreMacros.self
    ]
}
