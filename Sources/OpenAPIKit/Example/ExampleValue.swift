//
//  ExampleValue.swift
//

import Foundation

extension OpenAPI.Example {
    /// OpenAPI Spec "Example Object" `datValue`, `serializedValue`,
    /// `externalValue`, and `value` fields get represented by this type in
    /// order to guard against forbidden combinations of those fields.
    ///
    /// The `dataValue` and `serializedValue` fields were added in OAS 3.2.0;
    /// for OAS 3.1.x documents, use of these fields will produce a warning
    /// upon document validation.
    ///
    /// See [OpenAPI Example Object](https://spec.openapis.org/oas/v3.2.0.html#example-object).
    ///
    /// The fields can be used in the following combinations:
    /// |-------------------------------------------------------------|
    /// |  dataValue  |  serializedValue  |  externalValue  |  value  |
    /// |-------------|-------------------|-----------------|---------|
    /// | +           |                   |                 |         |
    /// | +           | +                 |                 |         |
    /// | +           |                   | +               |         |
    /// |             | +                 |                 |         |
    /// |             |                   | +               |         |
    /// |             |                   |                 | +       |
    /// |-------------------------------------------------------------|
    /// 
    /// **Examples:**
    ///
    ///     // dataValue + serializedValue (xml)
    ///     Value.value(data: ["name": "Frank"], serialized: .a("<name>Frank</name>"))
    /// 
    ///     // dataValue + externalValue
    ///     Value.value(data: ["name": "Susan"], serialized: .b(URL(string: "https://website.com/examples/name.xml")!))
    /// 
    ///     // externalValue
    ///     Value.value(data: nil, serialized: .b(URL(string: "https://website.com/examples/name.xml")!))
    /// 
    ///     // value
    ///     Value.legacy(["name": "Sam"])
    ///
    public enum Value: Equatable, Sendable {
        case legacy(AnyCodable)
        case value(data: AnyCodable?, serialized: Either<String, URL>?)
    }
}

extension OpenAPI.Example.Value {
    /// The OpenAPI Spec `value` or `dataValue` if either is specified. If you
    /// need to differentiate between the two fields, `switch` on the `Value`
    /// instead or use the `legacyValue` or `dataValue` accessors.
    public var value: AnyCodable? {
        switch self {
        case .legacy(let value), .value(data: let .some(value), serialized: _): value
        default: nil
        }
    }

    public var legacyValue: AnyCodable? {
        switch self {
        case .legacy(let value): value
        default: nil
        }
    }

    public var dataValue: AnyCodable? {
        switch self {
        case .value(data: let .some(value), serialized: _): value
        default: nil
        }
    }

    public var serializedValue: String? {
        switch self {
        case .value(data: _, serialized: let .a(value)): value
        default: nil
        }
    }

    public var externalValue: URL? {
        switch self {
        case .value(data: _, serialized: let .b(value)): value
        default: nil
        }
    }
}
