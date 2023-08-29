//
//  RootView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import OSLog
import StoreKit
import CoreSpotlight

struct RootView: View {
    @StateObject var navigationModel = NavigationModel()
    @StateObject var sceneModel = SceneModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
#if os(iOS)
    @State private var showShakeSheet: Bool = false
    init(){
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
    }
#endif
    
    var body: some View {
        ZStack {
            if horizontalSizeClass == .compact || UIDevice.current.userInterfaceIdiom == .phone {
                TabNavigation()
            } else {
                SidebarNavigation()
            }
        }
        .fileExporter($sceneModel.exporter)
        .toast($sceneModel.toaster)
        
        // MARK: - Add Models to the Environment
        
        .focusedSceneObject(sceneModel)
        .focusedSceneObject(navigationModel)
        .environmentObject(sceneModel)
        .environmentObject(navigationModel)
        
        // MARK: - Present Incoming Templates
        
        .sheet(item: $navigationModel.incomingTemplate, content: { template in
            NavigationStack {
                NewTemplateView(model: template)
            }
#if os(macOS)
            .frame(width: 350, height: 400)
#endif
        })
        
// MARK: - Detect Shakes
        #if os(iOS)
        .onShake {
            showShakeSheet = true
        }
        .sheet(isPresented: $showShakeSheet) {
            ShakeView()
        }
        #endif
        
        // MARK: - Listen for incoming URLs
        
        .onOpenURL { url in
            do {
                try navigationModel.handleURL(url)
            } catch let error {
                Logger.logView.error("Root: Unable to import file: \(error.localizedDescription)")
                sceneModel.toaster = .error(note: "Something went wrong")
            }
        }
        
        // MARK: - Continue Activity
        
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            navigationModel.handleSpotlight(activity)
        }
        
        .onContinueUserActivity(Constants.builderHandoffActivity) { activity in
            navigationModel.handleHandoff(activity)
        }
        
        // MARK: - What's New!
        .whatsNewSheet()
        
        // MARK: - Listen for purchases
        
        .task(priority: .background) {
            for await result in StoreKit.Transaction.updates {
                switch result {
                case .verified(let transaction):
                    sceneModel.toaster = .custom(image: Image(systemName: "party.popper"), imageColor: .pink, title: "Thank You!", note: "I really appreciate your support")
                    await transaction.finish()
                case .unverified(_,_):
                    Logger.logView.notice("RootView: An unverified transaction was found.")
                }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
