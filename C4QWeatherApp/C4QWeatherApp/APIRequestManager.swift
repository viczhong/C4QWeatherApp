//
//  ApiRequestManager.swift
//  C4QWeatherApp
//
//  Created by Victor Zhong on 8/7/17.
//  Copyright © 2017 Victor Zhong. All rights reserved.
//

import Foundation

class APIRequestManager {
    
    static let manager = APIRequestManager()
    private init() {}
    
    func getData(endPoint: String, callback: @escaping (Data?) -> Void) {
        guard let myURL = URL(string: endPoint) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: myURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error during session: \(String(describing: error))")
            }
            guard let validData = data else { return }
            callback(validData)
            }.resume()
    }
    
    func postRequest(endPoint: String, data: [String:Any]) {
        guard let url = URL(string: endPoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let body = try JSONSerialization.data(withJSONObject: data, options: [])
            request.httpBody = body
        } catch {
            print("Error posting body: \(error)")
        }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Error encountered during post request: \(error)")
            }
            if response != nil {
                let httpResponse = (response! as! HTTPURLResponse)
                print("Response status code: \(httpResponse.statusCode)")
            }
            guard let validData = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: []) as? [String : Any]
                if let validJson = json {
                    print(validJson)
                }
            } catch {
                print("Error converting json: \(error)")
            }
            }.resume()
    }
    
    func deleteRequest(endPoint: String, id: Int, callback: @escaping (URLResponse?) -> Void) {
        let combinedEndpoint: String = "\(endPoint)\(id)"
        var request = URLRequest(url: URL(string: combinedEndpoint)!)
        request.httpMethod = "DELETE"
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            guard let _ = data else {
                print("error calling DELETE on \(combinedEndpoint)")
                return
            }
            
            if response != nil {
                callback(response)
            }
            
            print("DELETE ok")
            }.resume()
    }
    
    func putRequest(endPoint: String, id: Int, dataBody: [String : Any], callback: @escaping (HTTPURLResponse?) -> Void) {
        let combinedEndpoint: String = "\(endPoint)\(id)"
        var request = URLRequest(url: URL(string: combinedEndpoint)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let body = try JSONSerialization.data(withJSONObject: dataBody, options: [])
            request.httpBody = body
        }
            
        catch {
            print("Error posting body: \(error)")
        }
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Error encountered during post request: \(error)")
            }
            
            if response != nil {
                let httpResponse = (response! as! HTTPURLResponse)
                callback(httpResponse)
                print("Response status code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: []) as? [String:Any]
                if let validJson = json {
                    print(validJson)
                }
            }
                
            catch {
                print("Error converting json: \(error)")
            }
            }.resume()
    }
    
}
