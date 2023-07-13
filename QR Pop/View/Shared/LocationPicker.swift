//
//  LocationPicker.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import MapKit
import Combine
import OSLog

// MARK: Place Finder Button
struct LocationPicker: View {
    @State private var showingPicker: Bool = false
    @Binding var geoLocation: String
    @State private var query: String = ""
    
    var body: some View {
        Button((query.isEmpty ? "Location" : query), action: {
            showingPicker.toggle()
        })
        .buttonStyle(TextFieldButtonStyle(placeholder: query.isEmpty))
        .sheet(isPresented: $showingPicker, content: {
            NavigationStack {
                LocationPickerSearchForm(geoLocation: $geoLocation, buttonQuery: $query)
                    .navigationTitle("Location Search")
#if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", action: {
                                showingPicker.toggle()
                            })
                        }
                    }
            }
#if os(macOS)
            .frame(minWidth: 350, minHeight: 250)
#endif
        })
        .onChange(of: geoLocation, perform: { newGeo in
            // Detect reset
            if newGeo == "" {
                query = ""
            }
        })
    }
}

//MARK: - Search Form

private struct LocationPickerSearchForm: View {
    @FocusState private var searchInFocus: Bool
    @StateObject private var mapSearch = LocationSearchCompleter()
    @Binding var geoLocation: String
    @Binding var buttonQuery: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            #if os(macOS)
            TextField("Search", text: $mapSearch.searchTerm, prompt: Text("Location"))
                .labelsHidden()
                .focused($searchInFocus)
                .onAppear {
                    searchInFocus = true
                }
            #endif
            Section(mapSearch.locationResults.isEmpty ? "" : "Results") {
                ForEach(mapSearch.locationResults, id: \.self) { location in
                    Button(action: {
                        parseCoordinates(location: location)
                        buttonQuery = mapSearch.searchTerm
                        dismiss()
                    }, label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(location.title)
                                .foregroundColor(.primary)
                            if !location.subtitle.isEmpty {
                                Text(location.subtitle)
                                    .font(.system(.caption))
                                    .foregroundColor(.secondary)
                            }
                        }
                    })
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }
            .animation(.easeIn, value: mapSearch.locationResults)
        }
#if os(macOS)
        .listStyle(.insetGrouped)
#else
        .toolbarBackground(.hidden, for: .automatic)
        .listStyle(.grouped)
        .searchable(text: $mapSearch.searchTerm, prompt: Text("Location"))
#endif
    }
    
    func parseCoordinates(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                geoLocation = "geo:\(coordinate.latitude),\(coordinate.longitude),1"
            }
        }
    }
}

struct LocationPicker_Previews: PreviewProvider {
    static var previews: some View {
        LocationPicker(geoLocation: .constant(""))
    }
}
