//
//  MenuBarScanResultsView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/22/23.
//

#if os(macOS)
import SwiftUI
import OSLog

struct MenuBarScanResultsView: View {
    var results: [String]
    @Environment(\.openURL) var openURL
    @StateObject var sceneModel = SceneModel()
    
    //MARK: Results Found
    var resultsForm: some View {
        Form {
            ForEach(results, id: \.self) { result in
                Section(content: {
                    Button(action: {
                        guard let encodedResult =
                                result.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        else { return }
                        openURL(URL(string: "qrpop:///buildtext/?\(encodedResult)")!)
                    }, label: {
                        Label("Edit in QR Pop", image: "qrpop.icon")
                    })
                    .buttonStyle(OutboundLinkButtonStyle())
                    
                    Button(action: {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.setString(result, forType: .string)
                        sceneModel.toaster = .copied(note: "Data copied")
                    }, label: {
                        Label("Add Data to Pasteboard", systemImage: "list.clipboard")
                    })
                    .buttonStyle(OutboundLinkButtonStyle())
                    
                    if result.isURL {
                        Button(action: {
                            openURL(URL(string: result)!)
                        }, label: {
                            Label("Open in Safari", systemImage: "safari")
                        })
                        .buttonStyle(OutboundLinkButtonStyle())
                    }
                    
                    if let wifiBundle = try? WifiHandler.parseWifiInfo(result) {
                        Button(action: {
                            do {
                                try wifiBundle.connect()
                                sceneModel.toaster = .custom(
                                    image: Image(systemName: "wifi"),
                                    imageColor: .secondary,
                                    title: "Connected",
                                    note: "Network joined")
                            } catch {
                                Logger.logView.error("MenuBarScanResultsView: Could not connect to wireless network.")
                                sceneModel.toaster = .custom(
                                    image: Image(systemName: "wifi.slash"),
                                    imageColor: .secondary,
                                    title: "Network Error",
                                    note: "Could not join network")
                            }
                        }, label: {
                            Label("Connect to Wireless Network", systemImage: "wifi")
                        })
                        .buttonStyle(OutboundLinkButtonStyle())
                    }
                }, header: {
                    Text(result)
                        .lineLimit(3)
                        .fontWeight(.regular)
                })
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Scan Results")
        .presentedWindowToolbarStyle(.unifiedCompact(showsTitle: true))
        .toolbar {
            Spacer()
        }
    }
    
    //MARK: Empty Results
    var emptyCodes: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "questionmark.square.dashed")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 52))
                Text("No QR codes were found")
                    .multilineTextAlignment(.center)
                HStack { Spacer() }
            }
            .padding()
            .background(
                Color.secondaryGroupedBackground
                    .cornerRadius(10)
            )
            Text("If you are using QR Pop's full-screen capture tool, call it from the display that contains the QR code. Otherwise, try enlarging any QR codes.")
                .foregroundColor(.secondary)
                .font(.footnote)
            Spacer()
        }
        .padding()
        .presentedWindowStyle(.hiddenTitleBar)
    }
    
    //MARK: Navigation Stack
    var body: some View {
        NavigationStack {
            if !results.isEmpty {
                resultsForm
                    .frame(minWidth: 300)
                    .toast($sceneModel.toaster)
            } else {
                emptyCodes
                    .frame(minWidth: 300)
            }
        }
    }
}

#if targetEnvironment(simulator)
struct MenuBarScanResultsView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarScanResultsView(results: ["Test1", "Test2", "https://www.theverge.com", "WIFI:T:WPA;S:202 Ida;P:Sunshin3;;", Constants.loremIpsum])
        MenuBarScanResultsView(results: [])
    }
}
#endif

#endif
