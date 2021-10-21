//
//  ShareExtensionView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/3/21.
//

import SwiftUI

/// A view explaining to the user how to use the Share Sheet Action
struct ShareExtensionView: View {
    @State var index = 0
    var images = ["actext1", "actext2", "actext3"]
    @State private var showShare: Bool = false
    
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
                        Label("Open the Share Sheet", systemImage: "1.circle")
                        Label("Scroll to the Bottom", systemImage: "2.circle")
                        Label("Tap \"Edit Actions...\"", systemImage: "3.circle")
                        Label("Add \"Generate QR Code\"", systemImage: "4.circle")
                    }.padding(.horizontal, 20)
                        .font(.title3)
                    HStack{
                        Spacer()
                        Button(action: {
                            showShareSheet(with: [URL(string: "https://fromshawn.dev/qrpop.html")!])
                        }) {
                            Text("Open Share Sheet")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                        }.buttonStyle(.borderedProminent)
                        Spacer()
                    }
                }
            }.frame(maxWidth: 533)
            Spacer()
        }
        .navigationBarTitle(Text("Share Sheet Action"), displayMode: .large)
    }
}


struct ShareExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionView()
            
    }
}
