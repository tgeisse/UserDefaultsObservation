//
//  ObservableUserDefaultsMacros.swift
//
//
//  Created by Taylor Geisse, June 22nd, 2023
//

import SwiftSyntax
import SwiftSyntaxMacros

private extension DeclSyntaxProtocol {
    var shouldAddObservableAttribute: Bool {
        guard let property = self.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifer = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            return false
        }
        
        if let hasAttribute = property.attributes.as(AttributeListSyntax.self)?
                                      .first?.as(AttributeSyntax.self)?.attributeName.trimmedDescription {
            if hasAttribute == "ObservationIgnored" {
                return false
            }
            
            if hasAttribute == "ObservableUserDefaultsProperty" {
                return false
            }
            
            if hasAttribute == "ObservableUserDefaultsIgnored" {
                return false
            }
            
            if hasAttribute == "ObservableUserDefaultsStore" {
                return false
            }
        }
        
        return binding.accessorBlock == nil && identifer.text != "_$observationRegistrar" && identifer.text != "_$userDefaultStore"
    }
}

public extension MemberBlockItemSyntax {
    var isUserDefaultsStoreVariable: Bool {
        guard let attributeName = decl.as(VariableDeclSyntax.self)?
                                    .attributes.first?.as(AttributeSyntax.self)?
                                    .attributeName.as(IdentifierTypeSyntax.self)?
                                    .name.trimmedDescription
        else { return false }
        
        return attributeName == "ObservableUserDefaultsStore"
    }
}

public struct ObservableUserDefaultsMacros {}

extension ObservableUserDefaultsMacros: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let identifier = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        
        let className = IdentifierPatternSyntax(identifier: .init(stringLiteral: "\(identifier.name.trimmed)"))
        
        let registrar: DeclSyntax =
            """
            private let _$observationRegistrar = Observation.ObservationRegistrar()
            """
        
        let accessFunction: DeclSyntax =
            """
            internal nonisolated func access<Member>(keyPath: KeyPath<\(className), Member>) {
              _$observationRegistrar.access(self, keyPath: keyPath)
            }
            """
        
        let withMutationFunction: DeclSyntax =
            """
            internal nonisolated func withMutation<Member, T>(keyPath: KeyPath<\(className), Member>, _ mutation: () throws -> T) rethrows -> T {
              try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
            }
            """
        
        let userDefaultStore: DeclSyntax
        
        if let storeDefined = declaration.memberBlock.members.filter(\.isUserDefaultsStoreVariable).first?.as(MemberBlockItemSyntax.self),
           let storeVarIdentifier = storeDefined.decl.as(VariableDeclSyntax.self)?
                                                .bindings.as(PatternBindingListSyntax.self)?
                                                .first?.pattern.as(IdentifierPatternSyntax.self)?
                                                .identifier
        {
            userDefaultStore =
                """
                private var _$userDefaultStore: Foundation.UserDefaults { get { \(storeVarIdentifier) } }
                """
        } else {
            userDefaultStore =
                """
                private let _$userDefaultStore: Foundation.UserDefaults = .standard
                """
        }
        
        return [
            registrar,
            accessFunction,
            withMutationFunction,
            userDefaultStore
        ]
    }
}

extension ObservableUserDefaultsMacros: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        guard member.shouldAddObservableAttribute else { return [] }
        
        guard let className = declaration.as(ClassDeclSyntax.self)?.name.trimmed,
              let memberName = member.as(VariableDeclSyntax.self)?
                                     .bindings.as(PatternBindingListSyntax.self)?
                                     .first?.pattern.as(IdentifierPatternSyntax.self)?
                                     .identifier.trimmed
        else { return [] }
        
        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(name: .identifier("ObservableUserDefaultsProperty(\"\(className).\(memberName)\")"))
            )
        ]
    }
}

extension ObservableUserDefaultsMacros: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let udObservable: DeclSyntax =
            """
                extension \(type.trimmed): Observation.Observable {}
            """
        
        guard let ext = udObservable.as(ExtensionDeclSyntax.self) else { return [] }
        return [ext]
    }
}
