//
//  View+Combine.swift
//  QR Pop
//
//  Modification of Tunous / DebouncedOnChange
//  https://github.com/Tunous/DebouncedOnChange/
//  Copyright (c) 2022 Łukasz Rutkowski
//  MIT License
//

import SwiftUI
import Combine

extension View {
    
    /// Observes changes to a given `Equatable` value and,
    /// after a debounce period has passed, initiates an action.
    /// - Parameters:
    ///   - value: The value to observe.
    ///   - debounce: A time, in seconds, to wait after the last change has
    ///   been observed before calling `action`.
    ///   - action: An action to call after `value` has changed.
    public func onChange<Value>(
        of value: Value,
        debounce: TimeInterval,
        perform action: @escaping (_ newValue: Value) -> Void
    ) -> some View where Value: Equatable {
        self.modifier(DebouncedChangeViewModifier(trigger: value, debounceTimer: debounce, action: action))
    }
}

private struct DebouncedChangeViewModifier<Value>: ViewModifier where Value: Equatable {
    let trigger: Value
    let debounceTimer: TimeInterval
    let action: (Value) -> Void
    
    @State private var debouncedTask: Task<Void, Never>?
    
    func body(content: Content) -> some View {
        content.onChange(of: trigger) { value in
            debouncedTask?.cancel()
            debouncedTask = Task { @MainActor in
                do {
                    try await Task<Never, Never>.sleep(for: .seconds(debounceTimer))
                    action(value)
                } catch { }
            }
        }
    }
}
