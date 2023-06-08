import Foundation

public struct ValueEncodingStrategy {
    
    public let encode: (Encodable, Encoder) throws -> Bool
    
    public init<T: Encodable>(
        _ type: T.Type,
        encode: @escaping (T, Encoder) throws -> Void
    ) {
        self.encode = {
            guard let value = $0 as? T else {
                return false
            }
            try encode(value, $1)
            return true
        }
    }
}
