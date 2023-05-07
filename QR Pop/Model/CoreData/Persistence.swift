//
//  Persistence.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

//
//  Persistence.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/11/23.
//

import CoreData
import CloudKit
import SwiftUI
import OSLog
#if os(iOS) || os(macOS)
import CoreSpotlight
import WidgetKit
#endif

class Persistence: ObservableObject {
    static let shared = Persistence()
    
#if canImport(CoreSpotlight)
    private(set) var spotlightIndexer: SpotlightDelegate?
#endif
    
    /// A Boolean that is true if iCloud is available on this device.
    var cloudAvailable: Bool = {
        FileManager.default.ubiquityIdentityToken != nil
    }()
    
    lazy var container: NSPersistentCloudKitContainer = {
        setupContainer()
    }()
    
    /// Prepares the `NSPersistentCloudKitContainer` depending on a variety of parameters.
    /// - If `useCloudSync` is enabled in `UserDefaults.appGroup` the container will be created with `CloudKitContainerOptions`
    /// - If `inMemory` is `true` the container will be initialized with no permanent store and no access to CloudKit.
    private func setupContainer() -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Database")
        var description: NSPersistentStoreDescription
        
#if !targetEnvironment(simulator)
        let storeURL = URL.storeURL(for: Constants.groupIdentifier, databaseName: "Database")
        description = NSPersistentStoreDescription(url: storeURL)
#else
        description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
#endif
        
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier:"iCloud.shwndvs.QR-Pop")
        
        container.persistentStoreDescriptions = [description]
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if error != nil {
                Logger.logPersistence.error("The container could not be loaded.")
            }
        })
        
#if canImport(CoreSpotlight)
        let coordinator = container.persistentStoreCoordinator
        self.spotlightIndexer = SpotlightDelegate(
            forStoreWith: description,
            coordinator: coordinator)
        self.toggleSpotlightIndexing(enabled: true)
#endif
        
#if canImport(AppIntent)
        QRPopShortcuts.updateAppShortcutParameters()
#endif
        
        return container
    }
}

// MARK: - Simulate Data

extension Persistence {
    
#if targetEnvironment(simulator)
    func loadPersistenceWithSimualtedData() {
        let viewContext = self.container.viewContext
        
        for i in 0..<5_000 {
            Logger.logModel.debug("Persistence Simulated Data: Simulating model `\(i)` of `5_000`")
            var design = DesignModel()
            design.backgroundColor = Color.random
            
            // Create a generic QREntity
            let qrEntity = QREntity(context: viewContext)
            qrEntity.id = UUID()
            qrEntity.created = Date()
            qrEntity.title = "QR Code \(i)"
            qrEntity.design = try? design.asData()
            qrEntity.builder = try? BuilderModel().asData()
            
            // Create a generic TemplateEntity
            let templateEntity = TemplateEntity(context: viewContext)
            templateEntity.id = UUID()
            templateEntity.title = "Template \(i)"
            templateEntity.created = Date()
            templateEntity.logo = nil
            templateEntity.design = try? design.asData()
        }
        do {
            try viewContext.atomicSave()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
#endif
}

// MARK: - Save Functions

extension NSManagedObjectContext {
    
    /// Attempts to commit unsaved changes to registered objects to the context’s parent store
    /// then informs interested parties that the context was changed.
    ///
    /// Unlike `save()`, this function guarantees that there are uncommitted changes before running.
    /// The following additional functions are called after save:
    /// - Shortcuts are updated.
    /// - Widgets are reloaded.
    /// If the save fails, these additional functions are not called and an error is thrown.
    func atomicSave() throws {
        Task { @MainActor [weak self] in
            if self?.hasChanges ?? false {
                try self?.save()
#if canImport(AppIntent)
                QRPopShortcuts.updateAppShortcutParameters()
#endif
#if os(iOS) || os(macOS)
                WidgetCenter.shared.reloadAllTimelines()
#endif
            }
        }
    }
}

// MARK: - Delete Functions
#if !CLOUDEXT
extension Persistence {
    
    /// Delete all entities, essentially wiping the database.
    func deleteAllEntities() throws {
        let entities = container.managedObjectModel.entities
        for entity in entities {
            try deleteEntity(entity.name!)
        }
    }
    
    /// Delete all instances of an entity in the container
    /// - Parameter entityName: The entity's name, as a String, to be deleted
    func deleteEntity(_ entityName: String) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try container.viewContext.execute(deleteRequest)
    }
    
    /// Delete an array of entities of a known `UUID` and ``EntityType``.
    /// - Warning: All entities must be of the same type.
    /// - Parameters:
    ///   - entities: The entities to delete, as ``Entity``.
    ///   - type: The type of entity to delete.
    func deleteEntities(_ entities: [any Entity], of type: EntityType) throws {
        for entity in entities {
            try deleteEntity(entity, of: type)
        }
    }
    
    /// Delete an entity of a known 'UUID' and ``EntityType``.
    /// - Parameters:
    ///   - entity: The entity to delete, as ``Entity``.
    ///   - type: The type of entity to delete.
    func deleteEntity(_ entity: any Entity, of type: EntityType) throws {
        switch type {
        case .archive:
            let fetchedEntity = try getQREntityWithUUID(entity.id)
            container.viewContext.delete(fetchedEntity)
            try container.viewContext.atomicSave()
        case .template:
            let fetchedEntity = try getTemplateEntityWithUUID(entity.id)
            container.viewContext.delete(fetchedEntity)
            try container.viewContext.atomicSave()
        }
    }
    
    /// The type of entity associated with the otherwise type-erased ``Entity``.
    enum EntityType: String {
        /// Represents `TemplateEntity`.
        case template = "TemplateEntity"
        /// Represents `QREntity`.
        case archive = "QREntity"
    }
    
}
#endif

// MARK: - Fetch Functions

extension Persistence {
    
    /// Fetch a single `QREntity` with the URI representation of its Managed Object ID.
    /// - Parameter uri: The URI representation of an NSManagedObjectID.
    /// - Returns: A `QREntity`, if one is found, else `nil`.
    func getQREntityWithURI(_ uri: URL) -> QREntity? {
        guard let objectID = container.viewContext
            .persistentStoreCoordinator?
            .managedObjectID(forURIRepresentation: uri)
        else {
            return nil
        }
        return container.viewContext.object(with: objectID) as? QREntity
    }
    
    /// Fetch a single `TemplateEntity` with the URI representation of its Managed Object ID.
    /// - Parameter uri: The URI representation of an NSManagedObjectID.
    /// - Returns: A `TemplateEntity`, if one is found, else `nil`.
    func getTemplateEntityWithURI(_ uri: URL) -> TemplateEntity? {
        guard let objectID = container.viewContext
            .persistentStoreCoordinator?
            .managedObjectID(forURIRepresentation: uri)
        else {
            return nil
        }
        return container.viewContext.object(with: objectID) as? TemplateEntity
    }
    
    /// Fetch a single `QREntity` with its associated `UUID`.
    /// - Parameter id: A `UUID`.
    /// - Returns: A `QREntity` matching the `id`.
    func getQREntityWithUUID(_ identifier: UUID?) throws -> QREntity {
        guard let identifier = identifier else {
            Logger.logPersistence.notice("A QREntity was requested using an invalid UUID.")
            throw PersistenceError.invalidUUID
        }
        
        let request = QREntity.fetchRequest() as NSFetchRequest<QREntity>
        request.predicate = NSPredicate(format: "%K == %@", "id", identifier as CVarArg)
        let items = try container.viewContext.fetch(request)
        
        guard let item = items.first else {
            Logger.logPersistence.notice("No QREntity was found with UUID provided to getQREntityWithUUID().")
            throw PersistenceError.noEntityFound
        }
        return item
    }
    
    /// Fetch a single `TemplateEntity` with its associated `UUID`.
    /// - Parameter id: A `UUID`.
    /// - Returns: A `TemplateEntity` matching the `id`.
    func getTemplateEntityWithUUID(_ identifier: UUID?) throws -> TemplateEntity {
        guard let identifier = identifier else {
            Logger.logPersistence.notice("A TemplateEntity was requested using an invalid UUID.")
            throw PersistenceError.invalidUUID
        }
        
        let request = TemplateEntity.fetchRequest() as NSFetchRequest<TemplateEntity>
        request.predicate = NSPredicate(format: "%K == %@", "id", identifier as CVarArg)
        let items = try container.viewContext.fetch(request)
        
        guard let item = items.first else {
            Logger.logPersistence.notice("No TemplateEntity was found with UUID provided to getTemplateEntityWithUUID().")
            throw PersistenceError.noEntityFound
        }
        return item
    }
    
    /// Fetch all `QREntity` objects matching an array of `UUID`s.
    /// - Parameter identifiers: An array of `UUID`s.
    /// - Returns: An array of `QREntity`s.
    /// - Warning: Invalid UUIDs are silently skipped. If no entities are found, an empty array is returned.
    func getQREntitiesWithUUIDs(_ identifiers: [UUID]) -> [QREntity] {
        var resultArray: [QREntity] = []
        identifiers.forEach { id in
            if let entity = try? getQREntityWithUUID(id) {
                resultArray.append(entity)
            }
        }
        return resultArray
    }
    
    /// Fetch all `TemplateEntity` objects matching an array of `UUID`s.
    /// - Parameter identifiers: An array of `UUID`s.
    /// - Returns: An array of `TemplateEntity`s.
    /// - Warning: Invalid UUIDs are silently skipped. If no entities are found, an empty array is returned.
    func getTemplateEntitiesWithUUIDs(_ identifiers: [UUID]) -> [TemplateEntity] {
        var resultArray: [TemplateEntity] = []
        identifiers.forEach { id in
            if let entity = try? getTemplateEntityWithUUID(id) {
                resultArray.append(entity)
            }
        }
        return resultArray
    }
    
    /// Fetch all `QREntity` objects matching a title `String`.
    /// - Parameter title: The entity's title as a `String`.
    /// - Returns: All matching `QREntity` as an array.
    func getQREntitiesWithTitle(_ title: String) throws -> [QREntity] {
        let request = QREntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        let results = try container.viewContext.fetch(request)
        return results
    }
    
    /// Fetch all `TemplateEntity` objects matching a title `String`.
    /// - Parameter title: The entity's title as a `String`.
    /// - Returns: All matching `TemplateEntity` as an array.
    func getTemplateEntitiesWithTitle(_ title: String) throws -> [TemplateEntity] {
        let request = TemplateEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        let results = try container.viewContext.fetch(request)
        return results
    }
    
    /// Fetch the `k` most recent `QREntity` objects stored in the database.
    ///   - k: The number of entities to fetch. Default is `1`.
    ///   - recency: An enum representing whether to fetch entities by their `created` date.
    /// - Returns: All matching `QREntity`s.
    func getMostRecentQREntities(_ k: Int = 1) throws -> [QREntity] {
        let request = QREntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        request.fetchLimit = k
        let items = try container.viewContext.fetch(request)
        return items
    }
    
    /// Fetch the `k` most recent `TemplateEntity` objects stored in the database.
    /// - Parameters:
    ///   - k: The number of entities to fetch. Default is `1`.
    ///   - recency: An enum representing whether to fetch entities by their `created` date.
    /// - Returns: All matching `TemplateEntity`s.
    func getMostRecentTemplateEntities(_ k: Int = 1) throws -> [TemplateEntity] {
        let request = TemplateEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        request.fetchLimit = k
        let items = try container.viewContext.fetch(request)
        return items
    }
    
    /// Fetch **all** `QREntity`s stored in the database.
    /// - Returns: An array containing all `QREntity`s.
    func getAllQREntities() throws -> [QREntity] {
        let request = QREntity.fetchRequest()
        let items = try container.viewContext.fetch(request)
        return items
    }
    
    /// Fetch **all** `TemplateEntity`s stored in the database.
    /// - Returns: An array containing all `TemplateEntity`s.
    func getAllTemplateEntities() throws -> [TemplateEntity] {
        let request = TemplateEntity.fetchRequest()
        let items = try container.viewContext.fetch(request)
        return items
    }
    
    /// Fetch **all** entities stored in the database.
    /// - Returns: A tuple containing all entities stored in the database.
    func getAllEntities() throws -> (qrEntities: [QREntity], templateEntities: [TemplateEntity]) {
        var results: (qrEntities: [QREntity], templateEntities: [TemplateEntity]) = ([],[])
        let qrRequest = QREntity.fetchRequest()
        results.qrEntities = try container.viewContext.fetch(qrRequest)
        let templateRequest = TemplateEntity.fetchRequest()
        results.templateEntities = try container.viewContext.fetch(templateRequest)
        return results
    }
}

// MARK: - Shared Database URL

public extension URL {
    
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            Logger(subsystem: Constants.bundleIdentifier, category: "persistence+url")
                .critical("The shared file container could not be created.")
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

#if canImport(CoreSpotlight)
// MARK: - Spotlight Delegate

class SpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    override func domainIdentifier() -> String {
        return "shwndvs.qr-pop.archiveContent"
    }
    
    override func indexName() -> String? {
        return "qrcode-index"
    }
    
    override func attributeSet(for object: NSManagedObject)
    -> CSSearchableItemAttributeSet? {
        guard let qrEntity = object as? QREntity else {
            return nil
        }
        
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        let model = try? QRModel(withEntity: qrEntity)
        
        attributeSet.contentDescription = "\(model?.content.builder.title ?? "Generic") QR Code"
        attributeSet.kind = model?.content.builder.title
        attributeSet.displayName = model?.title ?? "Archived QR Code"
        attributeSet.userCreated = 1
        attributeSet.thumbnailData = try? model?.jpegData(for: 180)
        return attributeSet
    }
}

// MARK: - Toggle Spotlight Indexing

extension Persistence {
    
    func toggleSpotlightIndexing(enabled: Bool) {
        guard let spotlightIndexer = spotlightIndexer else { return }
        
        if enabled {
            spotlightIndexer.startSpotlightIndexing()
        } else {
            spotlightIndexer.stopSpotlightIndexing()
        }
    }
}
#endif

// MARK: - Conform to Equatable

extension FetchedResults: Equatable {
    
    /// This is an incredibly lazy extension that doesn't *actually* check if two fetch requests are equal. Instead, it merely checks if they are the same length.
    /// This is intended for usage animating custom lists of FetchResults, specifically the removal and addition of new list items.
    /// - Parameters:
    ///   - lhs: A `FetchResult` to compare
    ///   - rhs: A `FetchResult` to compare
    /// - Returns: `true` if both sides are the same length, `false` otherwise
    public static func == (lhs: FetchedResults, rhs: FetchedResults) -> Bool {
        lhs.count == rhs.count
    }
}

// MARK: - Error Handling

extension Persistence {
    
    enum PersistenceError: Error, LocalizedError {
        case invalidUUID
        case noEntityFound
        
        var errorDescription: String? {
            switch self {
            case .invalidUUID:
                return "Invalid Entity ID"
            case .noEntityFound:
                return "No Entity Found"
            }
        }
    }
}
