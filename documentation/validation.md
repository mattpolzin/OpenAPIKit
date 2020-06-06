
## Validation <!-- omit in toc -->

- [Executing Validations](#executing-validations)
- [Adding Validations](#adding-validations)
- [Creating New Validations](#creating-new-validations)
  - [`Validator.validating()`](#validatorvalidating)
    - [Predicates](#predicates)
    - [Context KeyPaths](#context-keypaths)
    - [Logical Combinations](#logical-combinations)
  - [The `Validation` Type](#the-validation-type)
    - [Validation Composition](#validation-composition)
  - [A "Real" Example](#a-real-example)
    - [Passing OpenAPI Document](#passing-openapi-document)
    - [Failing OpenAPI Document](#failing-openapi-document)
    - [Validation Code](#validation-code)

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
2. Creating values of the `Validation` type.

The first approach can be more concise for most light-weight validations. The second approach is more verbose but it offers cleaner support for one validation producing more than one error and provides opportunities to compose validations together. In either case, the context of a validation is (a) the entire `OpenAPI.Document`, (b) the value being validated (we'll call this the "subject"), and (c) the coding path of the value being validated.

#### `Validator.validating()`

The simplest possible validations are equalities and inequalities. Such validations can usually be expressed using a KeyPath syntax starting with any OpenAPIKit type and ending with the value being checked followed by the appropriate equality or inequality. 

I'll call this the "Subject KeyPath syntax" because the type of the root of the KeyPath is the "subject" of the validation context.

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

Notice that when using the closure we are operating on the whole context and we drill into the `subject` which is the part of the context implicitly used by the Subject KeyPath syntax.

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

If we want to stay more light-weight than the full `(ValidationContext<T>) -> Bool` closure but we need to do something more involved (like call functions on the **subject**), the `take()` function will pull a value by KeyPath and pass it to a closure for us.
```swift
Validator().validating(
    "All servers have URLs containing the word 'prod'",
    check: take(\OpenAPI.Server.url.absoluteString) { $0.contains("prod") }
)
```

##### Predicates

We can assign predicates to validations to make the validation logic only apply to some values of the given type. 

For example, we could assert that any time a server list contains a server with the "test server" URL, we expect there to be at least two servers listed.
```swift
Validator().validating(
    "At least two servers are specified if one of them is the test server.",
    check: \[OpenAPI.Server].count >= 2,
    when: { context in
        context.subject.map { $0.url.absoluteString }.contains("https://test.server.com")
    }
)
```

Predicates passed to the `Validator.validating()` method have the same signature as the validation check functions and indeed can take advantage of all the same KeyPath syntax.

##### Context KeyPaths

A Context KeyPath is a KeyPath originating at the `ValidationContext` which means it has access to the `document` (the entire OpenAPI Document), `codingPath` (the location of the current value), and `subject` (the value being validated).

As long as something in the `validating()` method call (either the `check` or the `when` clause) provides a hint to the compiler as to the type of value being validated, either clause is free to use context KeyPaths to build predicates or validation logic based on parts of the context other than the **subject**.

For example, the following validation is on a `\.subject` of type `String` so the predicate is free to only reference the `\.codingPath`. It's a silly example, but it shows one way you can apply validations to Specification Extensions.
```swift
Validator().validating(
    "x-string is always 'hello'",
    check: \.subject == "hello",
    when: \.codingPath.last?.stringValue == "x-string"
)
```

If the syntax is making your head hurt a bit, take a look at the same validation with fully qualified KeyPaths:
```swift
Validator().validating(
    "x-string is always 'hello'",
    check: \ValidationContext<String>.subject == "hello",
    when: \ValidationContext<String>.codingPath.last?.stringValue == "x-string"
)
```

In the second example the verbosity hurts the visual flow a bit but it is more obvious that the check is going to run any time the Validator finds a `String` but before it tests whether the `subject` (the `String` in question) is equal to "hello" it is going to check that the last component of the coding path is "x-string" and skip the validation if not.

##### Logical Combinations

Any two individually valid arguments to `check` or `when` can be combined using `&&` (logical AND) or `||` (logical OR).

For example
```swift
Validator().validating(
    "Operations must contain a status code 500 or there must be two possible responses",
    check: take(\OpenAPI.Response.Map.keys) { $0.contains(500) }
        || \.count == 2  // \.Response.Map.count == 2
)
```

#### The `Validation` Type

The `Validation` type defines a validation. Each validation is specialized on one particular type that it applies to. For example, the `.pathsContainOperations` validation applies to `OpenAPI.PathItem`. When the Validator is validating an OpenAPI Document it will run the validation any time that type is encountered anywhere in the Document.

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

##### Validation Composition

Validations can be applied as part of other validations. You can use a parent validation context to gate child validations based on a shared `when` clause, drill into a parent context within the `check` clause, and reuse child validations in multiple parent validations.

Let's say you want to assert that all requests and responses are offered as JSON. You might be tempted to write the following validator
```swift
let allRoutesOfferJSON = Validation(
    description: "All content maps have JSON members.",
    check: \OpenAPI.Content.Map[.json] != nil
)
```

Unfortunately, now you are also validating that the content map that can be associated with parameters offers a JSON option; that might be ok, but it is definitely not the stated goal.

We could add a `when` clause that looks at the context's `codingPath` to determine whether the current context is a parameter, a request, or a response, but that's going to get cumbersome fast.

Instead, let's compose the content map validator with a validator that only runs against `OpenAPI.Response`. Then we will do the same thing with a validator that only runs against `OpenAPI.Request`. We need a new tool for this. The `lift()` function will let us use a KeyPath to map the current context to a new context and then run a validator in that new context.
```swift
let requestRoutesOfferJSON = Validation(
    check: lift(\OpenAPI.Request.content, into: allRoutesOfferJSON)
)

let responseRoutesOfferJSON = Validation(
    check: lift(\OpenAPI.Response.content, into: allRoutesOfferJSON)
)

try document.validate(using: Validator()
    .validating(requestRoutesOfferJSON)
    .validating(responseRoutesOfferJSON)
)
```

Notice we are using the `Validation` initializer that does not take a description for the parent validations. These validations can potentially produce any of the errors of their children validations but because they don't themselves represent one distinct potential error there is no description associated with them.

`lift()` can take a variadic list of any number of validators, so if we had an `allRoutesOfferXML` validator as well then we could write 
```swift
lift(\OpenAPI.Response.content, into: allRoutesOfferJSON, allRoutesOfferXML)
```

`lift()` does have its limits, though. One you'll hit pretty quickly is that you can't use any optional chaining in your KeyPath if you are lifting into a validator that expects a non-optional value in its context. This is actually a good thing -- we must be explicit about whether or not to error out if the optional unwrapping results in `nil`.

Let's pass a response's JSON content to a validation that operates on content:
```swift
let contentValidation = Validation<OpenAPI.Content>(...)

let contentMapValidator = Validation(
    check: lift(\OpenAPI.Content.Map[.json], into: contentValidation)
    // ^ error about the KeyPath pointing at `OpenAPI.Content?` instead of `OpenAPI.Content`.
)
```

Instead, we must use the `unwrap()` function. It operates similarly to `lift()` except if it encounters `nil` it will produce a `ValidationError`.
```swift
let contentValidation = Validation<OpenAPI.Content>(...)

let contentMapValidator = Validation(
    check: unwrap(\OpenAPI.Content.Map[.json], into: contentValidation)
)
```

That leaves the question of how to specify that the unwrap should _not_ fail if it hits an optional. It turns out, we already have a good way to be explicit about this with a `when` clause.
```swift
let contentValidation = Validation<OpenAPI.Content>(...)

let contentMapValidator = Validation(
    check: unwrap(\OpenAPI.Content.Map[.json], into: contentValidation),
    when: \OpenAPI.Content.Map[.json] != nil
)
```

#### A "Real" Example

Let's put this all together to form a slightly more realistic example of fully operational code (could be copy/pasted into a Swift project or playground with access to OpenAPIKit).

The setup is that we need to verify that no matter how many endpoints we add to the API we are documenting all `POST` resource requests contain a `'name'` property and all `POST` resource responses contain both a `'name'` and and `'id'`.

First, let's establish some test material so we can visualize what we are checking.

##### Passing OpenAPI Document
```swift
let createRequest = OpenAPI.Request(
   content: [
       .json: .init(
           schema: .object(
               properties: [
                   "name": .string,
                   "classification": .string(allowedValues: "big", "small")
               ]
           )
       )
   ]
)

let successCreateResponse = OpenAPI.Response(
   description: "Created Widget",
   content: [
       .json: .init(
           schema: .object(
               properties: [
                   "id": .integer,
                   "name": .string,
                   "classification": .string(allowedValues: "big", "small")
               ]
           )
       )
   ]
)

let document = OpenAPI.Document(
   info: .init(title: "test", version: "1.0"),
   servers: [],
   paths: [
       "/widget/create": .init(
           post: .init(
               requestBody: createRequest,
               responses: [
                   201: .response(successCreateResponse)
               ]
           )
       )
   ],
   components: .noComponents
)
```

##### Failing OpenAPI Document
```swift
// should fail in three ways:
// 1. No `name` in request schema
// 2. No `name` in response schema
// 3. No `id` in response schema

let createRequest = OpenAPI.Request(
   content: [
       .json: .init(
           schema: .object(
               properties: [
                   "classification": .string(allowedValues: "big", "small")
               ]
           )
       )
   ]
)

let successCreateResponse = OpenAPI.Response(
   description: "Created Widget",
   content: [
       .json: .init(
           schema: .object(
               properties: [
                   "classification": .string(allowedValues: "big", "small")
               ]
           )
       )
   ]
)

let document = OpenAPI.Document(
   info: .init(title: "test", version: "1.0"),
   servers: [],
   paths: [
       "/widget/create": .init(
           post: .init(
               requestBody: createRequest,
               responses: [
                   201: .response(successCreateResponse)
               ]
           )
       )
   ],
   components: .noComponents
)
```

##### Validation Code
```swift
// First, we define two validators that dig into
// JSON schemas looking for the 'name' or 'id'
// properties and verifying those properties are of
// the correct type.
//
// Notice that these validators don't actually care
// about their context because we will isolate parts of
// the OpenAPI document to validate with their parent
// validations.
let resourceContainsName = Validation<JSONSchema>(
   description: "All JSON resources must have a String name",
   check: take(\.subject) { schema in
       guard case let .object(_, context) = schema,
           let nameProperty = context.properties["name"] else {
               return false
       }
       return nameProperty.jsonTypeFormat?.jsonType == .string
   }
)

let responseResourceContainsId = Validation<JSONSchema>(
   description: "All JSON response resources must have an Id",
   check: take(\.subject) { schema in
       guard case let .object(_, context) = schema,
           let idProperty = context.properties["id"] else {
               return false
       }
       return idProperty.jsonTypeFormat?.jsonType == .integer
   }
)

// Now we create a validation that runs for all requests that
// have non-nil JSON schemas inlined within them. We use a `when`
// clause to skip over any requests that do not have such schemas
// without error.
let requestBodyContainsName = Validation(
   check: unwrap(\.content[.json]?.schema.schemaValue, into: resourceContainsName),

   when: \OpenAPI.Request.content[.json]?.schema.schemaValue != nil
)

// Similarly, we check JSON response schemas.
let responseBodyContainsNameAndId = Validation(
   check: unwrap(\.content[.json]?.schema.schemaValue, into: resourceContainsName, responseResourceContainsId),

   when: \OpenAPI.Response.content[.json]?.schema.schemaValue != nil
)

// We are specifically looking only at 201 ("created") status code
// responses in this example so we create another parent context
// validation for responses (_requests_ are not broken down by _response_
// status code (obviously) so this step is not needed for requests).
//
// Notice we do not use a `when` clause here because we want the check
// to run even when the subject is `nil` so it will produce an error
// if we find a POST operation that does not define a `201` status
// response. We also give this unwrap call a description that we want
// used in the creation of an error message if the validation does find
// a missing `201` response definition.
let successResponseBodyContainsNameAndId = Validation(
   check: unwrap(
       \OpenAPI.Response.Map[.status(code: 201)]?.responseValue,
       into: responseBodyContainsNameAndId,
       description: "201 status response value"
    )
)

// The last validation we create operates on POST operations of
// path items. We use two separate `unwrap()` calls because we
// want to run child validations against both the request body
// and the responses.
let postRequestAndResponsesAreValid = Validation(
    check: unwrap(
        \OpenAPI.PathItem[.post]?.requestBody?.requestValue,
        into: requestBodyContainsName
    )
    && unwrap(
        \OpenAPI.PathItem[.post]?.responses,
        into: successResponseBodyContainsNameAndId
    ),

    when: \OpenAPI.PathItem[.post] != nil
)

// Finally, we can create our Validator and add the POST request validation. 
// The various child validations not directly added below are not strictly 
// necessary and could have been written into the logic of their parent
// validtions. Doing so would have meant replacing small composable validtions
// with large validations containing a lot of logic in their `check` or `when`
// clauses.
let validator = Validator()
    .validating(postRequestAndResponsesAreValid)

try document.validate(using: validator)
```