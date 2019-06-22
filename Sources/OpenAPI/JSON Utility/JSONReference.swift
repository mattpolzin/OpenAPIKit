//
//  Reference.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

/// Anything conforming to RefName knows what to call itself
/// in the context of JSON References.
public protocol RefName {
    static var refName: String { get }
}

public protocol ReferenceRoot: RefName {}

public protocol ReferenceDict: RefName {
    associatedtype Value
}

/// A RefDict knows what to call itself (Name) and where to
/// look for itself (Root) and it stores a dictionary of
/// JSONReferenceObjects (some of which might be other references).
public struct RefDict<Root: ReferenceRoot, Name: RefName, RefType: Equatable & Encodable>: ReferenceDict, Equatable {
    public static var refName: String { return Name.refName }

    public typealias Value = RefType
    public typealias Key = String

    let dict: [String: RefType]

    public init(_ dict: [String: RefType]) {
        self.dict = dict
    }

    public subscript(_ key: String) -> RefType? {
        return dict[key]
    }
}

/// A Reference is the combination of
/// a path to a reference dictionary
/// and a selector that the dictionary is keyed off of.
public enum JSONReference<Root: ReferenceRoot, RefType: Equatable>: Equatable {

    case node(InternalReference)
    case file(FileReference)

    public typealias FileReference = String

    public struct InternalReference: Equatable {
        public let path: PartialKeyPath<Root>
        public let selector: String

        public var refName: String {
            // we require RD be a RefName in the initializer
            // so it is safe to force cast here.
            return (type(of: path).valueType as! RefName.Type).refName
        }

        public init<RD: RefName & ReferenceDict>(type: KeyPath<Root, RD>,
                                                 selector: String) where RD.Value == RefType {
            self.path = type
            self.selector = selector
        }
    }
}

// MARK: - Codable

extension JSONReference: Encodable {
    private enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let referenceString: String = {
            switch self {
            case .file(let reference):
                return reference
            case .node(let reference):
                return "#/\(Root.refName)/\(reference.refName)/\(reference.selector)"
            }
        }()

        try container.encode(referenceString, forKey: .ref)
    }
}

extension RefDict: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(dict)
    }
}
