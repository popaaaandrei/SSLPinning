//
//  ViewModel.swift
//  SSLPinning
//
//  Created by andrei on 07/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import Foundation
import RxSwift



class ViewModel {
    
    
    func rx_getRepos() -> Observable<[Repo]> {
        
        guard let 🐯 = 🐯(withCertificate: .github) else {
            return Observable.error(😱.certificate)
        }
        
        guard let request = Router.repos.request() else {
            return Observable.error(😱.withMessage(message: "route instantiation error"))
        }
        
        return 🐯
            .rx_request(request)
            .map({ return try JSONDecoder().decode([Repo].self, from: $0) })
    }
    
    
}
