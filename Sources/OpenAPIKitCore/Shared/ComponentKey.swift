//
//  ComponentKey.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//

import Foundation

extension Shared {
    /// A key for one of the component dictionaries.
    ///
    /// These keys must match the regex
    /// `^[a-zA-Z0-9\.\-_]+$`.
    public struct ComponentKey: RawRepresentable, ExpressibleByStringLiteral, Codable, Equatable, Hashable, StringConvertibleHintProvider {
        public let rawValue: String

        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }

        public init?(rawValue: String) {
            guard !rawValue.isEmpty else {
                return nil
            }
            var allowedCharacters = CharacterSet.alphanumerics
            allowedCharacters.insert(charactersIn: "-_.")
            guard CharacterSet(charactersIn: rawValue).isSubset(of: allowedCharacters) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public static func problem(with proposedString: String) -> String? {
            if Self(rawValue: proposedString) == nil {
                return "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(proposedString)' does not.."
            }
            return nil
        }

        public init(from decoder: Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            guard let key = Self(rawValue: rawValue) else {
                throw InconsistencyError(
                    subjectName: "Component Key",
                    details: "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(rawValue)' does not..",
                    codingPath: decoder.codingPath
                )
            }
            self = key
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

                // we check for consistency on encode because a string literal
                // may result in an invalid component key being constructed.
            guard Self(rawValue: rawValue) != nil else {
                throw InconsistencyError(
                    subjectName: "Component Key",
                    details: "Keys for components in the Components Object must conform to the regex `^[a-zA-Z0-9\\.\\-_]+$`. '\(rawValue)' does not..",
                    codingPath: container.codingPath
                )
            }

            try container.encode(rawValue)
        }
    }
}
