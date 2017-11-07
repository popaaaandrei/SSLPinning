//
//  ViewController.swift
//  SSLPinning
//
//  Created by andrei on 06/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import UIKit
import RxSwift


class ViewController: UIViewController {

    
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel
            .rx_getRepos()
            .subscribe(onNext: { value in
                print("value: \(value)")
            }, onError: { error in
                print("error: \(error)")
            })
            .disposed(by: disposeBag)
        
        
    }



}

