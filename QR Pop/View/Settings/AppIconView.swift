//
//  AppIconView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/24/23.
//
#if os(iOS)

import SwiftUI

struct AppIconView: View {
    @StateObject var model = AppIconModel()
    
    var body: some View {
        List(AppIconModel.AppIcon.allCases) { icon in
            Button(action: {
                model.updateAppIcon(to: icon)
            }, label: {
                HStack(spacing: 10) {
                    icon.iconImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48)
                        .mask {
                            RoundedRectangle(cornerRadius: 8.42, style: .continuous)
                        }
                    Text(icon.description)
                        .foregroundColor(.primary)
                    Spacer()
                    if model.selectedAppIcon == icon {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
            })
        }
        .navigationTitle("Change App Icon")
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
    }
}

#endif
