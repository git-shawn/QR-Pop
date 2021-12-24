//
//  QRLinkView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRCalendarView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var eventName: String = ""
    @State private var eventLocation: String = ""
    @State private var startTime = Date()
    @State private var startString: String = ""
    @State private var endTime = Date()
    @State private var endString: String = ""
    @State private var wholeEvent: String = ""
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        startString = formatter.string(from: startTime)
        endString = formatter.string(from: endTime)
    }
    
    private func setCodeContent() {
        wholeEvent = "BEGIN:VEVENT\nSUMMARY:\(eventName)\nLOCATION:\(eventLocation)\nDTSTART:\(startString)\nDTEND:\(endString)\nEND:VEVENT"
        qrCode.setContent(string: wholeEvent)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Event Name", text: $eventName)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .submitLabel(.done)
            #endif
                .onChange(of: eventName) { value in
                    setCodeContent()
                }
            
            TextField("Event Location", text: $eventLocation)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .submitLabel(.done)
            #endif
                .onChange(of: eventLocation) { value in
                    setCodeContent()
                }
            
            DatePicker("Event Start", selection: $startTime)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .onChange(of: startTime, perform: {valeu in
                    startString = formatter.string(from: startTime)
                    setCodeContent()
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
            
            DatePicker("Event End  ", selection: $endTime)
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onChange(of: endTime, perform: {valeu in
                    endString = formatter.string(from: endTime)
                    setCodeContent()
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                eventName = ""
                eventLocation = ""
                startTime = Date()
                startString = ""
                endTime = Date()
                endString = ""
                wholeEvent = ""
            }
        })
    }
}

struct QRCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        QRCalendarView()
    }
}
