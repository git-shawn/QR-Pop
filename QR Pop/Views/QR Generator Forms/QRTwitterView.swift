//
//  QRTwitterView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTwitterView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var toFollow: String = ""
    @State private var tweet: String = ""
    @State private var twitterInt = "Follow"
    @State private var fullURL = "https://www.twitter.com/"
    @State private var showTextModal: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Picker("Twitter URL Type", selection: $twitterInt) {
                Text("Follow").tag("Follow")
                Text("Tweet").tag("Tweet")
            }
                .pickerStyle(.segmented)
                .padding()
            
            if (twitterInt == "Follow") {
                Group {
                    TextField("Enter Account Name", text: $toFollow)
                        .textFieldStyle(QRPopTextStyle())
                    #if os(iOS)
                        .keyboardType(.default)
                        .submitLabel(.done)
                        .autocapitalization(.none)
                    #endif
                        .disableAutocorrection(true)
                        .onChange(of: toFollow) {_ in
                            combineURL()
                            qrCode.setContent(string: fullURL)
                        }
                }.animation(.spring(), value: twitterInt)
            } else {
                TextEditorModal(showTextEditor: $showTextModal, text: $tweet)
                    .onChange(of: showTextModal) {_ in
                        combineURL()
                        qrCode.setContent(string: fullURL)
                    }
                    .animation(.spring(), value: twitterInt)
            }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                toFollow = ""
                tweet = ""
                twitterInt = "Follow"
                fullURL = "https://www.twitter.com/"
            }
        })
    }
    
    private func combineURL() {
        if (twitterInt == "Follow") {
            combineFollowURL()
        } else {
            combineTweetURL()
        }
    }
    
    private func combineFollowURL() {
        toFollow = toFollow.replacingOccurrences(of: "@", with: "")
        fullURL = "https://twitter.com/intent/user?screen_name=\(toFollow)"
    }
    
    private func combineTweetURL() {
        let saniTweet = tweet.replacingOccurrences(of: " ", with: "%20")
        fullURL = "https://twitter.com/intent/tweet?text=\(saniTweet)"
    }
}

struct QRTwitterView_Previews: PreviewProvider {
    static var previews: some View {
        QRTwitterView()
    }
}
