//
//  ViewController.swift
//  SampleTestApp
//
//  Created by Nishant Sharma on 1/4/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary: we use NSFetchRequest to fetch the Planet entity, then tells it sort the result by name in ascending order. We initialize the NSFetchedResultController with the FetchRequest. The ViewController will also be assigned as the delegate so it can react and update the TableView when the underlying data changes.
 */
import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var failLabel: UILabel!
    @IBOutlet weak var planetTableView: UITableView!
    
    var viewModel: PlanetViewModel?
    private let planetURLStr = "https://swapi.co/api/planets/"
    private lazy var fetchedResultsController: NSFetchedResultsController<Planet> = {
        let fetchRequest = NSFetchRequest<Planet>(entityName:"Planet")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: (viewModel?.syncCordinator.viewContext)!,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.planetTableView.estimatedRowHeight = 30
        self.planetTableView.rowHeight = UITableView.automaticDimension
        if NetworkReachability.isConnectedToNetwork() == true || (self.fetchedResultsController.sections?[0].numberOfObjects ?? 0) > 0 {
            failLabel.isHidden = true
        }
        viewModel?.fetchData(planetURLStr, completionHandler: { error  in
            DispatchQueue.main.async {
                if error != nil {
                    print("Error in fetching Data")
                }
            }
        })
    }
   
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        let planet = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = planet.name
        return cell
    }
}
extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        planetTableView.reloadData()
    }
}


