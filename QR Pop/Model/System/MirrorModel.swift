//
//  MirrorModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/14/23.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

class MirrorModel: ObservableObject {
    static var shared = MirrorModel()
    
    @Published var presentedModel: QRModel? = nil
    @Published var showDetails: Bool = false
    @Published private(set) var nonInteractiveExternalDisplayIsConnected: Bool = false
    @AppStorage("hideInterfaceDuringMirroring", store: .appGroup) private var hideInterfaceDuringMirroring: Bool = true
    
    private var window: UIWindow? = nil
    private var subscribers: Set<AnyCancellable> = []
    
    
    private init() {
        $presentedModel.sink { [weak self] model in
            self?.conncetMirroredScene(with: model)
        }
        .store(in: &subscribers)
    }
    
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
    
    /// When a scene connects, determine if it is `non-interactive`. If so, present ``CodePresentationView`` on it.
    func sceneWillConnect(_ scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if scene.session.role == .windowExternalDisplayNonInteractive {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            if hideInterfaceDuringMirroring {
                conncetMirroredScene(with: nil)
            }
            nonInteractiveExternalDisplayIsConnected = true
        }
    }
    
    /// When our non-interactive scene disconnects, erase the windows.
    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.role == .windowExternalDisplayNonInteractive {
            self.window = nil
            nonInteractiveExternalDisplayIsConnected = false
        }
    }
    
    func conncetMirroredScene(with model: QRModel?) {
        window?.rootViewController = UIHostingController(rootView: PresentationView(model: .constant(model)))
        window?.rootViewController?.loadViewIfNeeded()
        window?.makeKeyAndVisible()
    }
    
    /// Removes the projected view from the window. If `conncetMirroredScene` is `true` the view will not be removed, but its model will be set to `nil`.
    func disconnectMirroredScene() {
        if hideInterfaceDuringMirroring {
            presentedModel = nil
        } else {
            window?.rootViewController = nil
        }
    }
}
#endif
