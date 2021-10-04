//
//  MakeQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/26/21.
//

import SwiftUI
import UniformTypeIdentifiers

// Create a slide-in/slide-out transition for the toast
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .top)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct MakeQRView: View {
    @State private var text = "" //QR Code value
    @State private var bgColor = Color.white //QR code background color
    @State private var fgColor = Color.black //QR code foreground color
    @State private var showToast = false //Boolean representing toast visibility
        
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                //If true, displays a toast to indicate the save was successful
                if showToast {
                Label("Saved", systemImage: "checkmark")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(16)
                    .background(
                        Capsule()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
                    )
                    .transition(.moveAndFade)
                    .onAppear {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                          showToast = false
                        }
                      }
                    }
                    .zIndex(2)
                }
                
                VStack() {
                    // Display the QR code
                    Image(uiImage: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 330, height: 330)
                        .accessibilityLabel("QR Code Image")
                        .onDrag({
                            let qrImage = getQRCode(text: text, bg: bgColor, fg: fgColor)!
                            return NSItemProvider(item: qrImage as NSSecureCoding, typeIdentifier: UTType.png.identifier)
                        })
                        .contextMenu {
                            Button {
                                let imageSaver = ImageSaver()

                                imageSaver.successHandler = {
                                    withAnimation {
                                        showToast = true
                                    }
                                }

                                imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
                            } label: {
                                Label("Save code", systemImage: "square.and.arrow.down")
                            }
                        }
                    
                    //Accept URL to generate QR code from
                    TextField("Enter URL", text: $text)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.tertiarySystemFill)))
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .padding()
                    
                    //Allow the user to pick a foreground and background color for the qr code
                    VStack() {
                        ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                        ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
                    }.padding(.horizontal, 20)
                }.padding(.top, 20)
                .zIndex(1)
            }
        }.navigationBarTitle(Text("QR Generator"), displayMode: .large)
        .navigationBarItems(trailing:
            HStack{
            Button(
                action: {
                    let imageSaver = ImageSaver()

                    imageSaver.successHandler = {
                        withAnimation {
                            showToast = true
                        }
                    }

                    imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
                }){
                    Image(systemName: "square.and.arrow.down")
                }
            })
    }
    //Generate the QR Code
    func getQRCode(text: String, bg: Color, fg: Color) -> Data? {
        //Create CoreImage filters for the qr code
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        //Convert text input to data
        let data = text.data(using: .ascii, allowLossyConversion: false)
        
        filter.setValue(data, forKey: "inputMessage")
        
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        //Set the background color
        colorFilter.setValue(CIColor(color: UIColor(bg)), forKey: "inputColor1")
        //Set the foreground color
        colorFilter.setValue(CIColor(color: UIColor(fg)), forKey: "inputColor0")
        //Apply the colors
        guard let ciimage = colorFilter.outputImage else { return nil }
        //Increase the code's image size
        let transform = CGAffineTransform(scaleX: 15, y: 15)
        let scaledCIImage = ciimage.transformed(by: transform)
        //Convert CoreImage to UIImage
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }

    //Handles photo saving. Handlers are optional.
    class ImageSaver: NSObject {
        var successHandler: (() -> Void)?
        var errorHandler: ((Error) -> Void)?
        
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        }

        @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                errorHandler?(error)
            } else {
                successHandler?()
            }
        }
    }
}

struct MakeQRView_Previews: PreviewProvider {
    static var previews: some View {
        MakeQRView()
.previewInterfaceOrientation(.portrait)
    }
}
