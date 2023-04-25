//
//  WifiForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct WifiForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case ssid
        case password
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
#if os(macOS)
            GetWifiButton(builderModel: $model)
                .buttonStyle(FormButtonStyle())
#endif
#if os(iOS)
            Menu {
                Picker(selection: $model.responses[0], label: EmptyView(), content: {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                    Text("None").tag("nopass")
                })
                .help("Select the encryption method your Wifi network uses. The majority of homes use WPA.")
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    Text(model.responses[0] == "nopass" ? "Unsecured Network" : model.responses[0])
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
            Picker(selection: $model.responses[0], label: EmptyView(), content: {
                Text("WPA").tag("WPA")
                Text("WEP").tag("WEP")
                Text("None").tag("nopass")
            })
            .help("Select the encryption method your Wifi network uses. The majority of homes use WPA.")
            .pickerStyle(.segmented)
#endif
            TextField("Wifi SSID", text: $model.responses[1])
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
            
            if (model.responses[0] != "nopass") {
                SecureField("Wifi Password", text: $model.responses[2])
                    .autocorrectionDisabled(true)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
#endif
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .password)
            }
        }
        .onChange(of: model.responses, debounce: 1) { _ in
            determineResult()
        }
        .onAppear {
            model.responses[0] = "WPA"
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard, content: {
                Spacer()
                Button("Done", action: {focusedField = nil})
            })
        }
    }
}

//MARK: - Form Calculation

extension WifiForm {
    
    func determineResult() {
        if model.responses[0].isEmpty {
            model.responses[0] = "WPA"
        }
        model.result = "WIFI:T:\(model.responses[0]);S:\(model.responses[1]);P:\(model.responses[2]);;"
    }
}

//MARK: - Get WiFi Button

#if os(macOS)
import CoreWLAN

fileprivate struct GetWifiButton: View {
    @Binding var model: BuilderModel
    @EnvironmentObject var sceneModel: SceneModel
    
    var isWifiActive: Bool = false
    
    init(builderModel: Binding<BuilderModel>) {
        self._model = builderModel
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
            model.responses[0] = authMethod
            model.responses[1] = ssidString
            model.responses[2] = wifiPassword
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
            Button(action: getWifiDetails) {
                Label("Autofill Wifi Information", systemImage: "wifi")
            }
        }
    }
}
#endif

struct WifiForm_Previews: PreviewProvider {
    static var previews: some View {
        WifiForm(model: .constant(BuilderModel(for: .wifi)))
    }
}
