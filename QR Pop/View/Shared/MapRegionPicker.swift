//
//  MapRegionPicker.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/27/23.
//
#if os(iOS)
import SwiftUI
import MapKit

struct MapRegionPicker: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            Map {
                
            }
        } else {
            EmptyView()
        }
    }
}

struct MapRegionPicker_Previews: PreviewProvider {
    static var previews: some View {
        MapRegionPicker()
    }
}
#endif
