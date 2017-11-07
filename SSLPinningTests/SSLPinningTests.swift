//
//  SSLPinningTests.swift
//  SSLPinningTests
//
//  Created by andrei on 06/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//


import XCTest
import RxSwift
@testable import SSLPinning



class SSLPinningTests: XCTestCase {
    
    
    private let disposeBag = DisposeBag()
    
    
    
    /// test if we have a valid connection
    func testIsConnectedToNetwork() {
        XCTAssert(isConnectedToNetwork(), "We should have a valid internet connection")
    }
    
    
    /// instantiate with GitHub certificate
    func testCertificateInstantiation2() {
        let 🦁 = 🐯(withCertificate: .github)
        XCTAssertNotNil(🦁, "we should be able to instantiate the Github certificate")
    }
    
    
    /// instantiate with GitHub certificate, call github
    func testSSLPinningGitHub() {
        
        // test that we can instantiate the certificate
        guard let 🐯 = 🐯(withCertificate: .github) else {
            XCTFail("couldn't initialize Networking with this certificate")
            return
        }
        
        // test that we have a valid URL
        guard let url = URL(string: Router.baseURL) else {
            XCTFail("couldn't initialize URL")
            return
        }
        let request = URLRequest(url: url)
        
        
        let _expectation = expectation(description: "operationAsync")
        
        🐯.rx_request(request)
            .subscribe(onNext: { value in
                XCTAssertNotNil(value, "The server response shouldn't be nil")
                _expectation.fulfill()
            }, onError: { error in
                XCTFail("We shouldn't have failed here: \(error)")
                _expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }

    
}
