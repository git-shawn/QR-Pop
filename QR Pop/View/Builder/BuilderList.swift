//
//  BuilderList.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

struct BuilderList: View {
    @State var showingGrid = true
    @State private var searchQuery = ""
#if os(macOS)
    @State private var hovering: Bool = false
#endif
    
    //MARK: - View
    var body: some View {
        GridList(showingGrid: $showingGrid, gridContent: {
            ForEach(filterBuildersByQuery(), id: \.rawValue, content: { kind in
                NavigationLink(value: createNavigationDestination(for: kind), label: {
                    VStack(alignment: .center, spacing: 0) {
                        kind.icon
                            .font(.title)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 96, height: 96)
                            .foregroundColor(.accentColor)
                            .background(
                                RoundedRectangle(cornerRadius: 21.5, style: .continuous)
                                    .fill(Color.gray.opacity(0.1))
                            )
#if os(iOS)
                            .hoverEffect(.lift)
#elseif os(macOS)
                            .onHover { hovering in
                                self.hovering = hovering
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 21.5, style: .continuous)
                                    .stroke(LinearGradient.macAccentStyle, lineWidth: 1)
                                    .opacity(0.15)
                            )
#endif
                            .padding([.horizontal, .bottom])
                            .contextMenu {
                                
                            }
                        Text(kind.title)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                        Spacer()
                    }
                })
#if os(macOS)
                .buttonStyle(.plain)
#endif
            })
        }, listContent: {
            ForEach(filterBuildersByQuery(), id: \.rawValue, content: { kind in
                NavigationLink(value: createNavigationDestination(for: kind), label: {
                    Label(title: {
                        Text(kind.title)
                    }, icon: {
                        kind.icon
                            .symbolRenderingMode(.hierarchical)
                    })
                })
            })
        })
#if os(iOS)
        .listStyle(.plain)
#endif
        .searchable(text: $searchQuery, prompt: "Search")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingGrid.toggle()
                }, label: {
                    Label("Toggle View", systemImage: showingGrid ? "list.bullet" : "square.grid.3x3")
                })
                .help("Switch between a list style view and a grid style view.")
            }
        }
        .navigationTitle("Builder")
    }
    
}

//MARK: - Functions

extension BuilderList {
    
    /// Filter the view contents based on `searchQuery` string.
    /// - Returns: A filtered list of `BuilderModel.Kind`. If `searchQuery` is empty, returns `allCases`.
    func filterBuildersByQuery() -> [BuilderModel.Kind] {
        let result = BuilderModel.Kind.allCases.filter {
            $0.title.contains(searchQuery)
        }
        return searchQuery.isEmpty ? BuilderModel.Kind.allCases : result
    }
    
    /// Iniitiates the navigation destination value for a particular `BuilderModel.Kind`.
    /// - Parameter builder: The `.Kind` of builder to use.
    /// - Returns: A `NavigationModel.Destination` with appropriate associated values.
    func createNavigationDestination(for builder: BuilderModel.Kind) -> NavigationModel.Destination {
        let builder = BuilderModel(for: builder)
        let model = QRModel(design: DesignModel(), content: builder)
        return NavigationModel.Destination.builder(code: model)
    }
}

struct BuilderList_Previews: PreviewProvider {
    static var previews: some View {
        BuilderList()
#if os(macOS)
            .frame(width: 400)
#endif
    }
}
