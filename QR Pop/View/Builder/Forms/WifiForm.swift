//
//  WifiForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct WifiForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case ssid
        case password
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: ["WPA", "", ""]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
#if os(macOS)
            GetWifiButton(inputs: $engine.inputs)
                .buttonStyle(FormButtonStyle())
#endif
#if os(iOS)
            Menu {
                Picker(selection: $engine.inputs[0], label: EmptyView(), content: {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                    Text("None").tag("")
                })
                .help("Select the encryption method your Wifi network uses. The majority of homes use WPA.")
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    Text(engine.inputs[0].isEmpty ? "Unsecured Network" : engine.inputs[0])
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .tint(.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
            }
#else
            Picker(selection: $engine.inputs[0], label: EmptyView(), content: {
                Text("WPA").tag("WPA")
                Text("WEP").tag("WEP")
                Text("None").tag("nopass")
            })
            .help("Select the encryption method your Wifi network uses. The majority of homes use WPA.")
            .pickerStyle(.segmented)
#endif
            TextField("Wifi SSID", text: $engine.inputs[1])
                .autocorrectionDisabled(true)
#if os(iOS)
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                .onSubmit({
                    focusedField = .password
                })
#endif
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .ssid)
            
            if (engine.inputs[0] != "nopass") {
                SecureField("Wifi Password", text: $engine.inputs[2])
                    .autocorrectionDisabled(true)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
#endif
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .password)
            }
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

//MARK: - Form Calculations

extension WifiForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: "WIFI:T:\(outputs[0]);S:\(outputs[1]);P:\(outputs[2]);;",
            builder: .wifi)
    }
}

//MARK: - Get WiFi Button

#if os(macOS)
import CoreWLAN

fileprivate struct GetWifiButton: View {
    @Binding var inputs: [String]
    @EnvironmentObject var sceneModel: SceneModel
    
    var isWifiActive: Bool = false
    
    init(inputs: Binding<[String]>) {
        self._inputs = inputs
        isWifiActive = self.isWIFIActive()
    }
    
    private func getWifiDetails() {
        // Get current SSID
        guard let wifiInterface = CWWiFiClient.shared().interface() else {failureAlert(); return}
        guard let ssidData: Data = wifiInterface.ssidData() else {failureAlert(); return}
        guard let ssidString = wifiInterface.ssid() else {failureAlert(); return}
        
        // Determine authentication method
        let security = wifiInterface.security()
        var authMethod: String = ""
        switch security {
        case .none:
            failureAlert()
            return
        case .WEP:
            authMethod = "WEP"
        case .wpaPersonal:
            authMethod = "WPA"
        case .wpaPersonalMixed:
            authMethod = "WPA"
        case .wpa2Personal:
            authMethod = "WPA"
        case .personal:
            authMethod = "WPA"
        case .dynamicWEP:
            authMethod = "WEP"
        case .wpaEnterprise:
            unsupportedAlert()
            return
        case .wpaEnterpriseMixed:
            unsupportedAlert()
            return
        case .wpa2Enterprise:
            unsupportedAlert()
            return
        case .enterprise:
            unsupportedAlert()
            return
        case .wpa3Personal:
            authMethod = "WPA"
        case .wpa3Enterprise:
            unsupportedAlert()
            return
        case .wpa3Transition:
            unsupportedAlert()
            return
        case .unknown:
            failureAlert()
            return
        case .OWE:
            unsupportedAlert()
        case .oweTransition:
            unsupportedAlert()
        @unknown default:
            failureAlert()
            return
        }
        
        // Request password for SSID
        var responseData: NSString? = nil
        var status:OSStatus?
        
        status = CWKeychainFindWiFiPassword(CWKeychainDomain.system, ssidData, &responseData)
        if status == noErr {
            guard let wifiPassword = responseData as? String else {failureAlert(); return}
            
            //Generate code from SSID and Password
            inputs[0] = authMethod
            inputs[1] = ssidString
            inputs[2] = wifiPassword
        } else {
            failureAlert()
        }
    }
    
    private func failureAlert() {
        sceneModel.toaster = .error(note: "Could not autofill")
    }
    
    private func unsupportedAlert() {
        sceneModel.toaster = .error(note: "Network not supported")
    }

    private func isWIFIActive() -> Bool {
        guard let interfaceNames = CWWiFiClient.interfaceNames() else {
            return false
        }
        
        for interfaceName in interfaceNames {
            let interface = CWWiFiClient.shared().interface(withName: interfaceName)
            
            if interface?.ssid() != nil {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        if isWifiActive {
            Button(action: {
                Task {
                    getWifiDetails()
                }
            }, label: {
                Label("Autofill Wifi Information", systemImage: "wifi")
            })
        }
    }
}
#endif

struct WifiForm_Previews: PreviewProvider {
    static var previews: some View {
        WifiForm(model: .constant(BuilderModel(for: .wifi)))
    }
}
