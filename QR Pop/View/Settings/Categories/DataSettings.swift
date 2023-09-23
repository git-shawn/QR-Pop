//
//  DataSettings.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/13/23.
//

import SwiftUI
import OSLog

struct DataSettings: View {
    @AppStorage("syncToCloud") var syncToCloud: Bool = true
    @EnvironmentObject var sceneModel: SceneModel

    @State private var erasingData: Bool = false
    var body: some View {
        Section("Data") {
            // Delete data
            Button(action: {
                erasingData.toggle()
            }, label: {
                Label(title: {
                    Text("Erase data")
                        .foregroundColor(.primary)
                }, icon: {
                    Image(systemName: "trash")
                })
            })
            .confirmationDialog(
                "Erase Data",
                isPresented: $erasingData,
                actions: {
                    Button("Erase Archived Codes", role: .destructive) {
                        do {
                            try Persistence.shared.deleteEntity("QREntity")
                            sceneModel.toaster = .custom(image: Image(systemName: "trash"), imageColor: .accentColor, title: "Erased", note: "Archive erased")
                        } catch {
                            Logger.logView.error("Settings: Could not delete all `QREntities` from the database.")
                            sceneModel.toaster = .error(note: "Archive not erased")
                        }
                    }
                    
                    Button("Erase Templates", role: .destructive) {
                        do {
                            try Persistence.shared.deleteEntity("TemplateEntity")
                            sceneModel.toaster = .custom(image: Image(systemName: "trash"), imageColor: .accentColor, title: "Erased", note: "Templates erased")
                        } catch {
                            Logger.logView.error("Settings: Could not delete all `TemplateEntities` from the database.")
                            sceneModel.toaster = .error(note: "Templates not erased")
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {}
                })
            
            // Toggle iCloud
            LabeledContent(content: {
                if Persistence.shared.cloudAvailable {
                    Text("Enabled")
                } else {
                    Text("Unavailable")
                }
            }, label: {
                Label("iCloud Sync", systemImage: "icloud")
            })
        }
    }
}

struct DataSettings_Previews: PreviewProvider {
    static var previews: some View {
        DataSettings()
    }
}
