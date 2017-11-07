//
//  Certificate.swift
//  SSLPinning
//
//  Created by andrei on 06/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import Foundation



// ===========================================================================
// MARK: Certificate
// ===========================================================================
enum Certificate {
    
    case github
    
    
    private var name: String {
        switch self {
        case .github: return "github.com"
        }
    }
    
    private var ext: String {
        switch self {
        case .github: return "cer"
        }
    }
    
    var certificate: SecCertificate? {
        return SecCertificate.certificate(withName: name, withExtension: ext)
    }
    
}


// ===========================================================================
// MARK: SecCertificate extensions
// ===========================================================================
extension SecCertificate {
    
    /// return a certificate from Bundle as SecCertificate
    public static func certificate(withName name: String, withExtension extension: String = "crt") -> SecCertificate? {
        
        guard let certificateData = SecCertificate.certificateData(withName: name, withExtension: `extension`) else {
            return nil
        }
        
        // Returns nil if the data passed in the data parameter is not a valid DER-encoded X.509 certificate.
        return SecCertificateCreateWithData(nil, certificateData as CFData)
    }
    
    /// return a certificate from Bundle as Data
    public static func certificateData(withName name: String, withExtension extension: String = "crt") -> Data? {
        
        // [".cer", ".CER", ".crt", ".CRT", ".der", ".DER"]
        guard let url = Bundle.main.url(forResource: name, withExtension: `extension`) else {
            return nil
        }
        
        // A DER (Distinguished Encoding Rules) representation of an X.509 certificate.
        guard let certificateData = try? Data(contentsOf: url) else {
            return nil
        }
        
        return certificateData
    }
    
}



