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
                            shareSheet()
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
    
    func shareSheet() {
        guard let data = URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435") else { return }
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            av.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            av.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            av.popoverPresentationController?.permittedArrowDirections = []
        } else {
            av.modalPresentationStyle = .pageSheet
        }
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}


struct ShareExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionView()
            
    }
}
