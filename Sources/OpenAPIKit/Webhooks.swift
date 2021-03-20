//
//  Webhooks.swift
//  
//
//  Created by Mihaela Mihaljevic Jakic on 20.03.2021..
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement.
    /// Closely related to the callbacks feature, this section describes requests initiated other than by an API call, for example by an out of band registration.
    /// The key name is a unique string to refer to each webhook, while the (optionally referenced) Path Item Object (`OpenAPI.PathItem`)
    /// describes a request that may be initiated by the API provider and the expected responses.
    /// See [OpenAPI Webhook Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#fixed-fields)
    public typealias Webhooks = OrderedDictionary<String, PathItem>
    
    /// A map of named collections of Webhook Objects (`OpenAPI.Webhooks`).
    public typealias WebhooksMap = OrderedDictionary<String, Either<JSONReference<Webhooks>, Webhooks>>
}
