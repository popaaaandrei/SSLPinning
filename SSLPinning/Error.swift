//
//  Error.swift
//  SSLPinning
//
//  Created by andrei on 06/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import Foundation



public enum 😱: Error, CustomStringConvertible {
    
    case certificate
    case withMessage(message: String)
    case ssl

    
    public var description: String {
        switch self {
        case .certificate: return "certificate error"
        case .withMessage(let message): return "network error: \(message)"
        case .ssl: return "server certificate failed validation"
        
        }
    }
}
