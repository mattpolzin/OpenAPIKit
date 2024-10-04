//
//  URLTemplate+Parsing.swift
//  
//
//  Created by Mathew Polzin on 12/20/20.
//

extension URLTemplate {
    internal static func scan(
        _ string: String
    ) throws -> [Component] {
        var tokens = [Component]()
        var remainder = string[...]
        var partialToken: PartialToken? = nil
        
        while let next = remainder.first {
            let nextFirstIndex = remainder.index(remainder.startIndex, offsetBy: 1, limitedBy: remainder.endIndex)

            switch (partialToken?.type, next) {
            case (nil, "{"),
                (.constant, "{"):
                guard let newFirstIndex = nextFirstIndex else {
                    throw ParsingError.unterminatedVariable(name: "")
                }
                tokens += tokenArray(from: partialToken)
                partialToken = .init(type: .variable, string: remainder[newFirstIndex..<newFirstIndex])
                remainder = remainder.dropFirst()

            case (.variable, "}"):
                tokens += tokenArray(from: partialToken)
                partialToken = nil
                remainder = remainder.dropFirst()

            case (nil, "}"),
                (.constant, "}"):
                throw ParsingError.variableEndedWithoutStarting(name: partialToken.map { String($0.string) } ?? "")

            case (.variable, "{"):
                throw ParsingError.variableStartedWithinVariable(name: partialToken.map { String($0.string) } ?? "")

            case (nil, _):
                partialToken = .init(type: .constant, string: remainder[remainder.startIndex...remainder.startIndex])
                remainder = remainder.dropFirst()

            case (.constant, _),
                (.variable, _):
                guard nextFirstIndex != nil, let reifiedPartialToken = partialToken else {
                    tokens += tokenArray(from: partialToken)
                    continue
                }
                    partialToken = reifiedPartialToken.advancingStringByOne(within: string)
                    remainder = remainder.dropFirst()
            }
        }
        guard partialToken == nil || partialToken?.type == .constant else {
            throw ParsingError.unterminatedVariable(name: String(partialToken?.string ?? ""))
        }
        return tokens + tokenArray(from: partialToken)
    }

    internal static func tokenArray(from partial: PartialToken?) -> [Component] {
        partial.flatMap { $0.token }.map { [$0] } ?? []
    }

    internal enum TokenType {
        case constant
        case variable
    }

    internal struct PartialToken {
        let type: TokenType
        let string: Substring

        func advancingStringByOne(within string: String) -> PartialToken {
            return .init(type: type, string: string[self.string.startIndex...self.string.endIndex])
        }

        var token: Component? {
            guard !string.isEmpty else { return nil }
            switch type {
            case .constant:
                return .constant(String(string))
            case .variable:
                return .variable(name: String(string))
            }
        }
    }

    internal enum ParsingError: Swift.Error, CustomStringConvertible {
        case unterminatedVariable(name: String)
        case variableStartedWithinVariable(name: String)
        case variableEndedWithoutStarting(name: String)

        public var description: String {
            switch self {
            case .unterminatedVariable(name: let name):
                return "An opening brace with no closing brace was found. The portion of the URL following the opening brace was '\(name)'"
            case .variableStartedWithinVariable(name: let name):
                return "An opening brace within another variable was found. The portion of the URL following the first opening brace up until the second opening brace was '\(name)'"
            case .variableEndedWithoutStarting(name: let name):
                return "A closing brace with no opening brace was found. The portion of the URL preceeding the closing brace was '\(name)'"
            }
        }
    }
}
