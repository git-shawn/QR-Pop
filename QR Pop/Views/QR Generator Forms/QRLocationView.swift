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

    @State private var addressQuery: String = ""
    @State private var noLocationFound: Bool = false
    @State private var foundLocation: String = "none"
    @State private var lat: String = "38.6247"
    @State private var long: String = "-90.1848"
    
    var body: some View {
        VStack(alignment: .center) {
            if (foundLocation != "none") {
                Text(foundLocation)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding()
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            TextField("Enter an Address", text: $addressQuery)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .textContentType(.fullStreetAddress)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onSubmit {
                    let geoCoder = CLGeocoder()
                    geoCoder.geocodeAddressString(addressQuery) { (placemarks, error) in
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
                                addressQuery = ""
                                foundLocation = "\(CNPostalAddressFormatter().string(from: (placemarks.first?.postalAddress)!))"
                            }
                        }
                        lat = locationFound.coordinate.latitude.description
                        long = locationFound.coordinate.longitude.description
                        qrCode.setContent(string: "geo:\(lat),\(long)")
                    }
                }
        }
        .toast(isPresenting: $noLocationFound, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .systemImage("binoculars", .accentColor), title: "No Locations Found")
        }
        .onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                addressQuery = ""
                noLocationFound = false
                foundLocation = "none"
            }
        })
    }
}

struct QRLocationView_Previews: PreviewProvider {
    static var previews: some View {
        QRLocationView()
    }
}
