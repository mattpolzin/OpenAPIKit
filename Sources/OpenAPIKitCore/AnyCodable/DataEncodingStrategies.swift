import Foundation

public extension ValueEncodingStrategy {
    
    /// Data encoding strategy to use when encoding `AnyCodable` values.
    enum Data {
    }
}

public extension ValueEncodingStrategy.Data {
    static var `default`: ValueEncodingStrategy = .Data.base64
    
    /// Base64 string, schema: .string(format: .byte)
    static var base64: ValueEncodingStrategy {
        .Data.base64(options: [])
    }
    
    /// Base64 string, schema: .string(format: .byte)
    static func base64(options: Data.Base64EncodingOptions) -> ValueEncodingStrategy {
        ValueEncodingStrategy(Data.self) { data, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(data.base64EncodedString(options: options))
        }
    }
}
