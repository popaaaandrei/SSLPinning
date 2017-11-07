//
//  ViewModelTests.swift
//  SSLPinningTests
//
//  Created by andrei on 07/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import XCTest
import RxSwift
@testable import SSLPinning



class ViewModelTests: XCTestCase {
    
    
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    
    
    /// test if we have a valid connection
    func testIsConnectedToNetwork() {
        XCTAssert(isConnectedToNetwork(), "We should have a valid internet connection")
    }
    
    
    func testGetRepos() {
        
        let _expectation = expectation(description: "operationAsync")
        
        viewModel
            .rx_getRepos()
            .subscribe(onNext: { value in
                XCTAssert(value.count == 11, "We should receive 10 Repositories")
                _expectation.fulfill()
            }, onError: { error in
                XCTFail("We shouldn't have failed here: \(error)")
                _expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }

    
}
