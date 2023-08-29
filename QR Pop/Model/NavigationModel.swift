//
//  NavigationModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import CoreSpotlight
import OSLog

@MainActor
/// Provides a single point-of-truth for the Navigation Stack.
class NavigationModel: ObservableObject {
    @Published var incomingTemplate: TemplateModel?
    @Published var path: [Destination]
    @Published var parent: Destination? {
        // The ``path`` needs reset between every change of the parent (Tab or Sidebar) to prevent the path from
        // carrying over to the next view. However, to avoid an akward back-slide animation, the animation must also be
        // removed before clearing the path.
        willSet {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            
            withTransaction(transaction) {
                path = []
            }
        }
    }
    
    init() {
        self.path = []
        self.parent = .builder(code: nil)
        self.incomingTemplate = nil
    }
}

// MARK: - Navigation Logic

extension NavigationModel {
    
    /// Removes `k` number of views from the navigation path. This function is safer than accessing `path` directly.
    /// - Parameter k: Number of views to remove from the path. Default 1.
    func goBack(_ k: Int = 1) throws {
        guard k > 0, k <= path.count else {
            Logger.logModel.notice("NavigationModel: The goBack() function was called with a parameter that is out of bounds.")
            throw NavigationError.invalidPath
        }
        path.removeLast(k)
    }
    
    /// Navigates the current path to a given ``Destination``.
    /// - Parameter destination: The destination to navigate to.
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    /// Navigate to a given ``Destination`` without allowing the user return to this point on the ``path``.
    /// - Parameter destination: The destination to navigate to.
    func navigateWithoutBack(to destination: Destination) {
        path = [destination]
    }
}

// MARK: - Open URL

extension NavigationModel {
    
    /// Handle incoming URLs via the `.onOpenURL` view modifier.
    ///
    /// QR Pop accepts URLs with the following schemes:
    /// - `qrpop://`
    /// - `file://`
    ///
    /// A URL beginning with the `file://` scheme must also end with `.qrpt` and represent a ``TemplateModel``. If both of these conditions are true, ``NewTemplateView`` will be presented with this file.
    ///
    /// A URL beginning with the `qrpop://` scheme interacts directly with the ``NavigationModel``.  All incoming URLs should include a third `/` to act as the URL's "host." The following combinations are allowed:
    /// - `qrpop:///scanner` - Presents ``CodeScannerView``
    /// - `qrpop:///archive` - Presents ``ArchiveList``
    /// - `qrpop:///builder` - Presents ``BuilderList``
    /// - `qrpop:///settings` - Presents ``SettingsView``
    ///
    /// The following `qrpop://` URLs accept additional parameters:
    /// - `qrpop:///archive/UUID` - Presents an item saved within the Archive matching a specified `UUID`.
    /// - `qrpop:///builder/BuilderModel.Kind.rawValue` - Presents a ``BuilderView`` of a specific `BuidlerModel.Kind`.
    /// - `qrpop:///buildlink/?URL` - Presentd a `link` ``BuilderView`` with an initial value. The URL should be percent encoded.
    /// - `qrpop:///buildtext/?String` - Presents a `text` ``BuilderView`` with an initial value.
    /// - `qrpop:///template/?URL` - Presents ``NewTemplateView`` initialized with a template at a specified URL. The URL should be percent encoded.
    ///
    /// - Parameter url: A URL to handle.
    func handleURL(_ url: URL) throws {
        Logger.logModel.debug("NavigationModel: Incoming URL - \(url)")
        
        if url.scheme == "qrpop" {
            try handleDeepLink(url)
        } else if url.scheme == "file" && url.pathExtension.lowercased() == "qrpt" {
            try handleIncomingTemplate(url)
        } else {
            Logger.logModel.notice("NavigationModel: No valid schemes found in incoming URL.")
            throw NavigationError.invalidURL
        }
    }
    
    /// Handles incoming URLs with the `qrpop` scheme.
    /// - Parameter url: A URL to handle.
    private func handleDeepLink(_ url: URL) throws {
        let components = url.pathComponents
        Logger.logModel.debug("NavigationModel: URL Components - \(components)")
        guard let primaryRoute = components[safe: 1]?.lowercased() else {
            Logger.logModel.notice("NavigationModel: No path at all found in incoming URL.")
            throw NavigationError.invalidURL
        }
        
        switch primaryRoute {
            
            /// Handle a URL describing a `.qrpt` file formatted `qrpop:///template/URL`
        case "template":
            guard let fileUrlString = url.query(percentEncoded: false), let fileUrl = URL(string: fileUrlString)
            else {
                Logger.logModel.notice("NavigationModel: Incoming URL passed with invalid template description.")
                throw NavigationError.invalidURL
            }
            try handleIncomingTemplate(fileUrl)
            
            /// Handle a URL describing a builder formatted `qrpop:///builder/BuilderModel.Kind.rawValue`
        case "builder":
            guard let builderKindString = components[safe: 2],
                  let builderKind = BuilderModel.Kind(rawValue: builderKindString)
            else {
                navigate(to: .builder(code: nil))
                return
            }
            let builderModel = BuilderModel(for: builderKind)
            navigate(to: .builder(code: QRModel(design: DesignModel(), content: builderModel)))
            
            /// Handle a URL describing a known template formatted `qrpop:///archive/UUID`
        case "archive":
            guard let libraryId = components[safe: 2],
                  let libraryUUID = UUID(uuidString: libraryId),
                  let entity = try? Persistence.shared.getQREntityWithUUID(libraryUUID),
                  let model = try? entity.asModel()
            else {
                navigate(to: .archive(code: nil))
                return
            }
            navigate(to: .archive(code: model))
            
            /// Handle a URL describing a link builder with an initial value formatted `qrpop:///buildlink/?URL`
            /// URL should be percent encoded.
        case "buildlink":
            guard let content = url.query(percentEncoded: false) else { throw NavigationError.invalidURL }
            var responses = [String](repeating: "", count: 7)
            responses[0] = content
            let builderModel = BuilderModel(responses: responses, result: content, builder: .link)
            navigate(to: .builder(code: QRModel(design: DesignModel(), content: builderModel)))
            
            /// Handle a URL describing a text builder with an initial value formatted `qrpop:///buildtext/String`
        case "buildtext":
            guard let content = url.query(percentEncoded: false) else { throw NavigationError.invalidURL }
            navigate(to: .builder(code: QRModel(design: DesignModel(), content: BuilderModel(text: content))))
            
            /// Navigate to the scanner
        case "scanner":
            navigate(to: .scanner)
            
            /// Navigate to settings
        case "settings":
            navigate(to: .settings)
            
        default:
            Logger.logModel.notice("NavigationModel: No valid path found in incoming URL \(url, privacy: .private).")
            throw NavigationError.invalidURL
        }
    }
    
    /// Handles incoming URLs with the `file` scheme.
    /// - Parameter url: A URL to handle.
    private func handleIncomingTemplate(_ url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else { throw NavigationError.badAccess }
        
        if !FileManager.default.fileExists(atPath: url.path()) {
            var error: NSError?
            
            Logger.logModel.notice("NavigationModel: A Template file URL has appeared that could not be found. Attempting to locate within iCloud.")
            
            // Calling NSFileCoordinator will forcibly download any iCloud files opened-in-place.
            NSFileCoordinator().coordinate(readingItemAt: url, options: .forUploading, error: &error) { coordinatedURL in
                do {
                    let _ = try (url as NSURL).resourceValues(forKeys: [.fileSizeKey])
                } catch let error {
                    Logger.logModel.debug("\(error)")
                    Logger.logModel.error("NavigationModel: Unable to access template URL that may be stored on iCloud.")
                }
            }
        }
        
        let data = try Data(contentsOf: url)
        let model = try TemplateModel(fromData: data)
        
        self.incomingTemplate = model
        
        url.stopAccessingSecurityScopedResource()
    }
    
    /// Handles incoming Spotlight activities.
    /// - Parameter activity: The incoming `NSUserActivity`.
    func handleSpotlight(_ activity: NSUserActivity) {
        if let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
           let coreDataURI = URL(string: id),
           let entity = Persistence.shared.getQREntityWithURI(coreDataURI),
           let model = try? entity.asModel()
        {
            navigate(to: .archive(code: model))
        }
    }
    
    func handleHandoff(_ activity: NSUserActivity) {
        if let designData = activity.userInfo?["design"] as? Data,
           let builderData = activity.userInfo?["content"] as? Data {
            let decoder = JSONDecoder()
            let design = try? decoder.decode(DesignModel.self, from: designData)
            let content = try? decoder.decode(BuilderModel.self, from: builderData)
            let model = QRModel(design: design ?? DesignModel(), content: content ?? BuilderModel())
            navigate(to: .builder(code: model))
        }
    }
}

// MARK: - Continues User Activity

extension NavigationModel {
    
}

// MARK: - Destination

extension NavigationModel {
    
    enum Destination: Hashable, CaseIterable {
        case builder(code: QRModel?)
        case scanner
        case archive(code: QRModel?)
        case settings
        
        var rawValue: String {
            switch self {
            case .builder(code: _):
                return "builder"
            case .scanner:
                return "scanner"
            case .archive(code: _):
                return "archive"
            case .settings:
                return "settings"
            }
        }
        
        var pathIndex: Int {
            switch self {
            case .builder(code: _):
                return 0
            case .scanner:
                return 1
            case .archive(code: _):
                return 2
            case .settings:
                return 3
            }
        }
        
#if os(macOS)
        static var allCases: [NavigationModel.Destination] {
            [.builder(code: nil), .scanner, .archive(code: nil)]
        }
#else
        static var allCases: [NavigationModel.Destination] {
            [.builder(code: nil), .scanner, .archive(code: nil), .settings]
        }
#endif
        
        var symbol: Image {
            switch self {
            case .builder(code: _):
                return Image(systemName: "qrcode")
            case .scanner:
                return Image(systemName: "qrcode.viewfinder")
            case .archive(code: _):
                return Image(systemName: "archivebox")
            case .settings:
                return Image(systemName: "gearshape")
            }
        }
        
        // Our only concern here, comparison wise, is the `case` itself, not the parameters.
        static func == (lhs: NavigationModel.Destination, rhs: NavigationModel.Destination) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .scanner:
                CodeScannerView()
            case .settings:
#if os(iOS)
                SettingsView()
#else
                EmptyView()
#endif
            case .builder(code: nil):
                BuilderList()
            case .builder(code: let code):
                BuilderView(model: code ?? QRModel())
            case .archive(code: nil):
                ArchiveList()
            case .archive(code: let code):
                ArchiveView(model: code ?? QRModel())
            }
        }
    }
}

// MARK: - Error Handling
extension NavigationModel {
    
    enum NavigationError: Error, LocalizedError {
        case invalidPath
        case invalidURL
        case badAccess
    }
}
