//
//  WifiHandler.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/4/23.
//

import Foundation
#if os(macOS)
import CoreWLAN
#endif

class WifiHandler {
    
    /// Determines if a `String` represents a wireless network and, if it does, returns that information extracted as a `WifiBundle`
    /// - Parameter string: The `String` to inspect for WiFi information.
    /// - Returns: A `WifiBundle` if information is found.
    ///
    /// WIFI:T:WPA;S:202 Ida;P:Sunshin3;;
    static func parseWifiInfo(_ string: String) throws -> WifiBundle {
        let contentString = string.removingPrefix("WIFI:")
        let components = contentString.components(separatedBy: ";")
        
        let isWEP = components[0].contains("WEP")
        // QR Pop only supports WEP or WPA networks.
        guard isWEP || components[0].contains("WPA") else { throw WifiHandlerError.invalidData }
        
        let ssid = components[1].removingPrefix("S:")
        let passphrase = components[2].removingPrefix("P:")
        
        return WifiBundle(ssid: ssid,
                          passphrase: passphrase,
                          isWEP: isWEP)
    }
    
    /// A cross-platform collection of WiFi information as well as a method to connect.
    struct WifiBundle {
        let ssid: String
        let passphrase: String
        let isWEP: Bool
        
        func connect() throws {
#if os(macOS)
            guard let interface = CWWiFiClient.shared().interface() else { throw WifiHandlerError.connectionFailure }
            let networks = try interface.scanForNetworks(withName: ssid)
            guard let network = networks.first else { throw WifiHandlerError.connectionFailure }
            return try interface.associate(to: network, password: passphrase)
#else
            // If this feature is ever brought to iOS, use NEHotspotConfiguration(ssid: String, passphrase: String, isWEP: Bool).
#endif
        }
    }
    
    enum WifiHandlerError: Error, LocalizedError {
        case invalidData
        case connectionFailure
        
        var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid or unsupported wireless network data."
            case .connectionFailure:
                return "Unable to connect to wireless network."
            }
        }
    }
}
