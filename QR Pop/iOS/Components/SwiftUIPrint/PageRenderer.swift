import SwiftUI
import UIKit
import Dispatch
import PDFKit

public class PageRenderer<Page>: UIPrintPageRenderer where Page: View {
    public let pages: [Page]
    public let fitting: PageFitting
    
    public init(pages: [Page], fitting: PageFitting) {
        self.pages = pages
        self.fitting = fitting
        super.init()
    }
    
    public convenience init(page: Page, fitting: PageFitting) {
        self.init(pages: [page], fitting: fitting)
    }

    override open var numberOfPages: Int { pages.count }
    
    override open func drawPage(at pageIndex: Int, in printableRect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: 0, y: paperRect.height)
        context.scaleBy(x: 1, y: -1)
        
        let frame: CGRect
        switch fitting {
        case .fitToPrintableRect:
            frame = printableRect
        case .fitToPaper:
            frame = paperRect
        }
        
        let pdfPage = DispatchQueue.main.sync {
            pages[pageIndex]
                .environment(\.colorScheme, .light)
                .frame(width: frame.width, height: frame.height)
                .pdfPage(in: CGRect(origin: CGPoint(x: 0, y: 20), size: frame.size))
        }
        context.translateBy(x: frame.minX, y: frame.minY)
        context.drawPDFPage(pdfPage)
    }
}
