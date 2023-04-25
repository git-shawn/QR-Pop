//
//  ErrorView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

struct ErrorView: View {
    let errorDescription: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Image("LaunchIcon")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.secondary)
                .blendMode(.hardLight)
                .frame(width: 200)
                .padding(.top)
            
            Text("An Error Occured")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .blendMode(.hardLight)
                .bold()
                .padding(.vertical)
            
            Text(errorDescription.uppercased())
                .multilineTextAlignment(.center)
                .fontDesign(.monospaced)
                .frame(maxWidth: 300)
                .padding()
                .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondaryGroupedBackground)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel, action: {
                    dismiss()
                })
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(errorDescription: "QR Pop was unable to do something it really needed to do.")
    }
}
