//
//  QRLinkView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRCalendarView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var startTime = Date()
    @State private var endTime = Date()
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    private func setCodeContent() {
        let wholeEvent = "BEGIN:VEVENT\nSUMMARY:\(qrCode.formStates[0])\nLOCATION:\(qrCode.formStates[1])\nDTSTART:\(qrCode.formStates[2])\nDTEND:\(qrCode.formStates[3])\nEND:VEVENT"
        qrCode.setContent(string: wholeEvent)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Event Name", text: $qrCode.formStates[0])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .submitLabel(.done)
            #endif
            
            TextField("Event Location", text: $qrCode.formStates[1])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .submitLabel(.done)
            #endif
            
            DatePicker("Start", selection: $startTime)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .onChange(of: startTime, perform: {_ in
                    qrCode.formStates[2] = formatter.string(from: startTime)
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
            
            DatePicker("End", selection: $endTime)
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onChange(of: endTime, perform: {_ in
                    qrCode.formStates[3] = formatter.string(from: endTime)
                })
            
            Divider()
                .padding(.leading)
                .padding(.bottom)
        }.onChange(of: qrCode.formStates) {_ in
            setCodeContent()
        }
    }
}

struct QRCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        QRCalendarView()
    }
}
