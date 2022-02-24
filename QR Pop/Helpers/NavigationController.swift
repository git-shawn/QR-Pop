//
//  NavigationController.swift
//  QR Pop
//
//  Created by Shawn Davis on 1/16/22.
//

import SwiftUI

enum Routes: Hashable {
    case generator
    case extensions
    case settings
    case saved
    case duplicate
}

class NavigationController: ObservableObject {
    @Published var activeRoute: Routes? = Routes.generator
    #if os(iOS)
    @Published var activeGenerator: Int? = nil
    #else
    @Published var activeGenerator: Int? = 1
    #endif

    func open(route: Routes) {
        activeRoute = route
        if (route != .generator) {
            activeGenerator = nil
        }
    }
    
    func open(generator: Int) {
        activeGenerator = generator
        activeRoute = Routes.generator
    }
}
