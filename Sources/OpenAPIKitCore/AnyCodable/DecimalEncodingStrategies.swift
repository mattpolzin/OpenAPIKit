import Foundation

public extension ValueEncodingStrategy {
    
    /// Decimal encoding strategy to use when encoding `AnyCodable` values.
    enum Decimal {
    }
}

public extension ValueEncodingStrategy.Decimal {
    static var `default`: ValueEncodingStrategy = .Decimal.number
    
    /// Quoted string
    static var string: ValueEncodingStrategy {
        ValueEncodingStrategy(Decimal.self) { decimal, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(decimal.description)
        }
    }
    
    /// Number
    static var number: ValueEncodingStrategy {
        ValueEncodingStrategy(Decimal.self) { decimal, encoder in
            var container = encoder.singleValueContainer()
            try container.encode((decimal as NSDecimalNumber).doubleValue)
        }
    }
}
