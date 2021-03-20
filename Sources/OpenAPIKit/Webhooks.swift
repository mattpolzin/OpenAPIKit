//
//  Webhooks.swift
//  
//
//  Created by Mihaela Mihaljevic Jakic on 20.03.2021..
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    public typealias Webhooks = OrderedDictionary<String, PathItem>
    public typealias WebhooksMap = OrderedDictionary<String, Either<JSONReference<Webhooks>, Webhooks>>
}
