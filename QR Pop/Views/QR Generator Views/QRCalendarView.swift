//
//  QRLinkView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRCalendarView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for link
    @State private var eventName: String = ""
    @State private var startTime = Date()
    @State private var startString: String = ""
    @State private var endTime = Date()
    @State private var endString: String = ""
    @State private var wholeEvent: String = ""
    let formatter = DateFormatter()
    
    init() {
        _qrData = State(initialValue: qrCode.generate(content: "BEGIN:VEVENT\nSUMMARY:\nDTSTART:\nDTEND:\nEND:VEVENT", fg: .black, bg: .white, encoding: .utf8))
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        startString = formatter.string(from: startTime)
        endString = formatter.string(from: endTime)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            TextField("Event Name", text: $eventName)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .submitLabel(.done)
            #endif
                .onChange(of: eventName) { value in
                    constructWholeEvent()
                    qrData = QRCode().generate(content: wholeEvent, fg: fgColor, bg: bgColor, encoding: .utf8)
                }
            
            DatePicker("Event Start", selection: $startTime)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .onChange(of: startTime, perform: {valeu in
                    startString = formatter.string(from: startTime)
                    constructWholeEvent()
                    qrData = QRCode().generate(content: wholeEvent, fg: fgColor, bg: bgColor, encoding: .utf8)
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
            
            DatePicker("Event End  ", selection: $endTime)
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onChange(of: endTime, perform: {valeu in
                    endString = formatter.string(from: endTime)
                    constructWholeEvent()
                    qrData = QRCode().generate(content: wholeEvent, fg: fgColor, bg: bgColor, encoding: .utf8)
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                constructWholeEvent()
                qrData = QRCode().generate(content: wholeEvent, fg: fgColor, bg: bgColor, encoding: .utf8)
            }
            #endif
        }.navigationTitle("Event Generator")
        .toolbar(content: {
            HStack{
                #if os(macOS)
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Image(systemName: "paintpalette")
                }
                .popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) { value in
                        constructWholeEvent()
                        qrData = QRCode().generate(content: wholeEvent, fg: fgColor, bg: bgColor, encoding: .utf8)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    eventName = ""
                    startTime = Date()
                    endTime = Date()
                    startString = formatter.string(from: startTime)
                    endString = formatter.string(from: endTime)
                    fgColor = .black
                    bgColor = .white
                    qrData = QRCode().generate(content: "BEGIN:VEVENT\nSUMMARY:\nDTSTART:\nDTEND:\nEND:VEVENT", fg: .black, bg: .white, encoding: .utf8)
                }){
                    Image(systemName: "trash")
                }
                #if os(macOS)
                SaveButton(qrCode: qrData)
                #endif
                ShareButton(shareContent: [qrData.image], buttonTitle: "Share")
            }
        })
    }
    
    func constructWholeEvent() {
        wholeEvent = "BEGIN:VEVENT\nSUMMARY:\(eventName)\nDTSTART:\(startString)\nDTEND:\(endString)\nEND:VEVENT"
    }
}

struct QRCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        QRCalendarView()
    }
}
