//
//  ShakeView.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/12/23.
//
#if os(iOS)
import SwiftUI

struct ShakeView: View {
    @AppStorage("detectShakes") private var detectShakes: Bool = true
    @State private var submittingFeedback: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Send Feedback")
                    .font(.title2)
                    .bold()
                Text("Did something go wrong? Tap the button below to submit feedback via Google Forms.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            .padding(.top, 26)
            
            Spacer()
            
            Button(action: {
                submittingFeedback.toggle()
            }, label: {
                Text("Submit Feedback")
                    .padding(.vertical, 6)
                    .frame(maxWidth: 400)
            })
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            
            Spacer()
            
            Divider()
            
            Toggle(isOn: $detectShakes, label: {
                VStack(alignment: .leading) {
                    Text("Shake for feedback")
                    Text("Toggle off to disable this popup")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            })
            .tint(.accentColor)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .transition(.move(edge: .bottom))
        .presentationDetents([.height(270)])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $submittingFeedback) {
            NavigationStack {
                WebView(url: URL(string: "https://forms.gle/L7aV8KRTT8EXLT2K6")!)
                    .ignoresSafeArea()
                    .navigationTitle("Feedback")
                    .navigationBarTitleDisplayMode(.inline)
                    .preferredColorScheme(.light)
                    .toolbar {
                        Button("Done", action: {
                            dismiss()
                        })
                    }
            }
        }
    }
}

struct ShakeView_Previews: PreviewProvider {
    static var previews: some View {
        ShakeView()
    }
}
#endif
