//
//  JSONSchemaFragment+Resolving.swift
//  
//
//  Created by Mathew Polzin on 8/1/20.
//

extension Array where Element == JSONSchemaFragment {
    /// An array of schema fragments can be resolved into a
    /// single `DereferencedJSONSchema` if all references can
    /// be looked up locally and none of the fragments conflict.
    public func resolved(against components: OpenAPI.Components) throws -> DereferencedJSONSchema {
        #warning("unimplemented")
        throw JSONSchemaResolutionError()
    }
}

public struct JSONSchemaResolutionError: Swift.Error {

}
