//
//  NetworkRequestFetcher.swift
//  Pods
//
//  Created by Alex da Franca on 23/10/15.
//
//

import UIKit

/**
 This class extends the original NetworkFetcher from Haneke in order to accept a NSURLRequest rather than only a NSURL
 
 Reason: We need to be able to "mess" with the User-Agent. We can not use the default iOS User-Agent
 Otherwise we will not get the correct images, meant for mobile.
 That is unfortunate IMO, but it's how it works at the moment.
 
 Haneke uses the sharedSession of NSURLSession (NSURLSession.sharedSession()) forthe requests.
 Until iOS 9 we could just add the User-Agent to the additionalHTTPHeeders of the sharedSession,
 this is not the case anymore for iOS >= 9 (is that a bug or intended?)
 
 So now we create the request outside of Haneke, where we define the httpHeaders ourselves
 and then instead of fetching a NSURL, we fetch this NSURLRequest with our custom HTTPHeaders
 */

public class NetworkRequestFetcher<T : DataConvertible> : NetworkFetcher<T> {
    let request: URLRequest
    
    public init(request : URLRequest) {
        self.request = request
        guard let url = request.url else {
            fatalError("Haneke Image loader: can't load image request without URL")
        }
        super.init(URL: url)
    }
    
    public override func fetch(failure fail : @escaping ((Error?) -> ()), success succeed : @escaping (T.Result) -> ()) {
        self.cancelled = false
        
        self.task = self.session.dataTask(with: self.request, completionHandler: { [weak self] (data, response, error) -> Void in
            if let strongSelf = self {
                strongSelf.onReceiveData(data: data , response: response, error: error , failure: fail, success: succeed)
            }
        })
        self.task?.resume()
    }
}
