//
//  RootView.swift
//  QR Pop Watch Watch App
//
//  Created by Shawn Davis on 3/23/23.
//

import SwiftUI
import CloudKit
import QRCode
import OSLog

struct RootView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)]) var codes: FetchedResults<QREntity>
    @State private var isCloudBlocked: Bool = false
    @State private var showHelpSheet: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if codes.isEmpty {
                    if #available(watchOS 10.0, *) {
                        newEmptyArchiveView
                    } else {
                        TabView {
                            emptyArchiveView
                        }
                        .tabViewStyle(.carousel)
                    }
                } else {
                    populatedArchiveView
                    
                }
            }
            .navigationTitle("QR Pop")
            .navigationDestination(for: QREntity.self, destination: { entity in
                CodeDetailView(entity: entity)
            })
            .onOpenURL(perform: { url in
                print("Incoming URL: --- \(url.absoluteString)")
                handleURL(url)
            })
            .task(priority: .userInitiated) {
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
                } catch {
                    Logger.logView.error("ContentView: Could not determine iCloud account status.")
                }
#endif
            }
        }
    }
    
    // MARK: - Empty Codes View WatchOS 10
    @available(watchOS 10.0, *)
    var newEmptyArchiveView: some View {
        ScrollView() {
            VStack(spacing: 10) {
                Image(systemName: isCloudBlocked ? "icloud.slash" : "archivebox")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 80))
                Text(isCloudBlocked ? "Unable to Connect to iCloud" : "Your Archive\nis Empty")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: {showHelpSheet.toggle()}, label: {
                        Label("Help", systemImage: "questionmark")
                    })
                    Spacer()
                    NavigationLink(destination: CreateCodeView(), label: {
                        Image(systemName: "pencil")
                            .help("Create Code")
                    })
                }
            }
        }
        .sheet(isPresented: $showHelpSheet, content: {
            VStack(spacing: 0) {
                QRCodeViewUI(
                    content: "https://www.fromshawn.dev/qrpop/support/apple-watch",
                    errorCorrection: .low,
                    foregroundColor: CGColor.white,
                    backgroundColor: CGColor(gray: 1, alpha: 0),
                    pixelStyle: DesignModel.PixelShape.roundedPath.generator,
                    eyeStyle: DesignModel.EyeShape.squircle.generator)
                .scaledToFit()
                Text("Scan for Support")
                    .foregroundColor(.white)
                Text("fromshawn.dev/qrpop/support")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12))
                    .padding(.bottom, 10)
            }
        })
    }
    
    // MARK: - Empty Codes View
    
    var emptyArchiveView: some View {
        Group {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                Image(systemName: isCloudBlocked ? "icloud.slash" : "archivebox")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 80))
                Text(isCloudBlocked ? "Unable to Connect to iCloud" : "Your Archive is Empty")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
                
            }
            .ignoresSafeArea(edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                QRCodeViewUI(
                    content: "https://www.fromshawn.dev/support/qrpop-watch-help",
                    errorCorrection: .low,
                    foregroundColor: CGColor.white,
                    backgroundColor: CGColor.black,
                    pixelStyle: DesignModel.PixelShape.roundedPath.generator,
                    eyeStyle: DesignModel.EyeShape.squircle.generator)
                .scaledToFit()
                .padding(.vertical)
                Text("Scan for Support")
                    .foregroundColor(.white)
                Text("fromshawn.dev/support")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.bottom, 10)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Codes List
    
    var populatedArchiveView: some View {
        List {
            ForEach(codes) { code in
                if let model = try? QRModel(withEntity: code) {
                    NavigationLink(value: code) {
                        HStack(spacing: 8) {
                            let foregroundColor = model.design.backgroundColor.isDark ? Color.white : Color.black
                            
                            VStack(alignment: .leading) {
                                Text(model.title ?? "QR Code")
                                    .foregroundColor(foregroundColor)
                                    .lineLimit(2, reservesSpace: false)
                                    .multilineTextAlignment(.leading)
                                Group {
                                    Text("Created ") +
                                    Text(model.created?.formatted(.dateTime.day().month().year()) ?? "")
                                }
                                .font(.system(size: 12))
                                .foregroundColor(foregroundColor)
                                .opacity(0.5)
                            }
                            Spacer()
                        }
                        .drawingGroup()
                        .padding(.vertical, 24)
                        .padding(.horizontal, 6)
                    }
                    .listRowBackground(
                        ZStack(alignment: .trailing) {
                            Rectangle()                                .fill(model.design.backgroundColor.gradient)
                            model.content.builder.icon
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.25)
                                .rotationEffect(.degrees(-10))
                                .foregroundStyle(.quaternary)
                        }
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(2)
                    )
                }
            }
        }
        .listStyle(.carousel)
        .toolbar {
            if #available(watchOS 10.0, *) {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        NavigationLink(destination: CreateCodeView(), label: {
                            Image(systemName: "plus")
                                .help("Create Code")
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Handle URL
    
    func handleURL(_ url: URL) {
        debugPrint(url.pathComponents)
        guard url.scheme == "qrpop",
              let route = url.pathComponents[safe: 1]?.lowercased(),
              route == "archive",
              let libraryId = url.pathComponents[safe: 2],
              let libraryUUID = UUID(uuidString: libraryId),
              let entity = try? Persistence.shared.getQREntityWithUUID(libraryUUID)
        else { return }
        
        path.append(entity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
