//
//  StringDatePicker.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/3/23.
//

import SwiftUI

struct StringDatePicker: View {
    @Binding var date: String
    @State private var dateProxy: Date
    let title: String
    
#if os(macOS)
    @State private var modifyingDate: Bool = false
    @State private var modifyingTime: Bool = false
#endif
    
    init(_ titleKey: String, date: Binding<String>) {
        self.title = titleKey
        self._date = date
        self._dateProxy = .init(wrappedValue: (try? Date(date.wrappedValue, strategy: .iso8601)) ?? Date())
    }
    

    var body: some View {
        Group {
#if os(iOS)
            DatePicker(title, selection: $dateProxy)
#else
            HStack {
                Text(title)
                Spacer()
                Button(action: {
                    modifyingDate = true
                }, label: {
                    Text(dateProxy.formatted(date: .abbreviated, time: .omitted))
                })
                .popover(isPresented: $modifyingDate) {
                    DatePicker(title, selection: $dateProxy, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .background(Color.antiPrimary.scaleEffect(1.5))
                }
                
                Button(action: {
                    modifyingTime = true
                }, label: {
                    Text(dateProxy.formatted(date: .omitted, time: .shortened))
                })
                .popover(isPresented: $modifyingTime) {
                    DatePicker(title, selection: $dateProxy, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.stepperField)
                        .labelsHidden()
                        .padding()
                        .background(Color.antiPrimary.scaleEffect(1.5))
                }
            }
#endif
        }
        .onChange(of: dateProxy) { proxy in
            self.date = proxy.ISO8601Format(.iso8601(timeZone: .gmt, includingFractionalSeconds: false, dateSeparator: .omitted, dateTimeSeparator: .standard, timeSeparator: .omitted))
        }
    }
}

struct StringDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        StringDatePicker("Start", date: .constant(""))
    }
}
