//
//  InitiatePrinting.swift
//  
//
//  Created by Wolf McNally on 2/4/21.
//

import SwiftUI

public enum PageFitting {
    case fitToPrintableRect
    case fitToPaper
}

public enum PrintingResult {
    case success
    case failure(Error)
    case userCancelled
}

public func presentPrintInteractionController<Page>(pages: [Page], jobName: String? = nil, fitting: PageFitting = .fitToPrintableRect, completion: ((PrintingResult) -> Void)? = nil) where Page: View {
    let printController = UIPrintInteractionController()
    let printInfo = UIPrintInfo.printInfo()
    if let jobName = jobName {
        printInfo.jobName = jobName
    }
    printController.printInfo = printInfo
    printController.printPageRenderer = PageRenderer(pages: pages, fitting: fitting)
    printController.present(animated: true) { _, completed, error in
        guard let completion = completion else { return }
        if completed {
            completion(.success)
        } else {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.userCancelled)
            }
        }
    }
}

public func presentPrintInteractionController<Page>(page: Page, fitting: PageFitting = .fitToPrintableRect, completion: ((PrintingResult) -> Void)? = nil) where Page: View {
    presentPrintInteractionController(pages: [page], fitting: fitting, completion: completion)
}
