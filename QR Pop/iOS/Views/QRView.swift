//
//  QRView.swift
//  QR Pop
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct QRView: View {
    
    let data = QRViews
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    @AppStorage("genViewList") var genViewList: Bool = false
    @EnvironmentObject private var navController: NavigationController
    
    var body: some View {
        if(!genViewList) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(data) { view in
                        NavigationLink(destination: QRGeneratorView(generatorType: view), tag: view.id, selection: $navController.activeGenerator) {
                            GridItemContainer(label: "\(view.name)") {
                                if (view.name == "Twitter") {
                                    Image("twitterLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(6)
                                } else {
                                    Image(systemName: "\(view.icon)")
                                        .font(.system(size: 32))
                                }
                            }.help(view.description)
                        }
                    }
                }.padding()
            }.navigationTitle("QR Generator")
            .toolbar(content: {
                ToolbarItem(content: {
                    Button(action: {
                        genViewList = true
                    }, label: {
                        Image(systemName: "list.bullet")
                    })
                })
            })
        } else {
            List {
                ForEach(data) { view in
                    NavigationLink(destination: QRGeneratorView(generatorType: view), tag: view.id, selection: $navController.activeGenerator) {
                        Label(title: {
                            Text("\(view.name)")
                        }, icon: {
                            if (view.name == "Twitter") {
                                Image("twitterLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(3)
                            } else {
                                Image(systemName: "\(view.icon)")
                            }
                        })
                    }.help(view.description)
                }
            }.navigationTitle("QR Generator")
            .toolbar(content: {
                ToolbarItem(content: {
                    Button(action: {
                        genViewList = false
                    }, label: {
                        Image(systemName: "square.grid.2x2")
                    })
                })
            })
        }
    }
}

private struct GridItemContainer <Content: View> : View {
    let label: String
    var content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .center) {
                content
            }.frame(width: 50, height: 50)
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(
                .ultraThickMaterial
            )
            .cornerRadius(16)
            Text("\(label)")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
}

struct QRView_Previews: PreviewProvider {
    static var previews: some View {
        QRView()
    }
}
