import SwiftUI

public typealias PagePreview = PagePreviewNamespace.Preview

public enum PagePreviewNamespace {
    
    struct ViewSize: PreferenceKey {
        static var defaultValue: CGSize?
        
        static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
            let n = nextValue()
            guard let next = n else { return }
            value = next
        }
    }
    
    public struct Preview<Page>: View where Page: View {
        let page: Page
        @Binding var pageSize: CGSize
        @Binding var marginsWidth: CGFloat
        
        @State private var viewSize: CGSize?

        public init(page: Page, pageSize: Binding<CGSize>, marginsWidth: Binding<CGFloat> = .constant(0)) {
            self.page = page
            self._pageSize = pageSize
            self._marginsWidth = marginsWidth
        }

        var content: some View {
            page
                .frame(width: pageSize.width, height: pageSize.height)
                .environment(\.colorScheme, .light)
                .scaleEffect(pageScale ?? 1)
        }

        var pageScale: CGFloat? {
            guard
                let viewSize = viewSize,
                viewSize.width > 0,
                viewSize.height > 0
            else { return nil }
            
            let hScale = viewSize.width / pageSize.width
            let vScale = viewSize.height / pageSize.height
            return min(hScale, vScale)
        }
        
        var scaledPageSize: CGSize? {
            guard let pageScale = pageScale else { return nil }
            return CGSize(width: pageSize.width * pageScale, height: pageSize.height * pageScale)
        }
        
        public var body: some View {
            GeometryReader { proxy in
                Rectangle()
                    .fill(Color.clear)
                    .background(GeometryReader { p in
                        Color.clear
                            .preference(key: ViewSize.self, value: p.size)
                    })
                    .overlay(
                        content
                    )
                    .onPreferenceChange(ViewSize.self) {
                        viewSize = $0
                    }
            }
            .frame(width: scaledPageSize?.width, height: scaledPageSize?.height)
            .padding(marginsWidth)
            .background(Color.white)
        }
    }
    
}
