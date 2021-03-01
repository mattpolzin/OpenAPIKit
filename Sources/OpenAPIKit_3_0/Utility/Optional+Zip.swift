//
//  Optional+Zip.swift
//  
//
//  Created by Mathew Polzin on 8/1/20.
//

internal func zip<T, U>(_ left: T?, _ right: U?) -> (T, U)? {
    return left.flatMap { left in right.map { right in (left, right) } }
}
