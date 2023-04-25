//
//  GridList.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

struct GridList<Content1: View, Content2: View>: View {
    @Binding var showingGrid: Bool
    @ViewBuilder var gridContent: Content1
    @ViewBuilder var listContent: Content2
    
    var body: some View {
        switch showingGrid {
        case true:
            grid
        case false:
            list
        }
    }
    
    //MARK: - Grid Layout
    let columns = [GridItem.init(.adaptive(minimum: 110))]
    
    var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                gridContent
                    .padding(.bottom, 10)
            }
            .padding()
        }
    }
    
    //MARK: - List Layout
    
    var list: some View {
        List {
            listContent
        }
#if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .environment(\.defaultMinListRowHeight, 32)
#endif
    }
}

struct GridList_Previews: PreviewProvider {
    static var previews: some View {
        GridList(showingGrid: .constant(true), gridContent: {
            ForEach(0..<25) { i in
                VStack {
                    GroupBox {
                        Text("\(i)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                    }
                    ._addingBackgroundGroup()
                    Text("Title")
                    Spacer()
                }
            }
        }, listContent: {
            ForEach(0..<25) { i in
                Text("\(i)")
            }
        })
    }
}
