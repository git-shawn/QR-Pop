//
//  AboutView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/9/21.
//

import SwiftUI

struct AboutView: View {
    let storeManager = StoreManager()
    @State var thankYouOpacity: Double = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Image(systemName: "heart.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .padding(3)
                Text("Thank You!")
                    .bold()
            }.zIndex(2)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)), radius: 6, x: 0, y: 3)
                )
                .opacity(thankYouOpacity)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        thankYouOpacity = 0
                    }
                })
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
                                storeManager.leaveTip()
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
                                storeManager.requestReview()
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
            }.zIndex(1)
        }.navigationTitle("About")
        .listStyle(.insetGrouped)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
