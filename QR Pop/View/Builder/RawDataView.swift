//
//  RawDataView.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/9/23.
//

import SwiftUI

struct RawDataView: View {
    let data: String
    @State private var exportableFile: SceneModel.ExportableFile? = nil
    @State private var toastable: SceneModel.Toast? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            GroupBox("\(Image(systemName: "doc")) Raw Encoded Data") {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text(data)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .monospaced()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .groupBoxStyle(RawDataGroupBoxStyle())
            .scenePadding([.horizontal, .top])
            ControlGroup {
                ImageButton("Copy Data", systemImage: "doc.on.doc", action: {
                    data.addToPasteboard()
                    toastable = .copied(note: "Raw data copied")
                })
                
                ImageButton("Save Data\(" to Files", platforms: [.iOS])", systemImage: "square.and.arrow.down", action: {
                    exportableFile = .init(
                        document: DataFileDocument(initialData: data.data(using: .utf8) ?? Data()),
                        UTType: .plainText,
                        defaultName: "Raw QR Code Data")
                })
            }
            .scenePadding()
            Spacer()
        }
        .toast($toastable)
        .fileExporter($exportableFile)
        .background(Color.groupedBackground)
        .toolbar {
            ToolbarItem(id: "dismiss", placement: .cancellationAction, content: {
                Button("Done", action: {
                    dismiss()
                })
            })
        }
    }
}

fileprivate struct RawDataGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding()
        .background(Color.secondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct RawDataView_Previews: PreviewProvider {
    static var previews: some View {
        RawDataView(data: Constants.loremIpsum)
    }
}
