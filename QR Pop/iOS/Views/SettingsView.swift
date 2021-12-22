//
//  SettingsView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI
import AlertToast

/// App settings and preferences
struct SettingsView: View {
    
    // Safari Extension QR Code width & height in pixels
    @AppStorage("codeSize") var codeSize: Int = 190
    
    // Safari Extension hostname visible or not
    @AppStorage("urlToggle") var urlToggle: Bool = false
    
    // Safari Extension UTM removal on or off
    @AppStorage("referralToggle") var referralToggle: Bool = false
    
    // Error Correction level from lowest (0 = 7%) to highest (3 = 30%)
    @AppStorage("errorCorrection") var errorLevel: Int = 0
    
    // If the user has tipped or not.
    @State var hasTipped: Bool = false
    
    var body: some View {
        Form {
            Section("Safari Extension") {
                HStack {
                    Spacer()
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: CGFloat(codeSize), height: CGFloat(codeSize))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.primary, lineWidth: 4)
                        )
                    Spacer()
                }.frame(height: 340)
                
                // Range from 100 to 300, incrementing by 10
                Stepper(value: $codeSize, in: 100...300, step: 10) {
                    Text("QR Code Size")
                }
                
                // Toggle showing hostname in Safari Extension
                Toggle("Show Webpage URL", isOn: $urlToggle)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                
                VStack(alignment:.leading, spacing: 5) {
                    Toggle("Remove tracking codes", isOn: $referralToggle)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    Text("Links may sometimes include UTM tracking parameters. These can make the link longer, and the QR codes QR Pop generates more complex.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, 3)
                }
            }
            Section("General") {
                VStack(alignment: .leading, spacing:5) {
                    Picker("Error Correction Level", selection: $errorLevel) {
                        Text("7%").tag(0)
                        Text("15%").tag(1)
                        Text("25%").tag(2)
                        Text("30%").tag(3)
                    }.padding(.top, 5)
                    Text("A higher error correction level will make a QR code more durable, but also more complex. Some codes may even become too complex to scan.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                if UIApplication.shared.supportsAlternateIcons {
                    NavigationLink(destination: AltIconView()) {
                        Label(title: {
                            Text("App Icon")
                                .tint(.primary)
                        }, icon: {
                            Image("altAppIcon")
                                .resizable()
                                .scaledToFit()
                                .padding(4)
                                .foregroundColor(.accentColor)
                        })
                    }
                }
                HStack {
                    Button(action: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                           return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:])
                        }
                    }) {
                        Label("Manage Permissions", systemImage: "checkmark.shield")
                    }.tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            Section("About") {
                HStack {
                    //Developer website
                    Link(destination: URL(string: "https://fromshawn.dev/")!, label: {
                        Label("Developer's Website", systemImage: "globe.americas")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                HStack {
                    Link(destination: URL(string: "mailto:contact@fromshawn.dev")!, label: {
                        Label("Contact Me", systemImage: "envelope")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                HStack {
                    //Source code
                    Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!, label: {
                        Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                // Privacy policy
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
            Section("Support QR Pop") {
                HStack {
                    Button(action: {
                        StoreManager.shared.leaveTip()
                    }, label: {
                        Label(title: {
                            Text("Buy Me a Coffee")
                                .tint(.primary)
                        }, icon: {
                            Image("coffeeTip")
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                                .foregroundColor(.accentColor)
                        })
                    })
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                HStack {
                    Button(action: {
                        StoreManager.shared.requestReview()
                    }, label: {
                        Label("Leave a Review", systemImage: "star.bubble")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }.navigationTitle("Settings")
        .onReceive(StoreManager.shared.purchasePublisher) { value in
            switch value {
            case .purchased:
                hasTipped = true
            case .restored:
                hasTipped = true
            case .failed:
                hasTipped = false
            case .deferred:
                hasTipped = false
            case .purchasing:
                hasTipped = false
            case .restoreComplete:
                hasTipped = true
            case .noneToRestore:
                hasTipped = false
            }
        }
        .toast(isPresenting: $hasTipped, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .systemImage("heart.circle", .accentColor), title: "Thank You!")
        }
    }
}

extension UIColor {
    class func color(withData data:Data) -> UIColor {
         return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIColor
    }

    func encode() -> Data {
         return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
