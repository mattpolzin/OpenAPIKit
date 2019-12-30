//
//  HttpVerb.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI {
    public enum HttpVerb: String, CaseIterable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case trace = "TRACE"
    }
}
