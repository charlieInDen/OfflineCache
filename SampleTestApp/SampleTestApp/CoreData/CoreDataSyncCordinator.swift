//
//  CoreDataSyncCordinator.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary:  This class responsibility is to act as Sync Coordinator to fetch data using the PlanetService and store the data to the Core Data Store. It accepts NSPersistent container as the initializer parameters and store it inside the instance variable. It also exposes a public variable for the View NSManagedObjectContext that uses the NSPersistetContainer View Context.
 */
import CoreData
protocol CoreDataSync {
     func fetchedPlanetData(_ result:[Result], completion: @escaping(Error?) -> Void)
}
class CoreDataSyncCordinator: CoreDataSync {
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func fetchedPlanetData(_ result:[Result], completion: @escaping(Error?) -> Void) {

        let taskContext = self.persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        
        _ = self.syncPlanets(result: result, taskContext: taskContext)
        
        completion(nil)
        
    }
    
    private func syncPlanets(result: [Result], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        
        taskContext.performAndWait {
            let matchingPlanetRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Planet")
            let planets = result.map { $0.name }.compactMap { $0 }
            matchingPlanetRequest.predicate = NSPredicate(format: "name in %@", argumentArray: [planets])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingPlanetRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            // Create new records.
            for item in result {
                
                guard let planet = NSEntityDescription.insertNewObject(forEntityName: "Planet", into: taskContext) as? Planet else {
                    print("Error: Failed to create a new Planet object!")
                    return
                }
                
                planet.update(with: item)
                
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
}
