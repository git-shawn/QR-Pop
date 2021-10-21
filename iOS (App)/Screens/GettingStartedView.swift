//
//  GettingStartedView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct GettingStartedView: View {
    @State private var showSheet: Bool = false
    @State var index = 0
    var images = ["safext1", "safext2", "safext3", "safext4", "safext5"]
    
    var body: some View {
        ScrollView {
            HStack() {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    HStack{
                        Spacer()
                        InlinePhotoView(index: $index, images: images)
                            .frame(maxHeight: 400)
                        Spacer()
                    }.padding(10)
                    Group {
                        Group {
                            Label("Open the Settings App", systemImage: "1.circle")
                            Label("Tap Safari", systemImage: "2.circle")
                            Label("Tap Extensions", systemImage: "3.circle")
                            Label("Tap QR Pop", systemImage: "4.circle")
                            Label("Turn QR Pop On", systemImage: "5.circle")
                        }.font(.title3)
                        HStack() {
                            Label("Allow \"All Websites\"", systemImage: "6.circle")
                                .font(.title3)
                            Spacer()
                            Button(action: {
                                self.showSheet = true
                            }) {
                                Text("Why?")
                                    .foregroundColor(.blue)
                            }.sheet(
                                isPresented: self.$showSheet
                            ) { ScrollView{
                                    VStack(alignment: .leading, spacing: 20) {
                                        Text("Why should I allow all websites?")
                                                .font(.largeTitle)
                                                .bold()
                                        Text("QR Pop works by extracting the URL from a webpage and converting it into a QR code. Allowing \"All Websites\" makes this process convenient and automatic.\n\nGiving an extension the ability to see every URL you visit can be risky business, so Safari checks to make sure you're serious before sharing that information.\n\nYou can be confident knowing no funny business is going on. QR Pop's privacy policy explicitly states that all codes are created on-device and that this app contains no loggers, trackers, etc.\n\nHowever, for those more technical, you don't need to take my word for it. Feel free to browse the source code and see for yourself.")
                                    }.padding(.horizontal, 20)
                                            .padding(.top, 20)
                                }
                            }
                        }
                    }.padding(.horizontal, 20)
                }
            }.frame(maxWidth: 533)
            Spacer()
        }
        .navigationBarTitle(Text("Safari Extension"), displayMode: .large)
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
            
    }
}
