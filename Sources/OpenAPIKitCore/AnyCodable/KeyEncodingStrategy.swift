import Foundation

/// Key encoding strategy to use when encoding `AnyCodable` values.
public struct KeyEncodingStrategy {
    public let encode: (String) -> String
}

public extension KeyEncodingStrategy {
    static var `default`: KeyEncodingStrategy = .useDefaultKeys

    /// Does not change the key
    static var useDefaultKeys: KeyEncodingStrategy = .custom { $0 }

    /// Custom key encoding strategy
    static func custom(_ encode: @escaping (String) -> String) -> KeyEncodingStrategy {
        KeyEncodingStrategy(encode: encode)
    }

    /// Encodes from camelCase to snake_case
    static var convertToSnakeCase: KeyEncodingStrategy {
        .convertToSnakeCase(separator: "_")
    }

    /// Encodes from camelCase to snake_case with a custom separator
    static func convertToSnakeCase(separator: String) -> KeyEncodingStrategy {
        .custom {
            $0.toSnakeCase(separator: separator)
        }
    }
}

private extension String {
    func toSnakeCase(separator: String = "_") -> String {
        var result = ""

        for character in self {
            if character.isUppercase {
                result += separator + character.lowercased()
            } else {
                result += String(character)
            }
        }

        return result
    }
}
