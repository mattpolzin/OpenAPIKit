import Foundation

public extension ValueEncodingStrategy {
    
    /// URL encoding strategy to use when encoding `AnyCodable` values.
    enum URL {
    }
}

public extension ValueEncodingStrategy.URL {
    static var `default`: ValueEncodingStrategy = .URL.uri
    
    /// URI string, schema: .string(format: .other("uri"))
    static var uri: ValueEncodingStrategy {
        ValueEncodingStrategy(URL.self) { url, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(url.absoluteString)
        }
    }
}
