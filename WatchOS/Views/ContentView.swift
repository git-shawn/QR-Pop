//
//  ContentView.swift
//  QR Pop Watch Watch App
//
//  Created by Shawn Davis on 3/23/23.
//

import SwiftUI
import CloudKit

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var codes: FetchedResults<QREntity>
    @State private var isCloudBlocked: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if (!codes.isEmpty && isCloudBlocked) {
                    HStack {
                        Image(systemName: "icloud.slash.fill")
                            .padding()
                        Text("Unable to connect to iCloud")
                            .font(.footnote)
                    }
                    .foregroundColor(Color.yellow)
                    .listRowBackground(Color.black)
                }
                
                ForEach(codes) { code in
                    if let model = try? QRModel(withEntity: code) {
                        NavigationLink(destination: {
                            CodeDetailView(entity: code)
                        }, label: {
                            HStack {
                                model.content.builder.icon
                                    .foregroundColor(.accentColor)
                                    .padding()
                                VStack(alignment: .leading) {
                                    Text(model.title ?? "QR Code")
                                    Text(model.created ?? Date(), style: .date)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        })
                    }
                }
                
                if codes.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: isCloudBlocked ? "icloud.slash" : "archivebox")
                            .foregroundColor(.secondary)
                            .font(.system(size: 80))
                        Text(isCloudBlocked ? "iCloud is required to sync your Archive with Apple Watch" : "You haven't saved any codes to your Archive yet")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .listRowBackground(Color.black)
                }
            }
            .task(priority: .medium) {
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
            }
            .navigationTitle("QR Pop")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
