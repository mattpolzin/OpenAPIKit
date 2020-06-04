
## Validation

OpenAPIKit provides a small set of validations that are not covered by the type system. You can run these with
```swift
let document = OpenAPI.Document(...)
try document.validate()
```

### Adding Validations

There are additionally a few built-in validations you can add that are not actually part of the OpenAPI Specifcation. For example, you might want to assert that your document should contain at least one `OpenAPI.PathItem`. This is not a default validation because the OpenAPI Specification allows omitting `PathItems` for security reasons depending upon the authorization of a person looking at the documentation.

You can add a check for at least one `PathItem` with
```swift
let document = OpenAPI.Document(...)
let validator = Validator()

validator.validating(.documentContainsPaths)

try document.validate(using: validator)
```

Alternatively, you can make that a bit more concise by chaining calls. We can do so in addition to checking that all paths contain at least one operation (`GET`, `POST`, etc.) with
```swift
try document.validate(using: Validator()
    .validating(.documentContainsPaths)
    .validating(.pathsContainOperations)
)
```

You can find all such built-in validations in `Validation+Defaults.swift` -- just keep in mind that some of the validations indicate that they are already included by default; adding these twice will run them twice!

### Defining Validations

The `Validation` type defines a validation. Each validation is specialized on one particular type that it applies to. For example, the `.pathsContainsOperations` validation applies to `OpenAPI.PathItem`. When the Validator is validating an OpenAPI Document it will run the validation any time that type is encountered anywhere in the Document.

You create a new validation by specifying a check to perform on values and optionally a predicate that needs to return `true` for any value the check should be performed on. If you don't specify a predicate, the check is run for all values of the type the `Validation` is specialized for.

Let's start unpacking `Validation` by looking at an incomplete construction of a validation:
```swift
let validation = Validation<String>(
    check: { context in ... },
    where: { context in ... }
)
```

The context passed to both the `check` and `where` clause is a struct containing the entire OpenAPI Document (`.document`), the current coding path (`.codingPath`), and the value being validated (`.subject`).

The function passed as the `check` must return an array of `ValidationErrors` (or an empty array if validation passes). The function passed as the `where` argument must return a `Bool` (`true` means the value should be checked, `false` means it should be skipped).

As a silly example, maybe we want to assert that any time our OpenAPI Document contains a Specification Extension named `"x-string"` we want the extension to contain the `String` value "hello":
```swift
let validation = Validation<String>(
    check: { context in
        guard context.subject == "hello" else {
            return [ ValidationError(reason: "x-string needs to be 'hello'", at: context.codingPath) ]
        }
        return []
    },
    where: { context in context.codingPath.last?.stringValue == "x-string" }
)
```

Naturally, you could just as easily have defined the `validate` and `predicate` functions elsewhere:
```swift
let validate: (ValidationContext<String>) -> [ValidationError] = ...
let predicate: (ValidationContext<String>) -> Bool = ...

let validation = Validation(check: validate, where: predicate)
```

