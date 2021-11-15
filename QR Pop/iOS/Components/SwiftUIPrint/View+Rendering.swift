import SwiftUI

public extension View {
    // Must be called on the main thread.
    func uiView(in frame: CGRect) -> UIView {
        let window = UIWindow(frame: frame)
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        hosting.view.backgroundColor = .white
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view
    }
    
    func image(in frame: CGRect) -> UIImage {
        self
            .uiView(in: frame)
            .image
    }
    
    func pdfPage(in frame: CGRect) -> CGPDFPage {
        self
            .uiView(in: frame)
            .pdfPage
    }
}

public extension UIView {
    var image: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    var pdfPage: CGPDFPage {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)
        let pdfData = pdfRenderer.pdfData { rendererContext in
            rendererContext.beginPage()
            let cgContext = rendererContext.cgContext
            layer.render(in: cgContext)
        }
        let dataProvider = CGDataProvider(data: pdfData as CFData)!
        let pdfDoc = CGPDFDocument(dataProvider)!
        UIGraphicsEndPDFContext();
        return pdfDoc.page(at: 1)!
    }
}
