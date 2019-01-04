//
//  PlanetViewModel.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
typealias FetchDataCallback = (Error?) -> Void
final class PlanetViewModel {
    var planetNames: [String]? //list of planet names from the first page of planet data
    let planetService: PlanetService
    let syncCordinator: CoreDataSyncCordinator
    init(service: PlanetService, syncCordinator: CoreDataSyncCordinator) {
        self.planetService = service
        self.syncCordinator = syncCordinator
    }
    func fetchData(_ urlString:String, completionHandler: @escaping FetchDataCallback){
        planetService.getPlanetList(forRequestURL: urlString) { (result, error) in
            guard let planetResult = result else {
                return
            }
            DispatchQueue.main.async {
                self.syncCordinator.fetchedPlanetData(planetResult.results, completion: { (error) in
                    completionHandler(error)
                })
            }
            
        }
    }
}


