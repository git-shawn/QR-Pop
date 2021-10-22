//
//  GettingStartedView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

/// A view explaining to the user how to use the Safari Extension
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
                            }.sheet(
                                isPresented: self.$showSheet
                            ) {
                                SEPermissionModal(isPresented: self.$showSheet)
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
