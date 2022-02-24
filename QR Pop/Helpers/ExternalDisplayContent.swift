//
//  ExternalDisplayContent.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 2/24/22.
//

import Foundation
import SwiftUI

class ExternalDisplayContent: ObservableObject {

    @Published var codeImage: Data? = nil
    @Published var backgroundColor: Color = .white
    @Published var isShowingOnExternalDisplay = false

}
