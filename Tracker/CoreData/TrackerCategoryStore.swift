//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Diana Viter on 21.04.2025.
//

import UIKit
import CoreData

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    var updatedIndexes: IndexSet?
    var movedIndexes: Set<Move>?
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}

final class TrackerCategoryStore: NSObject {
    private var context: NSManagedObjectContext
    var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    let colorMarshalling = UIColorMarshalling()
    let scheduleMarshalling = ScheduleMarshalling()
    
    init(context: NSManagedObjectContext) throws {
        self.context = context

        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.header, ascending: false)
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
    
    func trackerCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { try? trackerCategory(from: $0) }
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
    
    func addTracker(_ tracker: Tracker, to categoryHeader: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", categoryHeader)

        guard let categoryObject = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "Category not found", code: 1)
        }

        let trackerObject = TrackerCoreData(context: context)
        trackerObject.id = tracker.id
        trackerObject.name = tracker.name
        trackerObject.emoji = tracker.emoji
        trackerObject.color = colorMarshalling.hexString(from: tracker.color ?? .black)
        trackerObject.schedule = scheduleMarshalling.data(from: tracker.schedule ?? [])

        trackerObject.category = categoryObject
        categoryObject.addToTracker(trackerObject)

        try context.save()
    }
    
    func category(with header: String) throws -> TrackerCategory? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", header)
        
        let results = try context.fetch(fetchRequest)
        guard let category = results.first else { return nil }
        
        return try trackerCategory(from: category)
    }
    
    private func trackerCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = coreData.header, !header.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "Empty header", code: 0)
        }

        let trackerSet = coreData.tracker as? Set<TrackerCoreData> ?? []
        let trackers = trackerSet.compactMap { try? tracker(from: $0) }

        return TrackerCategory(
            header: header,
            trackers: trackers
        )
    }
    
    func addTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        guard let header = trackerCategory.header?.trimmingCharacters(in: .whitespacesAndNewlines),
              !header.isEmpty else {
            return
        }

            let categoryObject = TrackerCategoryCoreData(context: context)
            categoryObject.header = header

        for tracker in trackerCategory.trackers {
            let trackerObject = TrackerCoreData(context: context)
            trackerObject.id = tracker.id
            trackerObject.name = tracker.name
            trackerObject.color = colorMarshalling.hexString(from: tracker.color ?? .black)
            trackerObject.emoji = tracker.emoji
            trackerObject.schedule = scheduleMarshalling.data(from: tracker.schedule ?? [])
            
            trackerObject.category = categoryObject
            categoryObject.addToTracker(trackerObject)
        }
        print("Context before save: \(context)")
        try context.save()
    }
    
    func updateCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", category.header ?? "")

        guard let categoryToUpdate = try context.fetch(fetchRequest).first else {
            print("Warning: Category with header \(category.header ?? "") not found for update")
            return
        }

        categoryToUpdate.header = category.header

        let existingTrackers = categoryToUpdate.tracker as? Set<TrackerCoreData> ?? []
        for tracker in existingTrackers {
            context.delete(tracker)
        }

        for tracker in category.trackers {
            let trackerObject = TrackerCoreData(context: context)
            trackerObject.id = tracker.id
            trackerObject.name = tracker.name
            trackerObject.color = colorMarshalling.hexString(from: tracker.color ?? .black)
            trackerObject.emoji = tracker.emoji
            trackerObject.schedule = scheduleMarshalling.data(from: tracker.schedule ?? [])
            
            trackerObject.category = categoryToUpdate
            categoryToUpdate.addToTracker(trackerObject)
        }

        try context.save()
    }

    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
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
            didUpdate: TrackerCategoryStoreUpdate(
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

