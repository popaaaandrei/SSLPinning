//
//  Networking.swift
//  SSLPinning
//
//  Created by andrei on 06/11/2017.
//  Copyright © 2017 Andrei Popa. All rights reserved.
//

import Foundation
import RxSwift
import SystemConfiguration


// ===========================================================================
// MARK: Router
// ===========================================================================
enum Router {
    
    
    static let baseURL = "https://api.github.com/users/popaaaandrei"
    
    
    case repos
    
    
    
    var method: String {
        switch self {
        case .repos: return "GET"
        }
    }
    
    var path: String {
        switch self {
        case .repos: return "repos"
        }
    }

    func request() -> URLRequest? {
        
        // URL
        guard let url = URL(string: Router.baseURL)?.appendingPathComponent(path) else {
            return nil
        }
        
        // URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        return request
    }

}



// ===========================================================================
// MARK: Network request executor
// ===========================================================================
class 🐯 : NSObject, URLSessionDelegate {
    
    
    let pinnedCertificate : SecCertificate

    
    init?(withCertificate certificate: Certificate) {
        guard let _certificate = certificate.certificate else {
            return nil
        }
        self.pinnedCertificate = _certificate
        super.init()
    }
    

    /// abstraction of networking call into Rx Observable
    public func rx_request(_ request: URLRequest) -> Observable<Data> {
        
        return Observable.create { observer in
            
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            
            let task = session.dataTask(with: request) { (data, _, error) in
                if let data = data {
                    observer.on(.next(data))
                    observer.on(.completed)
                }
                
                if let error = error {
                    // if SSL Pinning error
                    let nserror = error as NSError
                    if nserror.code == NSURLErrorCancelled, nserror.userInfo.keys.contains(NSURLErrorFailingURLErrorKey) {
                        observer.on(.error(😱.ssl))
                    } else {
                        // other errors
                        observer.on(.error(error))
                    }
                }
            }
            
            task.resume()
            
            // if this observable is disposed, make sure to stop the request
            return Disposables.create {
                task.cancel()
            }
            
        }
    }

    
    // needs a certificate in DER format, what we got is PEM
    // openssl x509 -outform der -in certificate.crt -out certificate.der
    /// decide policy for challenge
    // ===========================================================================
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // we need to have a server certificate, otherwise fail
        // we already have the pinned certificate
        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }
        
        // 1) Evaluate server certificate
        var result = SecTrustResultType.invalid
        // a) define policy object for evaluating SSL certificate chain
        // the policy will require the specified hostname to match the hostname in the leaf certificate.
        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        // b) set the policy for evaluation
        SecTrustSetPolicies(serverTrust, policy)
        // c) evaluate
        SecTrustEvaluate(serverTrust, &result)
        
        // anything else other than the .Proceed and .Unspecified, we can consider the certificate to be invalid (untrusted). -> fail
        guard (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // DER representation of the Server certificate
        let serverCertificateDER = SecCertificateCopyData(serverCertificate)
        // DER representation of the pinned certificate
        let localCertificateDER = SecCertificateCopyData(pinnedCertificate)
        
        // 2) certificates must match
        guard serverCertificateDER == localCertificateDER else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // everything good, tests passed
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
    
    
}







// ===========================================================================
// MARK: Reachability
// ===========================================================================
func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return (isReachable && !needsConnection)
}

