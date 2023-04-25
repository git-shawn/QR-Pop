//
//  PlaceFinder.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import MapKit
import Combine

// MARK: Place Finder Button
struct PlaceFinder: View {
    @State private var showingPicker: Bool = false
    @Binding var geoLocation: String
    @State private var query: String = ""
    
    var body: some View {
        Button((query.isEmpty ? "Address" : query), action: {
            showingPicker.toggle()
        })
        .buttonStyle(TextFieldButtonStyle(placeholder: query.isEmpty))
        .sheet(isPresented: $showingPicker, content: {
            NavigationStack {
                SearchForm(geoLocation: $geoLocation, buttonQuery: $query)
                    .navigationTitle("Address Search")
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

private struct SearchForm: View {
    @FocusState private var searchInFocus: Bool
    @StateObject private var mapSearch = MapSearch()
    @Binding var geoLocation: String
    @Binding var buttonQuery: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Search", text: $mapSearch.searchTerm, prompt: Text("Address"))
#if os(iOS)
                .submitLabel(.search)
                .textContentType(.fullStreetAddress)
#else
                .labelsHidden()
#endif
                .focused($searchInFocus)
                .onAppear {
                    searchInFocus = true
                }
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
                            Text(location.subtitle)
                                .font(.system(.caption))
                                .foregroundColor(.secondary)
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
        .formStyle(.grouped)
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

struct PlaceFinder_Previews: PreviewProvider {
    static var previews: some View {
        PlaceFinder(geoLocation: .constant(""))
    }
}

//MARK: Map Search View Model
// Credit: https://stackoverflow.com/a/67131376/20422552

fileprivate class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""
    
    private var cancellables : Set<AnyCancellable> = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        
        $searchTerm
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    debugPrint(error)
                }
            }, receiveValue: { (results) in
                self.locationResults = results
            })
            .store(in: &cancellables)
    }
    
    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        currentPromise?(.success(completer.results))
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {}
}
