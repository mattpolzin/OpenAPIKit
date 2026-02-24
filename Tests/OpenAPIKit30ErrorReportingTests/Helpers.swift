//
//  Helpers.swift
//  

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@preconcurrency import Yams

var testDecoder: YAMLDecoder { YAMLDecoder() }
