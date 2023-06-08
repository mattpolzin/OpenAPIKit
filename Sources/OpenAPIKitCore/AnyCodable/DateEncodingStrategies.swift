import Foundation

public extension ValueEncodingStrategy {
    
    /// Date encoding strategy to use when encoding `AnyCodable` values.
    enum Date {
    }
}

public extension ValueEncodingStrategy.Date {
    static var `default`: ValueEncodingStrategy = .Date.dateTime

    /// full-date notation as defined by RFC 3339, section 5.6, for example, 2017-07-21, schema: .string(format: .date)
    static var date: ValueEncodingStrategy {
        .Date.custom { date, encoder in
            try encoder.encode(ValueEncodingStrategy.Date.date(date))
        }
    }

    /// the date-time notation as defined by RFC 3339, section 5.6, for example, 2017-07-21T17:32:28Z, schema: .string(format: .dateTime)
    static var dateTime: ValueEncodingStrategy {
        .Date.custom { date, encoder in
            try encoder.encode(ValueEncodingStrategy.Date.dateTime(date))
        }
    }

    /// the interval between the date value and 00:00:00 UTC on 1 January 1970, schema: .number(format: .other("timestamp"))
    static var timestamp: ValueEncodingStrategy {
        .Date.custom { date, encoder in
            try encoder.encode(date.timeIntervalSince1970)
        }
    }

    /// Custom date encoding strategy
    static func custom(
        encode: @escaping (Date, inout SingleValueEncodingContainer) throws -> Void
    ) -> ValueEncodingStrategy {
        ValueEncodingStrategy(Date.self) {
            var container = $1.singleValueContainer()
            try encode($0, &container)
        }
    }
}

extension ValueEncodingStrategy.Date {
    static func dateTime(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }

    static func date(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

private let isoFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()
private let dateFormatter = DateFormatter()
