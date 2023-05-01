//
//  ContentView.swift
//  QR Pop Watch Watch App
//
//  Created by Shawn Davis on 3/23/23.
//

import SwiftUI
import CloudKit
import QRCode

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var codes: FetchedResults<QREntity>
    @State private var isCloudBlocked: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if codes.isEmpty {
                    TabView {
                        emptyArchiveView
                    }
                    .tabViewStyle(.carousel)
                } else {
                    List {
                        createCodeList(codes)
                    }
                }
            }
            .navigationTitle("QR Pop")
            .task(priority: .medium) {
#if targetEnvironment(simulator)
                isCloudBlocked = false
#else
                do {
                    let status = try await CKContainer.default().accountStatus()
                    if status == .available {
                        isCloudBlocked = false
                    } else {
                        isCloudBlocked = true
                    }
                } catch let error {
                    debugPrint(error)
                }
#endif
            }
        }
    }
    
    // MARK: - Empty Codes View
    
    var emptyArchiveView: some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: isCloudBlocked ? "icloud.slash" : "archivebox")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 80))
                Text(isCloudBlocked ? "iCloud is required to sync your Archive with Apple Watch" : "Your Archive is Empty")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 10) {
                QRCodeViewUI(
                    content: "https://www.fromshawn.dev/support/qrpop-watch-help",
                    pixelStyle: DesignModel.PixelShape.roundedPath.generator,
                    eyeStyle: DesignModel.EyeShape.squircle.generator)
                .scaledToFit()
                .padding(.top)
                Text("Scan for Support")
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .ignoresSafeArea()
            )
        }
    }
    
    // MARK: - Codes List
    
    @ViewBuilder
    func createCodeList(_ codes: FetchedResults<QREntity>) -> some View {
        ForEach(codes) { code in
            if let model = try? QRModel(withEntity: code) {
                NavigationLink(destination: {
                    CodeDetailView(entity: code)
                }, label: {
                    HStack {
                        model.content.builder.icon
                            .foregroundColor(.primary)
                            .bold()
                            .padding()
                        VStack(alignment: .leading) {
                            Text(model.title ?? "QR Code")
                                .lineLimit(1)
                            Text(model.created ?? Date(), style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(model.design.backgroundColor)
                                .opacity(0.8)
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .foregroundColor(model.design.backgroundColor)
                            .opacity(0.8)
                    }
                    .padding(.vertical)
                })
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(model.design.backgroundColor)
                        .opacity(0.35)
                        .padding(2)
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
