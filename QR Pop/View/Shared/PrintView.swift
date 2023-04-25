//
//  PrintView.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/16/23.
//

import SwiftUI

struct PrintView: View {
    var printing: Image
    @State private var numberToPrint: Double = 1
    @State private var shouldCenter: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    
    var body: some View {
        let layout = vSizeClass == .regular ? hSizeClass == .compact ? AnyLayout(VStackLayout(alignment: .center, spacing: 0)) : AnyLayout(HStackLayout(alignment: .top, spacing: 0)) : AnyLayout(HStackLayout(alignment: .top, spacing: 0))
        
        layout {
            VStack {
                createPrintedPage(image: printing, repeating: Int(numberToPrint), center: shouldCenter)
                    .background(
                        Color.white
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
                    )
                    .frame(width: 170, height: 220)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.groupedBackground)
            Divider()
            Form {
                Section("Print Options") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Amount to Print")
                            Spacer()
                            Text("\(numberToPrint.formatted())")
                        }
                        Slider(value: $numberToPrint, in: 1...20, step: 1, label: {
                        }, minimumValueLabel: {
                            Text("1")
                        }, maximumValueLabel: {
                            Text("20")
                        })
#if os(macOS)
                        .labelsHidden()
#endif
                    }
                    Toggle("Center Printed Content?", isOn: $shouldCenter)
                }
            }
#if os(macOS)
            .formStyle(.grouped)
#endif
        }
        .navigationTitle("Page Setup")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar(id: "printbar", content: {
            ToolbarItem(id: "dismiss", placement: .cancellationAction, content: {
                Button("Cancel", action: {
                    dismiss()
                })
            })
            ToolbarItem(id: "continue", placement: .confirmationAction, content: {
                Button("Continue", action: {
                    let renderer = ImageRenderer(content: createPrintedPage(image: printing, repeating: Int(numberToPrint), center: shouldCenter).frame(width: 425, height: 550))
#if os(iOS)
                    presentPrintController(toPrint: renderer.uiImage)
#else
                    presentPrintController(toPrint: renderer.nsImage)
#endif
                })
            })
        })
    }
    
    @ViewBuilder
    private func createPrintedPage(image: Image, repeating: Int, center: Bool) -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: stepInt(repeating))
        let imageArray = [Image](repeating: image, count: repeating)
        VStack(alignment: .center) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(imageArray.indices, id: \.self) { index in
                    imageArray[index]
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: center ? .center : .topLeading)
            .padding(10)
        }
    }
    
    private func stepInt(_ val: Int) -> Int {
        switch val {
        case 1:
            return 1
        case 2...4:
            return 2
        case 4...9:
            return 3
        case 10...20:
            return 4
        default:
            return 4
        }
    }
    
#if os(iOS)
    /// Presents iOS's print control panel
    /// - Parameters:
    ///   - toPrint: A UIImage to be printed
    ///   - jobName: The name of the print job, if any
    public func presentPrintController(toPrint: UIImage?, jobName: String? = nil) {
        let printController = UIPrintInteractionController()
        let printInfo = UIPrintInfo.printInfo()
        if let jobName = jobName {
            printInfo.jobName = jobName
        }
        printController.printInfo = printInfo
        if let toPrint = toPrint {
            printController.printingItem = toPrint
        }
        printController.present(animated: true) {_,_,_ in }
    }
#else
    public func presentPrintController(toPrint: NSImage?, jobName: String? = nil) {
        if let imageToPrint = toPrint {
            // Create the printable view
            let printView = NSImageView(frame: NSRect(x: 0, y: 0, width: 425, height: 550))
            printView.image = imageToPrint
            
            // Define the print info
            let printInfo = NSPrintInfo.shared
            printInfo.topMargin = 0
            printInfo.bottomMargin = 0
            printInfo.leftMargin = 0
            printInfo.rightMargin = 0
            printInfo.scalingFactor = 1.3
            printInfo.orientation = .portrait
            
            // Setup the operation
            let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
            printOperation.jobTitle = jobName
            
            // If the user prints, close the print panel.
            if printOperation.run() {
                dismiss()
            }
        }
    }
#endif
}

struct PrintView_Previews: PreviewProvider {
    static var previews: some View {
        PrintView(printing: Image(systemName: "qrcode"))
    }
}
