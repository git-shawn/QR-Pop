//
//  FormStateEngine.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/3/23.
//

import SwiftUI
import OSLog
import Combine

class FormStateEngine: ObservableObject, Equatable {
    @Published var inputs: [String]
    @Published var outputs: [String]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(initial: [String]) {
        self.inputs = initial
        self.outputs = initial
        
        $inputs
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] i in
                self?.outputs = i
            }
            .store(in: &cancellables)
    }
    
    static func == (lhs: FormStateEngine, rhs: FormStateEngine) -> Bool {
        lhs.outputs == rhs.outputs
    }
}

protocol BuilderForm {
    func determineResult(for outputs: [String])
}
