//
//  ShareView.swift
//  Share Extension iOS
//
//  Created by Shawn Davis on 4/22/23.
//

import SwiftUI
import Contacts
import RegexBuilder
import UniformTypeIdentifiers
import OSLog
import QRCode

struct ShareView: View {
    let sharedItem: NSExtensionItem?
    var dismiss: () -> Void
    @State private var extensionItemType: ExtensionItemType = .loading
    @State private var toast: SceneModel.Toast? = nil
    @Environment(\.openURL) var openURL
    @Environment(\.verticalSizeClass) var vSizeClass
    
    var body: some View {
        NavigationStack {
            Group {
                switch extensionItemType {
                case .loading:
                    loadingView
                case .url(url: let url, model: let model):
                    urlView(url: url, model: model)
                case .contact(contact: let contact, model: let model):
                    contactView(contact: contact, model: model)
                case .template(model: let model):
                    templateView(model: model)
                case .image(content: let content):
                    imageView(content: content)
                case .error:
                    invalidInputView
                }
            }
            .navigationTitle("QR Pop")
            .toolbar(.visible, for: .automatic)
#if os(iOS)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
#else
            .toolbar(.visible, for: .windowToolbar)
            .frame(maxWidth: 500, maxHeight: 500)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: dismiss, label: {
                        Label("Cancel", systemImage: "x.circle.fill")
                            .foregroundColor(Color("CloseColor"))
                            .symbolRenderingMode(.hierarchical)
                            .fontWeight(.medium)
                            .font(.title2)
                    })
                }
            }
        }
        .task { @MainActor in
            handleInput()
        }
    }
}

// MARK: - Handle Extension Input

extension ShareView {
    
    func handleInput() {
        guard let sharedItem = sharedItem,
              let attachments = sharedItem.attachments
        else {
            extensionItemType = .error
            return
        }
        
        attachments.forEach { attachment in
            
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                debugPrint("URL Shared")
                _ = attachment.loadObject(ofClass: URL.self, completionHandler: { (url,_) in
                    guard let url = url else {
                        extensionItemType = .error
                        return
                    }
                    
                    // URL is an actual URL
                    if !url.isFileURL && !url.absoluteString.isEmpty {
                        extensionItemType = .url(url: url, model: QRModel(design: DesignModel(), content: BuilderModel(text: url.absoluteString)))
                        
                        // URL is a filepath referencing a `.QRPT` file
                    } else if url.isFileURL && url.pathExtension.lowercased() == "qrpt" {
                        guard url.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: url),
                              let templateModel = try? TemplateModel(fromData: data)
                        else {
                            extensionItemType = .error
                            return
                        }
                        url.stopAccessingSecurityScopedResource()
                        extensionItemType = .template(model: templateModel)
                        
                    } else {
                        extensionItemType = .error
                        return
                    }
                })
                
            }
            else if attachment.hasItemConformingToTypeIdentifier(UTType.vCard.identifier) {
                debugPrint("Contact Shared")
                attachment.loadItem(forTypeIdentifier: UTType.vCard.identifier) { (contact,_) in
                    if let contactData = contact as? Data, let vCardString = String(data: contactData, encoding: .utf8) {
                        
                        // Regex to detect PHOTO; followed by some text, a colon, and a BASE64 photo
                        let photoRegex = Regex {
                            "PHOTO;"
                            let colon = CharacterClass(.anyOf(":"))
                            OneOrMore(colon.inverted)
                            ":"
                            OneOrMore {
                                Capture {
                                    CharacterClass(
                                        .whitespace,
                                        ("a"..."z"),
                                        ("A"..."Z"),
                                        ("0"..."9"),
                                        .anyOf("+"),
                                        .anyOf("/")
                                    )
                                }
                            }
                            One(.newlineSequence)
                        }
                        
                        // Parse the Contact's name and set
                        let vCardCleaned = vCardString.replacing(photoRegex, with: "")
                        if let vCardData = vCardCleaned.data(using: .utf8),
                           let contacts = try? CNContactVCardSerialization.contacts(with: vCardData),
                           let contact = contacts.first {
                            extensionItemType = .contact(contact: contact, model: QRModel(design: DesignModel(), content: BuilderModel(text: vCardCleaned)))
                        } else {
                            extensionItemType = .error
                        }
                    } else {
                        extensionItemType = .error
                    }
                }
                
            }
            else if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                debugPrint("Image Shared")
                attachment.loadItem(forTypeIdentifier: UTType.image.identifier) { (filePath,_) in
                    guard let fileURL = filePath as? URL,
                          fileURL.startAccessingSecurityScopedResource(),
                          let imageData = try? Data(contentsOf: fileURL),
                          let image = PlatformImage(data: imageData),
                          let scannedContentArray = QRCode.DetectQRCodes(in: image),
                          let scannedContent = scannedContentArray.first,
                          let contentString = scannedContent.messageString,
                          !contentString.isEmpty
                    else {
                        extensionItemType = .error
                        return
                    }
                    fileURL.stopAccessingSecurityScopedResource()
                    
                    extensionItemType = .image(content: contentString)
                }
            }
            else if attachment.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                debugPrint("Text Shared")
                attachment.loadItem(forTypeIdentifier: UTType.text.identifier) { (string,_) in
                    if let string = string as? String, !string.isEmpty, let url = URL(string: string) {
                        extensionItemType = .url(url: url, model: QRModel(design: DesignModel(), content: BuilderModel(text: url.absoluteString)))
                    } else {
                        extensionItemType = .error
                    }
                }
            }
            else {
                extensionItemType = .error
            }
        }
    }
}

// MARK: - Extension Item Types

extension ShareView {
    
    enum ExtensionItemType {
        case loading
        case url(url: URL, model: QRModel)
        case contact(contact: CNContact, model: QRModel)
        case template(model: TemplateModel)
        case image(content: String)
        case error
    }
}

// MARK: - URL View

extension ShareView {
    
    @ViewBuilder
    func urlView(url: URL, model: QRModel) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                QRCodeView(qrcode: .constant(model))
                Text(url.host() ?? "Website QR Code")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
#if os(macOS)
            .padding(40)
#endif
            Spacer()
            Button("Edit in QR Pop", action: {
                openURL(URL(string: "qrpop:///buildlink/?\(url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
            })
#if os(iOS)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
#else
            .modifier(FooterModifier(dismiss: dismiss))
#endif
        }
#if os(iOS)
        .padding()
#endif
    }
}

// MARK: - Contact View

extension ShareView {
    
    func contactView(contact: CNContact, model: QRModel) -> some View {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        
        return VStack {
            Spacer()
            VStack(spacing: 20) {
                QRCodeView(qrcode: .constant(model))
                if let fullName = formatter.string(from: contact) {
                    Text(fullName)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                } else {
                    Text("Contact QR Code")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            }
#if os(macOS)
            .padding(40)
#endif
            Spacer()
            Button("Edit in QR Pop", action: {
                openURL(URL(string: "qrpop:///buildtext/?\(model.content.result.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
            })
#if os(iOS)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
#else
            .modifier(FooterModifier(dismiss: dismiss))
#endif
        }
#if os(iOS)
        .padding()
#endif
    }
}

// MARK: - Template View

extension ShareView {
    
    @ViewBuilder
    func templateView(model: TemplateModel) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                QRCodeView(design: .constant(model.design), builder: .constant(BuilderModel()))
                VStack(spacing: 10) {
                    Text(model.title)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    Text(model.created, style: .date)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
            }
#if os(macOS)
            .padding(40)
#endif
            Spacer()
            Button(action: {
                do {
                    try model.insertIntoContext(Persistence.shared.container.viewContext)
                    toast = .success(note: "Template saved")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        dismiss()
                    }
                } catch let error {
                    debugPrint(error)
                    Logger(subsystem: Constants.bundleIdentifier, category: "share-extension").error("Could not save Template.")
                    toast = .error(note: "Could not save")
                }
                
            }, label: {
                Text("Add Template")
#if os(iOS)
                    .padding(10)
                    .frame(maxWidth: .infinity)
#endif
            })
#if os(iOS)
            .tint(.primary)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
#else
            .modifier(FooterModifier(dismiss: dismiss))
#endif
        }
#if os(iOS)
        .padding()
#endif
        .toast($toast)
        .background(
            ZStack {
                model.preview(for: 16)?
                    .resizable()
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
                .ignoresSafeArea()
        )
    }
}

// MARK: - Image View

extension ShareView {
    
    @ViewBuilder
    func imageView(content: String) -> some View {
        let layout = vSizeClass == .compact ? AnyLayout(HStackLayout(spacing: 10)) : AnyLayout(VStackLayout(spacing: 20))
        VStack {
            Spacer()
            layout {
                QRCodeView(qrcode: .constant(QRModel(design: DesignModel(), content: BuilderModel(text: content))))
                GroupBox("Scan Results", content: {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            Text(content)
                        }
                        .frame(maxWidth: .infinity)
                    }
                })
            }
#if os(macOS)
            .padding(40)
#endif
            Spacer()
            Button("Edit in QR Pop", action: {
                openURL(URL(string: "qrpop:///buildtext/?\(content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
            })
#if os(iOS)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
#else
            .modifier(FooterModifier(dismiss: dismiss))
#endif
        }
#if os(iOS)
        .padding()
#endif
        .background(Color.antiPrimary, ignoresSafeAreaEdges: .all)
    }
}

// MARK: - Loading View

extension ShareView {
    
    var loadingView: some View {
        VStack {
            ProgressView()
                .controlSize(.large)
        }
    }
}

// MARK: - Invalid Input View

extension ShareView {
    
    var invalidInputView: some View {
        
        VStack {
#if os(macOS)
            Spacer()
#endif
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary)
                    .frame(width: 150)
                Text("This Content is Not Supported")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
#if os(macOS)
            Spacer()
            HStack(spacing: 20) {
                Spacer()
                Button("Cancel", action: dismiss)
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.quaternary, ignoresSafeAreaEdges: .all)
#endif
        }
#if os(iOS)
        .padding()
#endif
        
    }
}

// MARK: - Mac Bottom Button Bar
extension ShareView {
    
    private struct FooterModifier: ViewModifier {
        var dismiss: () -> Void
        
        func body(content: Content) -> some View {
            HStack(spacing: 20) {
                Spacer()
                Button("Cancel", action: dismiss)
                    .buttonStyle(.bordered)
                content
                    .buttonStyle(.borderedProminent)
                    .tint(Color("AccentColor"))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.quaternary, ignoresSafeAreaEdges: .all)
        }
    }
}
