//
//  CoreData.swift
//  Tracker
//
//  Created by Diana Viter on 21.04.2025.
//

import Foundation
import CoreData


final class CoreDataStack {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Models")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

let coreDataStack = CoreDataStack()
let trackerCategoryStore = try! TrackerCategoryStore(context: coreDataStack.context)
