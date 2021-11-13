//
//  HelpBook.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/12/21.
//

import SwiftUI

struct HelpBook: View {
    @State private var showTOC: Bool = false
    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image("launchScreenImg")
                        VStack(alignment: .leading, spacing: 3) {
                            Text("QR Pop User Guide")
                                .font(.title2)
                                .bold()
                            Button(action: {
                                showTOC = true
                            }) {
                                Label("Table of Contents", systemImage: "list.bullet.rectangle.portrait")
                            }.buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    Divider()
                    Group {
                        Group {
                            Text("Making QR Codes in the App")
                                .font(.title3)
                                .bold()
                                .id(1)
                            Text("QR Pop can currently generate the following types of QR codes in the app:")
                            ForEach(QRViews) { view in
                                Label(view.name, systemImage: view.icon)
                            }.padding(.leading)
                            Text("Each generator works largely the same. You are asked to enter some text, and QR Pop converts that text into an appropriate QR code. The link generator, for example, asks you to type (or paste) a URL into the text field. The code is generated as you type, and you can actually watch the preview change as more letters are entered.\n\nThe largest exception to this rule is the Contacts and Location generators.\n\nFor Contacts, you will be asked to select a Contact from your address book. QR Pop then extracts all data from the Contact Card, excluding the notes, and transforms it into a QR code.\n\nFor Locations, you will be asked to enter a street address into the text field. When you hit return on your keyboard, QR Pop will search for the coordinates of that location and present the formatted address of what it found. Those coordinates will then be transformed into a QR code.\n\nTo start over, press the \(Image(systemName: "trash")) icon in the toolbar.")
                        }
                        Group {
                            Divider()
                            Text("Styling QR Codes in the App")
                                .font(.title3)
                                .bold()
                                .id(2)
                            Text("QR Pop lets you change the foreground and background colors of your code. To do that, press the \(Image(systemName: "paintpalette")) icon in the toolbar.\n\nThe foreground and background must have 20% contrast. Anything less and some scanners may struggle to read it. You'll recieve a warning if your contrast ratio falls to low.")
                        }
                        Group {
                            Divider()
                            Text("Exporting QR Codes from the App")
                                .font(.title3)
                                .bold()
                                .id(3)
                            Text("Exporting the QR Code you made is easy. To share it, just press the \(Image(systemName: "square.and.arrow.up")) button in the toolbar or right click on the code and select \"Share Image.\"\n\nSaving works the same way. Either press the \(Image(systemName: "square.and.arrow.down")) button in the toolbar or right click on the code and select \"Save Image.\"\n\nTo copy your code, just right click like you would anywhere else and select \"Copy Image.\"\n\nTo print your code, right click it and select \"Print Image.\"\n\nQR Pop also supports drag-and-drop. Just click and hold your code, then drag it into your favorite app. Drag-and-drop may not be supported by every app.")
                        }
                        Group {
                            Divider()
                            Text("Can I Request a New Generator?")
                                .font(.title3)
                                .bold()
                                .id(4)
                            Text("Of course! Just shoot me an email at [contact@fromshawn.dev](mailto:contact@fromshawn.dev) describing what you're looking for. Just keep in mind the following things:\n - QR Codes cannot exceed 3KB.\n - QR Pop makes all codes on your device. Without using a server, that means codes can't be dynamic.\n\nIf there are other limitations, I'll let you know, but otherwise those are the big two. I appreciate all feedback and would love to hear your idea!")
                        }
                    }
                    Group {
                        Group {
                            Divider()
                            Text("How to Save a QR Code Made in the Safari Extension")
                                .font(.title3)
                                .bold()
                                .id(5)
                            Text("QR Codes in the Safari Extension work exactly like any other images on the web. To save it, just right click! You can also click-and-drag the image to your desktop. Keep in mind, though, that these codes are not as high-resolution as those you could make in the app.")
                        }
                    }
                    Group {
                        Group {
                            Divider()
                            Text("How to Save a QR Code Made in the Share Extension")
                                .font(.title3)
                                .bold()
                                .id(6)
                            Text("Saving a QR Code made in the Share Extension is easy, and works just like the main app. Just press the \(Image(systemName: "square.and.arrow.down")) button!")
                        }
                        Group {
                            Divider()
                            Text("What Apps Support the Share Extension?")
                                .font(.title3)
                                .bold()
                                .id(7)
                            Text("The Share Extension will appear in any app that uses Apple's default *share picker* system and shares a link. This includes popular apps like Twitter, Safari, and even the App Store. However, some apps, like Music, do not use the standard *share picker*, so QR Pop won't appear there. If you suspect an app may support QR Pop's Share Extension, you can access it by either pressing \(Image(systemName: "square.and.arrow.down")) or by pressing Share in the right-click menu.")
                        }
                        Group {
                            Divider()
                            Text("How do I Use QR Pop to Share Files with iCloud?")
                                .font(.title3)
                                .bold()
                                .id(8)
                            Text("If you use iCloud Drive, QR Pop is supported as one of the many ways you can share files. In Finder, simply right click on the file you would like to share, navigate to \"Share\" and select \"\(Image(systemName: "person.crop.circle.badge.plus")) Share File.\"\n\nYou'll see QR Pop listed alongside other services like Mail and AirDrop.\nThis system uses the *Share Extension*.")
                        }
                    }
                }.padding()
                .sheet(isPresented: $showTOC) {
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 10) {
                            Group {
                                Button("Making QR Codes in the App", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(1)
                                        }
                                    }
                                })
                                Button("Styling QR Codes in the App", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(2)
                                        }
                                    }
                                })
                                Button("Exporting QR Codes from the App", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(3)
                                        }
                                    }
                                })
                                Button("Can I Request a New Generator?", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(4)
                                        }
                                    }
                                })
                                Button("How to Save a QR Code Made in the Safari Extension", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(5)
                                        }
                                    }
                                })
                                Button("How to Save a QR Code Made in the Share Extension", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(6)
                                        }
                                    }
                                })
                                Button("What Apps Support the Share Extension?", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(7)
                                        }
                                    }
                                })
                                Button("How do I Use QR Pop to Share Files with iCloud?", action: {
                                    DispatchQueue.main.async {
                                        showTOC = false
                                        withAnimation(.easeIn) {
                                            value.scrollTo(8)
                                        }
                                    }
                                })
                            }.buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            Spacer()
                            Group {
                                Text("Don't see your question?")
                                Link("Contact Me", destination: URL(string:"mailto:contact@fromshawn.dev")!)
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(.regularMaterial)
                                    .clipShape(Capsule())
                                    .padding(.bottom, 20)
                            }
                        }.padding(.top, 50)
                        .padding(.horizontal, 20)
                        HStack {
                            Spacer()
                            Button(action: {
                                showTOC.toggle()
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                                .opacity(1)
                                .font(.title)
                                .accessibility(label: Text("Close"))
                            })
                            .keyboardShortcut(.cancelAction)
                            .buttonStyle(.plain)
                            .padding()
                        }.overlay(Text("Table of Contents").font(.headline))
                    }.frame(width: 300, height: 400)
                }
            }
        }
        .frame(width: 450, height: 500)
        .navigationTitle("QR Pop Help")
        .toolbar {
            Button(action: {
                showTOC = true
            }) {
                Label("Table of Contents", systemImage: "list.bullet.rectangle.portrait")
            }.buttonStyle(.plain)
            .foregroundColor(.accentColor)
        }
    }
}

struct HelpBook_Previews: PreviewProvider {
    static var previews: some View {
        HelpBook()
    }
}
