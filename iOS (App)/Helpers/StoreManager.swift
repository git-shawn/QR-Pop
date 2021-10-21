//
//  StoreManager.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/20/21.
//

import Foundation
import StoreKit
import SwiftUI

class StoreManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    /// Defines the progress of paymentQueue as a simple boolean. True if successful, false if not for any reason.
    @Published var didCompletePurchase: Bool = false
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            /// Payment in process.
            case .purchasing:
                print("Purchase in progress...")
                self.didCompletePurchase = false
            /// Payment completed successfully.
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.didCompletePurchase = true
            /// Payment encounted an error.
            case .failed:
                if let error = transaction.error as? SKError {
                    self.didCompletePurchase = false
                    print("Transaction failed \(error)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            /// Purchase restored
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.didCompletePurchase = true
            /// Needs permission from supervisor (think parental controls).
            case .deferred:
                self.didCompletePurchase = false
            @unknown default:
                break
            }
        }
    }
    
    
    /// Initiates a purchase for 0.99 as a tip.
    func leaveTip() {
        let request = SKProductsRequest(productIdentifiers: Set(["QRTip1"]))
        request.delegate = self
        request.start()
    }
    
    
    /// Responds to a request to the IAP server for SKProducts.
    /// - Parameters:
    ///   - request: The initial request.
    ///   - response: An array of products.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if products.count > 0 {
            makePurchase(product: products[0])
        }
    }
    
    
    /// Begins an IAP.
    /// - Parameter product: The SKProduct to be purchased.
    func makePurchase(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func requestReview() {
        //TODO: Windows is deprecated in iOS15. Come up with an alternative to this.
        if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
    }
}
