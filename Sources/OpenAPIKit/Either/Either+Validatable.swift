//
//  Either+Validatable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

extension Either: @retroactive Validatable where A: Validatable, B: Validatable {}
