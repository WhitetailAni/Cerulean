//
//  MetworkManager.swift
//  Cerulean
//
//  Created by WhitetailAni on 12/2/24.
//
import Foundation

class MetworkManager {
    static let shared: MetworkManager = {
        let configuration = URLSessionConfiguration.default
        
        let username = "40f17377c3c028c4a0457f93ab233eac"
        let password = "9c5e6505fa35fb12d65bf11e79dfd7db"
        
        let authString = "\(username):\(password)"
        
        guard let authData = authString.data(using: .utf8) else {
            fatalError("Could not create login data")
        }
        let encodedData = authData.base64EncodedString()
        
        configuration.httpAdditionalHeaders = [
            "Authorization": "Basic \(encodedData)"
        ]
        
        let session = URLSession(configuration: configuration)
        return MetworkManager(session: session)
    }()
    
    private let session: URLSession
    
    private init(session: URLSession) {
        self.session = session
    }
    
    func contactMetra(from urlString: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            completion(data, error)
        }
        
        task.resume()
    }
}
