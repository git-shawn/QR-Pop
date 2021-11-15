//
//  PrintActivity.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 11/13/21.
//

import Foundation
import SwiftUI
import UIKit

class PrintActivity: UIActivity {
    var activityItems: [Any] = []
 
    override var activityTitle: String?{
        return "Print"
    }
    
    override var activityImage: UIImage?{
        return UIImage(systemName: "printer")
    }
 
    override var activityType: UIActivity.ActivityType{
        return UIActivity.ActivityType.printActivity
    }
 
    override var activityViewController: UIViewController?{
        let printView = PrintModal(activityItems: activityItems, dismissAction: {self.activityDidFinish(true)})
        let printHostingController = UIHostingController(rootView: printView)
        return printHostingController
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if activityItems.contains(where: { obj in
            if obj is UIImage {
                // If the device can't print, we shouldn't show the button.
                if UIPrintInteractionController.isPrintingAvailable {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }) {
        return true
        } else {
        return false
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
 }

extension UIActivity.ActivityType {
    static let printActivity = UIActivity.ActivityType("shwndvs.QR-Pop.printActivity")
}

private struct PrintModal: View {
    @Environment(\.presentationMode) var presentationMode
    var activityItems: [Any]
    var dismissAction: (() -> Void)
    
    let maximumCopies: Int
    @State private var numberOfCopies: Int = 1
    @State private var columns: Int = 1
    @AppStorage("printScaleCodes") private var scaleCodes: Bool = true
    @AppStorage("printCenterImage") private var centerImage: Bool = true
    
    init(activityItems: [Any], dismissAction: @escaping (() -> Void)) {
        self.activityItems = activityItems
        self.dismissAction = dismissAction
        
        // Codes exceeding 2000KB are highly complex and should be printed larger.
        if (activityItems.first! as! UIImage).imageSizeInKB > 2000 {
            maximumCopies = 4
        } else {
            maximumCopies = 16
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PagePreview(page: PrintablePage(numberOfCopies: $numberOfCopies, activityItems: activityItems, columns: $columns, scaleCodes: $scaleCodes, centerImage: $centerImage), pageSize: .constant(CGSize(width: 8.5 * 72, height: 11 * 72)))
                        .frame(width: 170, height: 220)
                        .background(Color.white)
                        .cornerRadius(3)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.secondary))
                        Spacer()
                    }.listRowBackground(Color.clear)
                }.padding(.top)
                Section {
                    Stepper("Codes per page: \(numberOfCopies)", value: $numberOfCopies, in: 1...maximumCopies)
                        .onChange(of: numberOfCopies, perform: {num in
                            if num == 1 {
                                columns = 1
                            } else if (num > 1 && num <= 4) {
                                columns = 2
                            } else if (num > 4 && num <= 9) {
                                columns = 3
                            } else if (num > 9) {
                                columns = 4
                            }
                        })
                    Toggle("Scale codes to fill page", isOn: $scaleCodes)
                        .tint(.accentColor)
                    Toggle("Center codes on page", isOn: $centerImage)
                        .tint(.accentColor)
                }
                if(!activityItems.isEmpty) {
                    Section {
                        Button(action: {
                            presentPrintInteractionController(pages: [PrintablePage(numberOfCopies: $numberOfCopies, activityItems: activityItems, columns: $columns, scaleCodes: $scaleCodes, centerImage: $centerImage)], jobName: "QR Pop", fitting: .fitToPrintableRect)
                        }) {
                            Label("Print", systemImage: "printer")
                        }
                    }
                }
            }
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
                Spacer()
            }.overlay(
                Text("Page Setup").font(.headline)
            )
            .padding()
        }.onDisappear(perform: {
            presentationMode.wrappedValue.dismiss()
            dismissAction()
        })
    }
}

private struct PrintablePage: View {
    @Binding var numberOfCopies: Int
    var activityItems: [Any]
    @Binding var columns: Int
    @Binding var scaleCodes: Bool
    @Binding var centerImage: Bool
    
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 20, maximum: 792)), count: (scaleCodes ? columns : ((activityItems.first! as! UIImage).imageSizeInKB > 2000) ? 2 : 4)), spacing: 20) {
            ForEach((1...numberOfCopies), id: \.self) { item in
                Image(uiImage: activityItems.first! as! UIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
            }
        }.frame(width: 540, height: 720, alignment: (centerImage ? .center : .topLeading))
    }
}
