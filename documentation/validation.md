
## Validation <!-- omit in toc -->

- [Executing Validations](#executing-validations)
- [Adding Validations](#adding-validations)
- [Creating New Validations](#creating-new-validations)
  - [`Validator.validating()`](#validatorvalidating)
    - [Predicates](#predicates)
    - [Context KeyPaths](#context-keypaths)
    - [Logical Combinations](#logical-combinations)
  - [The `Validation` Type](#the-validation-type)

### Executing Validations

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

### Creating New Validations

There are two ways to define validations:
1. Using the various `validating()` helper methods on the `Validatior`.
2. Directly creating values of the `Validation` type.

The first approach can be much more concise for most light-weight validations. The second approach is more verbose but it offers cleaner support for one validation producing more than one error. In either case, the context of a validation is (a) the entire `OpenAPI.Document`, (b) the value being validated, and (c) the coding path of the value being validated.

#### `Validator.validating()`

The simplest possible validations are equalities and inequalities. Such validations can usually be expressed using a KeyPath syntax starting with any OpenAPIKit type and ending with the value being checked followed by the appropriate equality or inequality.

To assert that the version of the OpenAPI Document is 3.0.0 we could write
```swift
Validator().validating(
   "Using OpenAPI v 3.0.0",
   check: \OpenAPI.Document.openAPIVersion == .v3_0_0
)
```

Just to immediately demystify this, the equivalent validation expressed as a closure is
```swift
Validator().validating(
    "Using OpenAPI v 3.0.0",
    check: { (context: ValidationContext<OpenAPI.Document>) in context.subject.openAPIVersion == .v3_0_0 }
)
```

Notice that when using the closure we are operating on the whole context and we drill into the `subject` which is the part of the context implicitly used by the previous KeyPath syntax.

We could assert that all server arrays in the document have more than 1 element
```swift
Validator().validating(
   "All server arrays have more than 1 server",
    check: \[OpenAPI.Server].count > 1
)
```

Or target just the server arrays on `OpenAPI.PathItems`
```swift
Validator().validating(
   "All Path Items have at least one server",
    check: \OpenAPI.PathItem.servers.count >= 1
)
```

If we want to stay lighter weight than the full `(ValidationContext<T>) -> Bool` closure but we need to do something more involved (like call functions on the value), the `take()` function will pull a value by KeyPath and pass it to a closure for us.
```swift
Validator().validating(
    "All servers have URLs containing the word 'prod'",
    check: take(\OpenAPI.Server.url.absoluteString) { $0.contains("prod") }
)
```

##### Predicates

We can assign predicates to validations to make the validation logic only apply to some values of the given type. 

For example, we could check that any time a list contains a server with a URL containing the word "test" we expect there to be at least two servers listed.
```swift
Validator().validating(
    "At least two servers are specified if one of them is the test server.",
    check: \[OpenAPI.Server].count >= 2,
    when: { context in
        context.subject.map { $0.url.absoluteString }.contains("https://test.server.com")
    }
)
```

Predicates passed to the `Validator.validating()` method have the same signature as the validation check functions and indeed can take all the same KeyPath forms.

##### Context KeyPaths

A context KeyPath is a KeyPath originating at the `ValidationContext` which means it has access to the `document` (the entire OpenAPI Document), `codingPath` (the location of the current value), and `subject` (the value being validated).

As long as something in the `validating()` method call (either the `check` or the `when` clause) provides a hint to the compiler as to the type of value being validated, either clause is free to use context KeyPaths to build predicates or validation logic based on parts of the context other than the value being validated.

For example, the following validation is on a `\.subject` of type `String` so the predicate is free to only reference the `\.codingPath`. It's a silly example, but it shows one way you can apply validations to Specification Extensions.
```swift
Validator().validating(
    "x-string is 'hello'",
    check: \.subject == "hello",
    when: \.codingPath.last?.stringValue == "x-string"
)
```

If the syntax is making your head hurt a bit, take a look at the same validation with fully qualified KeyPaths:
```swift
Validator().validating(
    "x-string is 'hello'",
    check: \ValidationContext<String>.subject == "hello",
    when: \ValidationContext<String>.codingPath.last?.stringValue == "x-string"
)
```

In the second example the verbosity hurts the legibility but it is a bit more obvious that the check is going to run any time the Validator finds a `String` but before it tests whether the `subject` (the `String` in question) is equal to "hello" it is going to check that the last component of the coding path is "x-string" and skip the validation if not.

##### Logical Combinations

Any two individually valid arguments to `check` or `when` can be combined using `&&` (logical AND) or `||` (logical OR).

For example
```swift
Validator().validating(
    "Operations must contain a status code 500 or there must be two possible responses",
    check: take(\OpenAPI.Response.Map.keys) { $0.contains(500) }
        || \.count == 2  // Response.Map.count
)
```

#### The `Validation` Type

The `Validation` type defines a validation. Each validation is specialized on one particular type that it applies to. For example, the `.pathsContainsOperations` validation applies to `OpenAPI.PathItem`. When the Validator is validating an OpenAPI Document it will run the validation any time that type is encountered anywhere in the Document.

You create a new validation by specifying a check to perform on values and optionally a predicate that needs to return `true` for any value the check should be performed on. If you don't specify a predicate, the check is run for all values of the type the `Validation` is specialized for.

Let's start unpacking `Validation` by looking at an incomplete construction of a validation:
```swift
let validation = Validation<String>(
    check: { context in ... },
    when: { context in ... }
)
```

The context passed to both the `check` and `when` clause is a struct containing the entire OpenAPI Document (`.document`), the current coding path (`.codingPath`), and the value being validated (`.subject`).

The function passed as the `check` must return an array of `ValidationErrors` (or an empty array if validation passes). The function passed as the `when` argument must return a `Bool` (`true` means the value should be checked, `false` means it should be skipped).

To bring back a silly example from the above section, maybe we want to assert that any time our OpenAPI Document contains a Specification Extension named `"x-string"` we want the extension to contain the `String` value "hello":
```swift
let validation = Validation<String>(
    check: { context in
        guard context.subject == "hello" else {
            return [ ValidationError(reason: "x-string needs to be 'hello'", at: context.codingPath) ]
        }
        return []
    },
    when: { context in context.codingPath.last?.stringValue == "x-string" }
)
```

Because we return an array of errors from our `validate` function when constructing a `Validation` in this way, we don't have access to the same KeyPath helpers we used in the previous section. We can, however, use those helpers for our `predicate`.

Here's the same example with a slightly more concise `when` clause.
```swift
let validation = Validation<String>(
    check: { context in
        guard context.subject == "hello" else {
            return [ ValidationError(reason: "x-string needs to be 'hello'", at: context.codingPath) ]
        }
        return []
    },
    when: \.codingPath.last?.stringValue == "x-string"
)
```

We can get the most concise syntax when we only need to produce a single error from our `Validation`. In that case, the construction will look identical to those in the previous section on the `validating()` method except for the `description` argument label being spelled out.

Note that in this example we can drop the explicit `<String>` specialization because the compiler can infer it.
```swift
let validation = Validation(
    description: "x-string is 'hello'",
    check: \.subject == "hello",
    when: \.codingPath.last?.stringValue == "x-string"
)
```

Naturally, you could just as easily define the `validate` and `predicate` functions elsewhere:
```swift
let validate: (ValidationContext<String>) -> [ValidationError] = ...
let predicate: (ValidationContext<String>) -> Bool = ...

let validation = Validation(check: validate, when: predicate)
```
