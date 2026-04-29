## OpenAPIKit v6 Migration Guide

OpenAPIKit v6 introduces no breaking code changes.

The minimum Swift version has increased to Swift 6.1.

### External Loading
The external loading capabilities introduced in OpenAPIKit v4.0.0 have been
moved into a Trait. The trait is enabled by default, but you can disable it if
you don't want to use the external loading features and you want to save some
time compiling OpenAPIKit. The Swift compiler is notably slow to compile Swift
Concurrency features so turning the trait off can save around 50% of the
compile time.

There is no known runtime cost to the trait being on, just the compile time
cost.
