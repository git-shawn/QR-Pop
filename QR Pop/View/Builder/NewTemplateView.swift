//
//  NewTemplateView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/20/23.
//

import SwiftUI
import OSLog

struct NewTemplateView: View {
    let model: TemplateModel
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) var vSizeClass
    @State private var toast: SceneModel.Toast? = nil
    
    var body: some View {
        let layout = (UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact) ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout(spacing: 0))
        VStack {
            layout {
                Spacer()
                
                QRCodeView(
                    design: .constant(model.design),
                    builder: .constant(BuilderModel()),
                    interactivity: .view
                )
                .padding(.horizontal)
                .frame(minHeight: 0, maxHeight: 400)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: .black.opacity(0.3), radius: 10)

                VStack(spacing: 6) {
                    Text(model.title)
                        .font(.title2)
                    Text(model.created, style: .date)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Material.thin)
                )
                .padding(.horizontal)
                
                Spacer()
            }
#if os(iOS)
            Spacer()
            Button(action: {
                do {
                    try model.insertIntoContext(moc)
                    toast = .success(note: "Template added")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        dismiss()
                    }
                } catch {
                    Logger.logView.error("NewTemplateView: Tempalte could not be inserted into the database.")
                    toast = .error(note: "Template could not be added")
                }
            }, label: {
                Text("Add to Templates")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
            })
            .padding()
            .buttonStyle(.bordered)
            .tint(.primary)
            .buttonBorderShape(.capsule)
#endif
        }
        .toast($toast)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(blurredBackground)
        .navigationTitle("New Template")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: {
                    dismiss()
                })
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add to Templates", action: {
                    do {
                        try model.insertIntoContext(moc)
                        toast = .success(note: "Template added")
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            dismiss()
                        }
                    } catch {
                        Logger.logView.error("NewTemplateView: Tempalte could not be inserted into the database.")
                        toast = .error(note: "Template could not be added")
                    }
                })
            }
#else
            ToolbarItem(placement: .primaryAction) {
                ImageButton("Cancel", systemImage: "x.circle.fill", action: {
                    dismiss()
                })
                .font(.title2)
                .bold()
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            }
#endif
        }
    }
}

extension NewTemplateView {
    
    var blurredBackground: some View {
        ZStack {
            model.preview(for: 12)?
                .resizable()
            Rectangle()
                .fill(.ultraThinMaterial)
        }
#if os(iOS)
        .ignoresSafeArea(.all)
#endif
    }
}

struct NewTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Nothing!")
        }
        .frame(width: 500, height: 500)
        .sheet(isPresented: .constant(true), content: {
            NavigationStack {
                NewTemplateView(model: TemplateModel(title: "My Template", created: Date(), design: DesignModel(eyeShape: .circle, pixelShape: .roundedPath, eyeColor: Color(red: 0.6, green: 0.8, blue: 0.2), pupilColor: Color(red: 0.6, green: 0.8, blue: 0.2), pixelColor: Color(red: 0.8, green: 0.8, blue: 0.2), backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2), errorCorrection: .low), id: UUID()))
            }
        })
    }
}
