//
//  EntityProtocol.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/13/23.
//

import Foundation

/// A type containing a collection of known values unique to Core Data entities.
protocol Entity: Equatable {
    var id: UUID? { get set }
    var title: String? { get set }
    var created: Date? { get set }
    var viewed: Date? { get set }
    var design: Data? { get set }
    var logo: Data? { get set }
}

extension QREntity: Entity { }
extension TemplateEntity: Entity { }
