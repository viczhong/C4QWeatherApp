//
//  APIRequestManager.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/7/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import Foundation

class APIRequestManager {
    
    static let manager = APIRequestManager()
    private init() {}
    
    
    func getData(endPoint: String, callback: @escaping (Data?, Error?) -> Void) {
        guard let myURL = URL(string: endPoint) else { return }

        let customConfig = URLSessionConfiguration.default
        customConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        customConfig.urlCache = nil
        
        let session = URLSession(configuration: customConfig)
        session.dataTask(with: myURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error during session: \(String(describing: error))")
            }
            
            // guard let validData = data else { return }
            callback(data, error)
            }.resume()
    }
}
