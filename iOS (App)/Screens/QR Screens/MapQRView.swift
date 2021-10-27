//
//  LinkQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI
import UniformTypeIdentifiers

/// A QR code builder view to make codes for locations
struct MapQRView: View {
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
    
    //QR View standard variables
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
    @State private var content: Data?
    
    //Unique variables for locations
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var mapClient: QRCode.mapType = .AppleMaps
    @State private var directions: Bool = false
    @FocusState private var keyboard
    
    init() {
        _content = State(initialValue: QRCode().generate(content: "", bg: .white, fg: .black))
    }
    
    /// Generate a QR code for a location
    var body: some View {
        ScrollView {
            VStack() {
                
                QRImageView(content: $content, bg: $bgColor)
                    .animation(.easeInOut, value: mapClient)
                
                //Accept inputs to generate QR code
                HStack {
                    Picker("Open in", selection: $mapClient) {
                        Text("Apple Maps").tag(QRCode.mapType.AppleMaps)
                        Text("Google Maps").tag(QRCode.mapType.GoogleMaps)
                        Text("Waze").tag(QRCode.mapType.Waze)
                    }
                        .padding()
                        .onChange(of: mapClient) { value in
                            content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                        }
                    if (mapClient == .AppleMaps) {
                        Picker("Open as Directions?", selection: $directions) {
                            Text("Navigate").tag(true)
                            Text("Show Location").tag(false)
                        }
                            .padding()
                            .onChange(of: directions) { value in
                                content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                            }
                    }
                }.animation(.easeInOut, value: mapClient)
                .animation(.easeInOut, value: directions)
                
                TextField("Enter Full Street Address", text: $address)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                    .submitLabel(.done)
                    .focused($keyboard)
                    .textContentType(.streetAddressLine1)
                    .onChange(of: address) { value in
                        content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                    }
                Divider()
                    .padding(.leading)
                TextField("Enter City", text: $city)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                    .submitLabel(.done)
                    .focused($keyboard)
                    .textContentType(.addressCity)
                    .onChange(of: city) { value in
                        content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                    }
                Divider()
                    .padding(.leading)
                HStack {
                    TextField("Enter State", text: $state)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                        .submitLabel(.done)
                        .focused($keyboard)
                        .textContentType(.addressState)
                        .onChange(of: state) { value in
                            content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                        }
                    TextField("Enter ZipCode", text: $zipCode)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .padding(.top, 10)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .focused($keyboard)
                        .toolbar {
                            ToolbarItem(placement: .keyboard, content: {
                                HStack{
                                    Spacer()
                                    Button("Done") {
                                        keyboard = false
                                    }
                                }
                            })
                        }
                }
                Divider()
                    .padding(.leading)
                    .padding(.bottom)
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                .onChange(of: [bgColor, fgColor]) { value in
                    content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                }
                
            }.padding(.top)
        }.navigationBarTitle(Text("Location QR Code"), displayMode: .large)
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    fgColor = .black
                    bgColor = .white
                    address = ""
                    city = ""
                    state = ""
                    mapClient = .AppleMaps
                    directions = false
                    content = qrCode.generateLocation(address: address, city: city, state: state, map: mapClient, directions: directions, bg: bgColor, fg: fgColor)
                }){
                    Image(systemName: "trash")
                }
                Button(
                action: {
                    showShareSheet(with: [UIImage(data: content!)!])
                }){
                    Image(systemName: "square.and.arrow.up")
                }
            }
        })
    }
}

struct MapQRView_Previews: PreviewProvider {
    static var previews: some View {
        MapQRView()
    }
}
