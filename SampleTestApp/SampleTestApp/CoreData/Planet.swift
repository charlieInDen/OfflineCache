//
//  Planet.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/*
 Summary: We declare all the properties related to the entity with associated type, the property also need to be declared with @NSManaged keyword for the compiler to understand that this property will use Core Data at its backing store.
     We also create a simple function that maps a JSON Dictionary property and assign it to the properties of Film Managed Object.
 */
import CoreData

class Planet: NSManagedObject {
    @NSManaged var climate: String
    @NSManaged var gravity: String
    @NSManaged var name: String
    @NSManaged var terrain: String
    @NSManaged var population: String
    func update(with result: Result){
        self.population = result.population
        self.terrain = result.terrain
        self.name = result.name
        self.gravity = result.gravity
        self.climate = result.climate
    }
}
