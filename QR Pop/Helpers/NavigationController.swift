//
//  NavigationController.swift
//  QR Pop
//
//  Created by Shawn Davis on 1/16/22.
//

import SwiftUI

enum Routes {
    case generator
    case duplicate
    case extensions
    case settings
}

class NavigationController: ObservableObject {
    @Published var activeRoute: Routes? = Routes.generator
    @Published var activeGenerator: Int? = 1

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
