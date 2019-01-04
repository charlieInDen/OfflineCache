//
//  CoreDataStack.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/*
 Summary:Responsible for building the NSPersistentContainer using the schema.
 It is a Singleton class that exposes NSPersistentContainer public variable. To initialize the container, we just pass the filename of the Managed Object Model schema
 */

import CoreData

class CoreDataStack {
    
    private init() {}
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlanetModel")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
}
