//
//  WidgetBundle.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/21/23.
//

import SwiftUI
import WidgetKit

import WidgetKit

@main
struct Widgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        widgets()
    }
    
    func widgets() -> some Widget {
       if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
           return ArchiveWidget()
       } else {
           return OldArchiveWidget()
       }
   }
}
