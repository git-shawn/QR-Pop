//
//  ShareExtensionView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/3/21.
//

import SwiftUI

struct ShareExtensionView: View {
    @State var index = 0
    var images = ["actext1", "actext2", "actext3"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack{
                    Spacer()
                    InlinePhotoView(index: $index, images: images)
                    Spacer()
                }.padding(10)
                Group {
                    Label("Open the Share Sheet", systemImage: "1.circle")
                    Label("Scroll to the Bottom", systemImage: "2.circle")
                    Label("Tap \"Edit Actions...\"", systemImage: "3.circle")
                    Label("Add \"Generate QR Code\"", systemImage: "4.circle")
                }.padding(.horizontal, 20)
                HStack{
                    Spacer()
                    Button(action: {
                        actionSheet()
                        
                    }) {
                        Text("Open Share Sheet")
                            .padding(.horizontal, 20)
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text("Share Sheet Action"), displayMode: .large)
    }
    
    func actionSheet() {
           guard let urlShare = URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435") else { return }
           let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
           UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}


struct ShareExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionView()
            
    }
}
