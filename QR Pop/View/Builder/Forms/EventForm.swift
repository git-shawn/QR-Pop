//
//  EventForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI
import OSLog

struct EventForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            let rightNow = Date().ISO8601Format(.iso8601(timeZone: .gmt, includingFractionalSeconds: false, dateSeparator: .omitted, dateTimeSeparator: .standard, timeSeparator: .omitted))
            
            self._engine = .init(wrappedValue: .init(initial: ["","",rightNow,rightNow]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name
        case location
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Event Name", text: $engine.inputs[0])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .name)
#if os(iOS)
                .keyboardType(.default)
                .submitLabel(.next)
#endif
                .onSubmit {
                    focusedField = .location
                }
            
            TextField("Event Location", text: $engine.inputs[1])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .location)
#if os(iOS)
                .keyboardType(.default)
                .submitLabel(.next)
#endif

            StringDatePicker("Start", date: $engine.inputs[2])
                .padding()
#if os(macOS)
                .buttonStyle(DatePickerButtonStyle())
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                )
#else
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
#endif
            
            StringDatePicker("End", date: $engine.inputs[3])
                .padding()
#if os(macOS)
                .buttonStyle(DatePickerButtonStyle())
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                )
#else
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
#endif
        }
        .onReceive(engine.$outputs) {
            if model.responses != $0 {
                determineResult(for: $0)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard, content: {
                Spacer()
                Button("Done", action: {focusedField = nil})
            })
        }
    }
}

// MARK: - Form Calculation

extension EventForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        let result = "BEGIN:VEVENT\nSUMMARY:\(outputs[0])\nLOCATION:\(outputs[1])\nDTSTART:\(outputs[2])\nDTEND:\(outputs[3])\nEND:VEVENT"
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .event)
    }
}

struct EventForm_Previews: PreviewProvider {
    static var previews: some View {
        EventForm(model: .constant(BuilderModel(for: .event)))
    }
}
