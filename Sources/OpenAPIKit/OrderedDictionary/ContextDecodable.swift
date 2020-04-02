//
//  ContextDecodable.swift
//  
//
//  Created by Mathew Polzin on 4/1/20.
//

import Foundation

internal protocol ContextDecodable {
    associatedtype DecodingContext

    init(from decoder: Decoder, in context: DecodingContext) throws
}
