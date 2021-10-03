//
//  ShareExtensionView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/3/21.
//

import SwiftUI

struct ShareExtensionView: View {
    var body: some View {
        ScrollView {
            HStack() {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                Label {
                    Text("Share a link")
                } icon: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.purple)
                }
                Label {
                    Text("Scroll to the bottom of the Share Sheet")
                } icon: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.red)
                }
                Label {
                    Text("Tap \"Edit Actions...\"")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
                Label {
                    Text("Add \"Generate QR Code\"")
                } icon: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.green)
                }
                }.padding(.horizontal, 20)
            }
                Spacer()
            }
        }
        .navigationBarTitle(Text("Share Sheet Action"), displayMode: .large)
    }
}

struct ShareExtensionView_Previews: PreviewProvider {
    static var previews: some View {
        ShareExtensionView()
    }
}
