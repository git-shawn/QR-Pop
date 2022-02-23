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
    
    // Safari Extension QR Code background and foreground colors as hex codes.
    @AppStorage("extBgColor") var extHexBg: String = "#FFFFFF"
    @AppStorage("extFgColor") var extHexFg: String = "#000000"
    
    // If the user has tipped or not.
    @State var hasTipped: Bool = false
    @State var extBgColor: Color = .white
    @State var extFgColor: Color = .black
    
    var body: some View {
        Form {
            Section("Safari Extension") {
                HStack {
                    Spacer()
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundColor(extFgColor)
                        .frame(width: CGFloat(codeSize), height: CGFloat(codeSize))
                        .background(extBgColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(extFgColor, lineWidth: 4)
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
                
                ColorPicker("Background Color", selection: $extBgColor)
                    .onChange(of: extBgColor, perform: {color in
                        let hex = color.toHex()
                        extHexBg = hex
                    })
                ColorPicker("Foreground Color", selection: $extFgColor)
                    .onChange(of: extFgColor, perform: {color in
                        let hex = color.toHex()
                        extHexFg = hex
                    })
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
                NavigationLink(destination: ExtensionGuideView(), label: {
                    Label("Enable App Extensions", systemImage: "puzzlepiece.extension")
                })
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
        .onAppear(perform: {
            extBgColor = Color(hex: extHexBg)
            extFgColor = Color(hex: extHexFg)
        })
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = cgColor?.components
        let r = Int(components![0]*255)
        let g = Int(components![1]*255)
        let b = Int(components![2]*255)
        let rgb:Int = (Int)(r)<<16 | (Int)(g)<<8 | (Int)(b)<<0
        return String(format: "#%06x", rgb)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
