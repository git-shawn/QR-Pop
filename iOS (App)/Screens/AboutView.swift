//
//  AboutView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/9/21.
//

import SwiftUI
import AlertToast

/// Miscelaneous information about the app
struct AboutView: View {
    @State var hasPurchased: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
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
                    
                    //Contact email
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
                NavigationLink(destination: PrivacyView()) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Section {
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
            }
            Text("Made in Southern Illinois")
                .font(.footnote)
                .opacity(0.3)
        }.navigationTitle("About")
        .listStyle(.insetGrouped)
        .onReceive(StoreManager.shared.purchasePublisher) { value in
            switch value {
            case .purchased:
                hasPurchased = true
            case .restored:
                hasPurchased = true
            case .failed:
                hasPurchased = false
            case .deferred:
                hasPurchased = false
            case .purchasing:
                hasPurchased = false
            case .restoreComplete:
                hasPurchased = true
            case .noneToRestore:
                hasPurchased = false
            }
        }
        .toast(isPresenting: $hasPurchased, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .systemImage("heart.circle", .accentColor), title: "Thank You!")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
