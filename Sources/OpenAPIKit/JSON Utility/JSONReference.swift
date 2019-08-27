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
public struct RefDict<Root: ReferenceRoot, Name: RefName, RefType: Equatable & Codable>: ReferenceDict, Equatable {
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
public enum JSONReference<Root: ReferenceRoot, RefType: Equatable>: Equatable, CustomStringConvertible {

    case `internal`(Local)
    case external(FileReference, Local?)

    public static func external(_ ref: FileReference) -> JSONReference {
        let parts = ref.split(separator: "#")

        return .external(String(parts[0]), parts.count > 1 ? .unsafe("#" + String(parts[1])) : nil)
    }

    public typealias FileReference = String

    public enum Local: Equatable, CustomStringConvertible {
        case node(InternalReference)
        case unsafe(String)

        public var description: String {
            switch self {
            case .node(let reference):
                return reference.description
            case .unsafe(let string):
                guard string.starts(with: "#") else {
                    return "#/" + string
                }
                return string
            }
        }
    }

    public struct InternalReference: Equatable, CustomStringConvertible {
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

        public var description: String {
            return "#/\(Root.refName)/\(refName)/\(selector)"
        }
    }

    public var description: String {
        switch self {
        case .external(let file, let path):
            return path.map { file + $0.description } ?? file
        case .internal(let reference):
            return reference.description
        }
    }
}

// MARK: - Codable

extension JSONReference {
    private enum CodingKeys: String, CodingKey {
        case ref = "$ref"
    }
}

extension JSONReference: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(description, forKey: .ref)
    }
}

extension JSONReference: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let referenceString = try container.decode(String.self, forKey: .ref)

        if referenceString.first == "#" {
            // TODO: try to parse ref to components
            self = .internal(.unsafe(referenceString))
        } else {
            self = .external(referenceString)
        }
    }
}

extension RefDict: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(dict)
    }
}

extension RefDict: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        dict = try container.decode([String : RefType].self)
    }
}
