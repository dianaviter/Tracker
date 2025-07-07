//
//  TrackerStore.swift
//  Tracker
//
//  Created by Diana Viter on 21.04.2025.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    var updatedIndexes: IndexSet?
    var movedIndexes: Set<Move>?
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    private var context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    let colorMarshalling = UIColorMarshalling()
    let scheduleMarshalling = ScheduleMarshalling()
    
    init(context: NSManagedObjectContext) throws {
        self.context = context

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: false)
        ]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        
        self.fetchedResultsController.delegate = self
        try self.fetchedResultsController.performFetch()
    }
    
    func trackers() throws -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return try objects.map { try tracker(from: $0) }
    }

    private func tracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard let name = coreData.name, let emoji = coreData.emoji else {
            throw NSError()
        }

        let color = colorMarshalling.color(from: coreData.color ?? "")
        let schedule = scheduleMarshalling.schedule(from: coreData.schedule)

        return Tracker(
            id: coreData.id ?? UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: coreData.isPinned
        )
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let object = TrackerCoreData(context: context)
        object.id = tracker.id
        object.name = tracker.name
        object.emoji = tracker.emoji
        object.color = colorMarshalling.hexString(from: tracker.color ?? .black)
        object.isPinned = tracker.isPinned
        let scheduleData = scheduleMarshalling.data(from: tracker.schedule ?? [])
        object.schedule = scheduleData
        try context.save()
    }
    
    func togglePin(for tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let objects = try context.fetch(fetchRequest)
        
        guard let object = objects.first else { return }
        
        object.isPinned.toggle()
        
        try context.save()
    }
    
    func updateTracker(_ updatedTracker: Tracker, inCategoryWithHeader newCategoryHeader: String?) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", updatedTracker.id as CVarArg)

        guard let trackerToUpdate = try context.fetch(fetchRequest).first else { return }

        trackerToUpdate.name = updatedTracker.name
        trackerToUpdate.emoji = updatedTracker.emoji
        trackerToUpdate.color = colorMarshalling.hexString(from: updatedTracker.color ?? .black)
        trackerToUpdate.schedule = scheduleMarshalling.data(from: updatedTracker.schedule ?? [])
        trackerToUpdate.isPinned = updatedTracker.isPinned

        if let newCategoryHeader = newCategoryHeader, trackerToUpdate.category?.header != newCategoryHeader {
            let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "header == %@", newCategoryHeader)

            if let newCategory = try context.fetch(categoryRequest).first {
                trackerToUpdate.category = newCategory
            }
        }

        try context.save()
    }

    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let objects = try context.fetch(fetchRequest)
        
        guard let objectToDelete = objects.first else { return }
        
        context.delete(objectToDelete)
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes,
                movedIndexes: movedIndexes
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
}
