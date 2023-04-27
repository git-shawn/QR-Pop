//
//  TipButton.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/20/23.
//

import SwiftUI
import OSLog
import StoreKit

struct TipButton: View {
    @EnvironmentObject var sceneModel: SceneModel
    
    var body: some View {
        Button(action: {
            Task {
                await purchase()
            }
        }, label: {
            Label(title: {
                Text("Buy Me a Coffee")
                    .foregroundColor(.primary)
            }, icon: {
                Image("coffee.heart")
                    .foregroundColor(.accentColor)
            })
        })
    }
    
    @MainActor
    func purchase() async {
        do {
            let product = try await Product.products(for: ["QRTip1"])
            let result = try await product.first?.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    sceneModel.toaster = .custom(image: Image(systemName: "party.popper"), imageColor: .pink, title: "Thank You!", note: "I really appreciate your support")
                case .unverified(_,_):
                    Logger.logView.notice("TipButton: A purcahse returned unverified.")
                }
            case .userCancelled, .pending:
                break
            default:
                break
            }
        } catch {
            Logger.logView.error("TipButton: An unexpected error occured during purchase().")
        }
    }
}

struct TipButton_Previews: PreviewProvider {
    static var previews: some View {
        TipButton()
    }
}
