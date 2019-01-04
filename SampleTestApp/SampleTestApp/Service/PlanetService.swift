//
//  PlanetService.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary: Networking Coordinator that connects to the Planet API to fetch list of planets from the network. It provides public method to get planets with completion closure as the parameter.
 */
import Foundation


typealias PlanetServiceCallback = (_ data: PlanetResult?, _ error: Error?) -> Void
protocol PlanetService {
    //GET /api/planets/
    func getPlanetList(forRequestURL url: String,
                      andCallback callback: @escaping PlanetServiceCallback)
}
enum PlanetListError: Error {
    case invalidURL
    case invalidData
    case none
}
class PlanetServiceImpl: PlanetService {
    func getPlanetList(forRequestURL urlStr: String,
                       andCallback callback: @escaping PlanetServiceCallback) {
        // Make it look like method needs some time to communicate with the server
        //Read data from URL
        guard let url = URL.init(string: urlStr) else {
            callback(nil, PlanetListError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            guard let jsonData = data else {
                callback(nil, PlanetListError.invalidData)
                return
            }
            //Convert responseData to json
            guard let responseJson = try? JSONDecoder().decode(PlanetResult.self, from: jsonData) else {
                callback(nil, PlanetListError.invalidData)
                return
            }
            callback(responseJson, PlanetListError.none)
            }.resume()
    }
    
    
}
