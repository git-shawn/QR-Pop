//
//  LocationActivityModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/12/23.
//

#if os(iOS)
import CoreLocation
import UserNotifications
import ActivityKit

struct RegionedActivity: Equatable, Identifiable, Codable {
    var id: UUID
    var region: CLLocationCoordinate2D
    var active: Bool
    
    static func == (lhs: RegionedActivity, rhs: RegionedActivity) -> Bool {
        lhs.id == rhs.id
    }
}

/**
 Strategy here:
 - Register a maximum of five regions that trigger UNUserNotifications when entered and exited
 - Use the notifications to start and stop an associated live activity with ActivityKit
 - Relevent data, the id and region, are stored within UserDefaults as an array of ``RegionedActivity``
 */

class LocationManager: NSObject {
    /// An array of region-based activity triggers.
    private(set) var regionedActivities: [RegionedActivity]
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        // Load any previously created regionedActivities.
        if let regionedActivitiesData = UserDefaults.appGroup.value(forKey: "regionedActivities") as? Data,
           let potentialArrayValues = try? JSONDecoder().decode(Array<RegionedActivity>.self, from: regionedActivitiesData) {
            self.regionedActivities = potentialArrayValues
        } else {
            self.regionedActivities = []
        }
        
        super.init()
    }
}

// Conform CLLocationCoordinate2D to Hashable for storage in UserDefaults
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

#endif
