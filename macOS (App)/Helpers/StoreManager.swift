//
//  StoreManager.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import Foundation
import StoreKit
import Combine

/// A helper class to manage in-app purchases
class StoreManager: NSObject {
    static let shared = StoreManager()
    private var totalRestoredPurchases: Int = 0
    private var runTipProcess: Bool = false
    let purchasePublisher = PassthroughSubject<StoreManagerTransactionState, Never>()
    
    /// Possible states that the transaction can be in.
    enum StoreManagerTransactionState {
        /// Successful purchase
        case purchased
        /// Product was restored
        case restored
        /// Purchase failed (check the log for an error)
        case failed
        /// Purchase deferred (this means another account was asked for permission first)
        case deferred
        /// Purcahse in process
        case purchasing
        /// A restore of all purchases completed
        case restoreComplete
        /// No products were available to restore
        case noneToRestore
    }
    
    private override init() {
        super.init()
    }
    
    /// Get the IDs of products to request from the IAP server.
    /// - Returns: A String array of product IDs.
    func getProductIDs() -> [String] {
        return ["QRTip1"]
    }
    
    /// Request all products from the IAP server.
    func getProducts() {
        let productIDs = Set(getProductIDs())
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    /// A combined chain of many functions that fetches the tip product from the IAP server, initiates the purchase, and sees it through.
    func leaveTip() {
        runTipProcess = true
        let productIDs = Set(getProductIDs())
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    /// Determines whether an accouont can make in-app purchases or not.
    /// - Returns: True if the account can make purchases, false if it cannot.
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Perform an in-app purchase of a product.
    /// - Parameter product: The product to buy.
    /// - Returns: True if the payment has been queued, false if it hasn't.
    func makePurchase(product: SKProduct) -> Bool {
        if !StoreManager.shared.canMakePayments() {
            return false
        } else {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        return true
    }
    
    /// Restore all non-consumable purchases. There aren't any in this app, but better safe than sorry.
    func restorePurchases() {
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /// The restore request succeeded successfully (that's a mouthful)
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            purchasePublisher.send(.restoreComplete)
        } else {
            purchasePublisher.send(.noneToRestore)
        }
    }
    
    /// There was an error restoring, so this function logs it and alerts the UI
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            purchasePublisher.send(.failed)
            print(error.localizedDescription)
        }
    }
    
    /// Subscribe to updates in the purchase queue
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    /// Unsubscribe from updates in the purchase queue
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
}

// Evaluate the products returned from the IAP server. If none returned, that's an error.
extension StoreManager: SKProductsRequestDelegate, SKRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let invalidIDs = response.invalidProductIdentifiers
        let validIDs = response.products
        if validIDs.count > 0 {
            if(runTipProcess) {
                let beginPurchase = makePurchase(product: response.products[0])
                if (!beginPurchase) {
                    purchasePublisher.send(.failed)
                }
            } else {
                productsDB.shared.items = response.products
            }
        }
        print("Invalid IDs found. Check StoreManager.swift: \(invalidIDs)")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error! Could not find products: \(error)")
    }
    
    func requestReview() {
        SKStoreReviewController.requestReview()
    }
}

// Evaluate the purchasing process and publish progres reports as we go.
extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                purchasePublisher.send(.purchased)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                totalRestoredPurchases += 1
                purchasePublisher.send(.restored)
            case .failed:
                if let error = transaction.error as? SKError {
                    purchasePublisher.send(.failed)
                    print("Payment failed \(error.code)")
                }
            case .deferred:
                purchasePublisher.send(.deferred)
            case .purchasing:
                purchasePublisher.send(.purchasing)
            default:
                break
            }
        }
    }
}

/// Store products in a database of all products. This can be programatically fed into a list, but for QR Pop's purposes there's only one product.
/// We'll always reference it as the only object in the array.
final class productsDB: ObservableObject, Identifiable {
    static let shared = productsDB()
    var items:[SKProduct] = []
    {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
}

