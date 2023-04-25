//
//  LinearGradient+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

import SwiftUI

extension LinearGradient {
    
    static var macAccentStyle: LinearGradient {
        LinearGradient(colors: [.secondary, .black], startPoint: .top, endPoint: .bottom)
    }
    
    static var reverseMacAccentStyle: LinearGradient {
        LinearGradient(colors: [.secondary, .black], startPoint: .bottom, endPoint: .top)
    }
}
