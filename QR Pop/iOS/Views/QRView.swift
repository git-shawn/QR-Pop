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
    
    var body: some View {
        if(!genViewList) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(data) { view in
                        NavigationLink(destination: {
                            ScrollView {
                                HStack {
                                    Spacer()
                                    view.destination
                                        .frame(maxWidth: 400)
                                    Spacer()
                                }
                            }
                        }) {
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
                            }
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
                    NavigationLink(destination: {
                        ScrollView {
                            HStack {
                                Spacer()
                                view.destination
                                    .frame(maxWidth: 400)
                                Spacer()
                            }
                        }
                    }) {
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
                    }
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
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.gray)
                    .opacity(0.1)
                    .aspectRatio(1, contentMode: .fit)
            )
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
