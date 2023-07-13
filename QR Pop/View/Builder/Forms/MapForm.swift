//
//  MapForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct MapForm: View {
    @Binding var model: BuilderModel
    
    init(model: Binding<BuilderModel>) {
        self._model = model
    }
    
    var body: some View {
        VStack(spacing: 20) {
            LocationPicker(geoLocation: $model.result)
        }
    }
}


// MARK: - Form Calculation

extension MapForm: BuilderForm {
    // Place Finder automatically debounces, so there's no need for determine result.
    // If I decide to add some manual input later on, this'll be used.
    func determineResult(for outputs: [String]) { }
}

struct MapForm_Previews: PreviewProvider {
    static var previews: some View {
        MapForm(model: .constant(BuilderModel(for: .location)))
    }
}
