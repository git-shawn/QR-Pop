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
 
    //Returns custom activity title
    override var activityTitle: String?{
        return "Print"
    }
    
    //Returns thumbnail image for the custom activity
    override var activityImage: UIImage?{
        return UIImage(systemName: "printer")
    }
 
    //Custom activity type that is reported to completionHandler
    override var activityType: UIActivity.ActivityType{
        return UIActivity.ActivityType.printActivity
    }
 
    //View controller for the activity
    override var activityViewController: UIViewController?{
        let printView = PrintModal(activityItems: activityItems, dismissAction: {self.activityDidFinish(true)})
        let printHostingController = UIHostingController(rootView: printView)
        return printHostingController
    }
    
    //Returns a Boolean indicating whether the activity can act on the specified data items.
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if activityItems.contains(where: { obj in
            if obj is UIImage {
                return true
            } else {
                return false
            }
        }) {
        return true
        } else {
        return false
        }
    }
    
    //If no view controller, this method is called. call activityDidFinish when done.
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
    
    @State private var numberOfCopies: Int = 1
    @State private var columns: Int = 1
    @State private var scaleCodes: Bool = true
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Form {
                Text("Page Setup")
                    .font(.largeTitle)
                    .bold()
                    .listRowBackground(Color.clear)
                Section {
                    HStack {
                        Spacer()
                        PagePreview(page: PrintablePage(numberOfCopies: $numberOfCopies, activityItems: activityItems, columns: $columns), pageSize: .constant(CGSize(width: 8.5 * 72, height: 11 * 72)))
                        .frame(width: 170, height: 220)
                        .padding(15)
                        .background(Color.white)
                        .cornerRadius(3)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.secondary))
                        Spacer()
                    }.listRowBackground(Color.clear)
                }
                Section {
                    Stepper("Codes per page: \(numberOfCopies)", value: $numberOfCopies, in: 1...16)
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
                    #warning("PrintActivity.swift needs a way to set the QR code's size.")
                    //Toggle("Scale codes to fill page?", isOn: $scaleCodes)
                }
                if(!activityItems.isEmpty) {
                    Section {
                        Button(action: {
                            presentPrintInteractionController(page: PrintablePage(numberOfCopies: $numberOfCopies, activityItems: activityItems, columns: $columns), fitting: .fitToPaper)
                        }) {
                            Label("Print", systemImage: "printer")
                        }
                    }
                }
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                    .opacity(1)
                    .font(.title)
                    .accessibility(label: Text("Close"))
                    .padding()
            }
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
    
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 20, maximum: 792)), count: columns), spacing: 20) {
            ForEach((1...numberOfCopies), id: \.self) { item in
                Image(uiImage: activityItems.first! as! UIImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
            }
        }.frame(width: 612, height: 792)
    }
}
