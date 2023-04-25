//
//  EventForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct EventForm: View {
    @Binding var model: BuilderModel
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    let formatter = DateFormatter()
    
    init(model: Binding<BuilderModel>) {
        self.formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        self.formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self._model = model
    }
    
    /// TextField focus information
    private enum Field: Hashable {
        case name
        case location
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Event Name", text: $model.responses[0])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .name)
#if os(iOS)
                .keyboardType(.default)
                .submitLabel(.next)
#endif
                .onSubmit {
                    focusedField = .location
                }
            
            TextField("Event Location", text: $model.responses[1])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .location)
#if os(iOS)
                .keyboardType(.default)
                .submitLabel(.next)
#endif
            
            DatePicker("Start", selection: $startTime)
                .padding()
#if os(macOS)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                )
#else
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
#endif
                .onChange(of: startTime) { _ in
                    model.responses[2] = formatter.string(from: startTime)
                }
            
            DatePicker("End", selection: $endTime)
                .padding()
#if os(macOS)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.regularMaterial)
                )
#else
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
#endif
                .onChange(of: endTime) { _ in
                    model.responses[3] = formatter.string(from: endTime)
                }
        }
        .onChange(of: model.responses, debounce: 1) {_ in
            determineResult()
        }
        .onAppear {
            model.responses[2] = formatter.string(from: startTime)
            model.responses[3] = formatter.string(from: endTime)
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

extension EventForm {
    
    func determineResult() {
        if model.responses.allSatisfy({ $0 == "" }) {
            startTime = Date()
            endTime = Date()
            model.responses[2] = formatter.string(from: startTime)
            model.responses[3] = formatter.string(from: endTime)
        } else {
            model.result = "BEGIN:VEVENT\nSUMMARY:\(model.responses[0])\nLOCATION:\(model.responses[1])\nDTSTART:\(model.responses[2])\nDTEND:\(model.responses[3])\nEND:VEVENT"
        }
    }
}

struct EventForm_Previews: PreviewProvider {
    static var previews: some View {
        EventForm(model: .constant(BuilderModel(for: .event)))
    }
}
