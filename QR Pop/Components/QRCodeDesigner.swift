//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//
import SwiftUI

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @Binding var bgColor: Color
    @Binding var fgColor: Color
    @State var warningVisible: Bool = false
    
    var body: some View {
        VStack {
            if warningVisible {
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("The background and foreground colors are too similar.")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("This code may not scan. Consider picking colors with more contrast.")
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }.foregroundColor(Color("WarningLabel"))
                .frame(maxWidth: 350)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("WarningBkg"))
                        .padding(5)
                )
                .animation(.spring(), value: warningVisible)
                .padding()
            }
            VStack(alignment: .center, spacing: 10) {
                ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
            }.padding(.horizontal, 20)
            .onChange(of: [bgColor, fgColor], perform: {_ in
                evaluateContrast()
            }).padding(.vertical)
        }
        #if os(macOS)
        .onAppear(perform: {
            evaluateContrast()
        })
        #endif
    }
    
    func evaluateContrast() {
        let cRatio = bgColor.contrastRatio(with: fgColor)
        if cRatio < 2.5 {
            withAnimation {
                warningVisible = true
            }
        } else {
            withAnimation {
                warningVisible = false
            }
        }
    }
}

struct QRCodeDesigner_Previews: PreviewProvider {
    @State static var bg: Color = .white
    @State static var fg: Color = .black
    static var previews: some View {
        QRCodeDesigner(bgColor: $bg, fgColor: $fg)
    }
}

// - MARK: The below functions are not currently in use.

#if os(iOS)
extension UIImage {
    
    /// Overlay an image with another image. The overlaying image will be centered and a quarter the size of the initial image.
    /// - Parameter overlay: The image to overlay
    /// - Returns: A new image, created as a merger of the initial image and the overlay.
    /// - Warning: If being used for a QR Code, the code's error correction must be as high as possible.
    func overlayWith(overlay: UIImage) -> UIImage {
        let initialImage = self

        UIGraphicsBeginImageContext(size)

        // The initial size of the QR code
        let codeSize = CGRect(x: 0, y: 0, width: initialImage.size.width, height: initialImage.size.height)
        // The size of the overlaying image, which is 25% the size of the QR code.
        let overlaySize = CGRect(x: 0, y: 0, width: (initialImage.size.width * 0.25), height: (initialImage.size.width * 0.25))
          
        initialImage.draw(in: codeSize)
        overlay.draw(in: overlaySize, blendMode: .normal, alpha: 1.0)

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
}
#else
extension NSImage {
    
    /// Overlay an image with another image. The overlaying image will be centered and a quarter the size of the initial image.
    /// - Parameter overlay: The image to overlay
    /// - Returns: A new image, created as a merger of the initial image and the overlay.
    /// - Warning: If being used for a QR Code, the code's error correction must be as high as possible.
    func overlayWith(overlay: NSImage) -> NSImage {
        // Convert the images to CIImage
        guard let initialImage = CIImage(data: self.png!) else {
            print("Error: Could not convert initial image into CIImage in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        guard let overlayImage = CIImage(data: overlay.png!) else {
            print("Error: Could not convert overlay into CIImage in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        
        // Resize the
        guard let resizeFilter = CIFilter(name:"CILanczosScaleTransform") else {
            print("Error: Could not scale images in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        let scale = self.size.height * 0.25
        let aspectRatio = overlay.size.width / overlay.size.height
        
        resizeFilter.setValue(overlayImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let resizedOverlayImage = resizeFilter.outputImage
        
        guard let filter = CIFilter(name: "CIAdditionCompositing") else {
            print("Error: Could not composite images in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        filter.setDefaults()
        
        filter.setValue(resizedOverlayImage, forKey: "inputImage")
        filter.setValue(initialImage, forKey: "inputBackgroundImage")
        
        let combineResultImage = filter.outputImage
        
        let rep = NSCIImageRep(ciImage: combineResultImage!)
        let finalResult = NSImage(size: rep.size)
        finalResult.addRepresentation(rep)
        
        return finalResult
    }
}
#endif
