//
//  MirrorModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/14/23.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import Combine

class MirrorModel: ObservableObject {
    static var shared = MirrorModel()
    @Published var presentedModel: QRModel?
    @Published var isMirroring: Bool = false
    @Published var showModelDetails: Bool = false
    @AppStorage("enhancedMirroringEnabled", store: .appGroup) private var enhancedMirroringEnabled: Bool = true
    
    private init() { }
    
#if os(iOS)
    var window: UIWindow? = nil
    
    // Listen for new scenes to appear
    var sceneWillConnectPublisher: AnyPublisher<UIScene, Never> {
        NotificationCenter.default
            .publisher(for: UIScene.willConnectNotification)
            .compactMap { $0.object as? UIScene }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // Listen for scenes to disappear
    var sceneDidDisconnectPublisher: AnyPublisher<UIScene, Never> {
        NotificationCenter.default
            .publisher(for: UIScene.didDisconnectNotification)
            .compactMap { $0.object as? UIScene }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /// When a scene connects, determine if it is `non-interactive`. If so, present ``PresentationView`` on it.
    func sceneWillConnect(_ scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if scene.session.role == .windowExternalDisplayNonInteractive && enhancedMirroringEnabled {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: PresentationView())
            window.rootViewController?.loadViewIfNeeded()
            window.makeKeyAndVisible()
            self.window = window
            isMirroring = true
        }
    }
    
    /// When our non-interactive scene disconnects, erase the windows.
    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.role == .windowExternalDisplayNonInteractive {
            self.window = nil
            isMirroring = false
        }
    }
#endif
}
