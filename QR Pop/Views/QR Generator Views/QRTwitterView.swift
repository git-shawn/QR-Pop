//
//  QRTwitterView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTwitterView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for twitter links
    @State private var toFollow: String = ""
    @State private var tweet: String = ""
    @State private var twitterInt = "Follow"
    @State private var fullURL = "https://www.twitter.com/"
    @State private var showTextModal: Bool = false
    
    init() {
        qrData = qrCode.generate(content: "https://www.twitter.com/", fg: .black, bg: .white, encoding: .utf8)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
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
                            qrData = QRCode().generate(content: fullURL, fg: fgColor, bg: bgColor, encoding: .utf8)
                        }
                }.animation(.spring(), value: twitterInt)
            } else {
                TextEditorModal(showTextEditor: $showTextModal, text: $tweet)
                    .onChange(of: showTextModal) {_ in
                        combineURL()
                        qrData = QRCode().generate(content: fullURL, fg: fgColor, bg: bgColor, encoding: .utf8)
                    }
                    .animation(.spring(), value: twitterInt)
            }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) {_ in
                qrData = qrCode.generate(content: fullURL, fg: fgColor, bg: bgColor, encoding: .utf8)
            }
            #endif
            Text("Twitter, and the Twitter logo, is a trademark of Twitter Inc. QR Pop, and it's developer, is not affiliated with Twitter in any way. Just a big fan.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .opacity(0.3)
                .padding()
        }.navigationTitle("Twitter Generator")
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
                    .onChange(of: [bgColor, fgColor]) {_ in
                        qrData = qrCode.generate(content: fullURL, fg: fgColor, bg: bgColor, encoding: .utf8)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    toFollow = ""
                    tweet = ""
                    twitterInt = "Follow"
                    fullURL = "https://www.twitter.com/"
                    fgColor = .black
                    bgColor = .white
                    qrData = QRCode().generate(content: "https://www.twitter.com/", fg: .black, bg: .white)
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
