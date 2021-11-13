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
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for location
    @State private var addressQuery: String = ""
    @State private var noLocationFound: Bool = false
    @State private var foundLocation: String = "none"
    @State private var lat: String = "38.6247"
    @State private var long: String = "-90.1848"
    
    init() {
        qrData = qrCode.generate(content: "geo:38.6247,-90.1848", fg: .black, bg: .white)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
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
                        qrData = qrCode.generate(content: "geo:\(lat),\(long)", fg: fgColor, bg: bgColor)
                    }
                }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                qrData = qrCode.generate(content: "geo:\(lat),\(long)", fg: fgColor, bg: bgColor)
            }
            #endif
        }.navigationTitle("Location Generator")
        .toast(isPresenting: $noLocationFound, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .systemImage("binoculars", .accentColor), title: "No Locations Found")
        }
        .toolbar(content: {
            HStack{
                #if os(macOS)
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Image(systemName: "paintpalette")
                }
                .popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) { value in
                        qrData = qrCode.generate(content: "geo:\(lat),\(long)", fg: fgColor, bg: bgColor)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    DispatchQueue.main.async {
                        withAnimation(.spring()) {
                            addressQuery = ""
                            foundLocation = "none"
                            lat = "38.6247"
                            long = "-90.1848"
                            fgColor = .black
                            bgColor = .white
                            qrData = qrCode.generate(content: "geo:\(lat),\(long)", fg: fgColor, bg: bgColor)
                        }
                    }
                }){
                    Image(systemName: "trash")
                }
                #if os(macOS)
                SaveButton(qrCode: qrData)
                #endif
                ShareButton(shareContent: [qrData.image], buttonTitle: "Share")
            }
        })
    }
}

struct QRLocationView_Previews: PreviewProvider {
    static var previews: some View {
        QRLocationView()
    }
}
