//
//  DiggingError.swift
//  
//
//  Created by Mathew Polzin on 5/2/20.
//

/// A `DiggingError` is an error that knows how to dig deeper into its
/// underlying context to attempt to pull out a more granular reason for the
/// failure.
///
/// This is a relevant concept with respect to `DecodingError`s in particular
/// because they often have underlying causes.
///
public protocol DiggingError {
    /// Initialize this error with a `DecodingError` and
    /// unwrap it if possible to instead a expose a more
    /// granular underlying error.
    init(unwrapping error: Swift.DecodingError)
}

extension DiggingError {
    /// Returns one of the branches of the `EitherDecodeNoTypesMatchedError`
    /// or `nil`, depending on whether it is heuristically beneficial to dig into either
    /// branch in search of a more granular error.
    ///
    /// If an `Either` fails to decode and the most useful error for the user is just
    /// that neither option of the `Either` was found, then this function returns `nil`
    /// which indicates neither branch should be dug into.
    ///
    /// On the other hand, one of the two branches of the `Either` might have failed to decode
    /// trivially (i.e. the user does not need to know that both branches failed because one
    /// of those branches is very unlikely to have been the intended one). If that happens, it is
    /// more useful to dig into the less trivial branch and display a more granular error to the user
    /// from deeper in that brach. When this occurs, this function retruns the udnerlying error on
    /// that branch.
    public static func eitherBranchToDigInto(_ eitherError: EitherDecodeNoTypesMatchedError) -> DecodingError? {
        // Just a guard against this being an error with more than 2 branches.
        guard eitherError.individualTypeFailures.count == 2 else { return nil }

        let firstFailureIsReference = eitherError.individualTypeFailures[0].typeString == "$ref"
        let secondFailureIsReference = eitherError.individualTypeFailures[1].typeString == "$ref"

        let firstFailureIsDeeper = eitherError.individualTypeFailures[0].codingPath(relativeTo: eitherError.codingPath).count > 1
        let secondFailureIsDeeper = eitherError.individualTypeFailures[1].codingPath(relativeTo: eitherError.codingPath).count > 1

        let firstFailureNestsAnEitherError = eitherError.individualTypeFailures[0].error.underlyingError is EitherDecodeNoTypesMatchedError
        let secondFailureNestsAnEitherError = eitherError.individualTypeFailures[1].error.underlyingError is EitherDecodeNoTypesMatchedError

        // The goal here is to report errors that are more granular when appropriate.
        // it is heuristically nice to report more granular (i.e. more deeply nested errors)
        // any time one of the two legs of an Either decoding failure is deeper than 1.
        // It is also good to dig deeper if you hit another Either decoding error immediately.

        if firstFailureIsReference && (secondFailureIsDeeper || secondFailureNestsAnEitherError) {
            return eitherError.individualTypeFailures[1].error
        } else if secondFailureIsReference && (firstFailureIsDeeper || firstFailureNestsAnEitherError) {
            return eitherError.individualTypeFailures[0].error
        }

        return nil
    }
}
