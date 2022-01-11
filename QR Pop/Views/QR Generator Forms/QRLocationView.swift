//
//  QRLocationView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI
import CoreLocation
import Contacts
import AlertToast

struct QRLocationView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var noLocationFound: Bool = false
    @State private var foundLocation: String = "none"
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            if (foundLocation != "none") {
                Text(foundLocation)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding()
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            TextField("Enter an Address", text: $qrCode.formStates[0])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .textContentType(.fullStreetAddress)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onSubmit {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(qrCode.formStates[0]) { (placemarks, error) in
                        guard
                            let placemarks = placemarks,
                            let locationFound = placemarks.first?.location
                        else {
                            noLocationFound = true
                            foundLocation = "none"
                            return
                        }
                        DispatchQueue.main.async {
                            withAnimation(.spring()) {
                                qrCode.formStates[0] = ""
                                foundLocation = "\(CNPostalAddressFormatter().string(from: (placemarks.first?.postalAddress)!))"
                            }
                        }
                        let lat = locationFound.coordinate.latitude.description
                        let long = locationFound.coordinate.longitude.description
                        qrCode.setContent(string: "geo:\(lat),\(long)")
                    }
                }
        }
        .toast(isPresenting: $noLocationFound, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .systemImage("binoculars", .accentColor), title: "No Locations Found")
        }
    }
}

struct QRLocationView_Previews: PreviewProvider {
    static var previews: some View {
        QRLocationView()
    }
}
