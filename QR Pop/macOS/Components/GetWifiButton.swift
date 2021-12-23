//
//  GetWifiButton.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 12/22/21.
//

import SwiftUI
import CoreWLAN

struct GetWifiButton: View {
    @EnvironmentObject var qrCode: QRCode
    var isWifiActive: Bool = false
    
    init() {
        isWifiActive = self.isWIFIActive()
    }
    
    private func getWifiDetails() {
        // Get current SSID
        guard let wifiInterface = CWWiFiClient.shared().interface() else {failureAlert(); return}
        guard let ssidData: Data = wifiInterface.ssidData() else {failureAlert(); return}
        let ssidString: String = wifiInterface.ssid()!
        print(ssidString)
        
        // Determine authentication method
        let security = wifiInterface.security()
        var authMethod: String
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
            enterpriseAlert()
            return
        case .wpaEnterpriseMixed:
            enterpriseAlert()
            return
        case .wpa2Enterprise:
            enterpriseAlert()
            return
        case .enterprise:
            enterpriseAlert()
            return
        case .wpa3Personal:
            authMethod = "WPA"
        case .wpa3Enterprise:
            enterpriseAlert()
            return
        case .wpa3Transition:
            enterpriseAlert()
            return
        case .unknown:
            failureAlert()
            return
        }
        
        // Request password for SSID
        var responseData: NSString? = nil
        var wifiPassword: String = ""
        var status:OSStatus?
        
        status = CWKeychainFindWiFiPassword(CWKeychainDomain.system, ssidData, &responseData)
        if status == noErr {
            wifiPassword = responseData! as String
            print(wifiPassword)
            
            //Generate code from SSID and Password
            qrCode.setContent(string: "WIFI:T:\(authMethod);S:\(ssidString);P:\(wifiPassword);;")
        }
    }
    
    private func failureAlert() {
        let alert = NSAlert()
        alert.messageText = "Unable to Autofill"
        alert.informativeText = "QR Pop encountered an error fetching your Wifi Information."
        alert.alertStyle = .warning
        alert.runModal()
    }
    
    private func enterpriseAlert() {
        let alert = NSAlert()
        alert.messageText = "Unable to Autofill"
        alert.informativeText = "QR Pop does not currently support enterprise networks."
        alert.alertStyle = .warning
        alert.runModal()
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
            }.buttonStyle(QRPopPlainButton())
        }
    }
}

struct GetWifiButton_Previews: PreviewProvider {
    static var previews: some View {
        GetWifiButton()
    }
}
