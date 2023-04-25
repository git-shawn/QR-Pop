//
//  MapForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct MapForm: View {
    @Binding var model: BuilderModel
    
    var body: some View {
        VStack(spacing: 20) {
            PlaceFinder(geoLocation: $model.result)
        }
    }
}

struct MapForm_Previews: PreviewProvider {
    static var previews: some View {
        MapForm(model: .constant(BuilderModel(for: .location)))
    }
}
