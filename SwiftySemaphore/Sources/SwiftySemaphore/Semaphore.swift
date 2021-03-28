//
//  SwiftySemaphore.swift
//
//
//  Created by PJ Fechner on 3/27/21.
//

import Foundation

/// Simple PropertyWrapper that handles Semaphore semantics for property access/mutation.
/// - Note: When Value is a reference Type (e.g. Class) saving references to the wrapped Value outside of this Type's API will not be gated by `semaphore` 
@propertyWrapper
public class Semaphore<Value> {

    public enum Timeout {
        case none
        case dispatchTime(DispatchTime)
        case wallTime(DispatchWallTime)
    }

    private let semaphore: DispatchSemaphore
    private var _wrappedValue: Value

    /// Access gated by `semaphore`
    public var wrappedValue: Value {
        get {
            get()
        }
        set {
            set(newValue)
        }
    }

    public init(wrappedValue: Value, semaphore: DispatchSemaphore = .init(value: 1)) {
        self.semaphore = semaphore
        self._wrappedValue = wrappedValue
    }


    //MARK: Basic Access


    public func get() -> Value {
        return getInSamaphore()
    }

    public func set(_ newValue: Value) {
        runInSemaphore {
            _wrappedValue = newValue
        }
    }


    //MARK: Closure Access


    public func access(_ operation: (Value) -> ()) {
        runInSemaphore {
            operation(_wrappedValue)
        }
    }

    public func set(_ operation: () -> Value) {
        runInSemaphore {
            _wrappedValue = operation()
        }
    }

    public func mutate(_ operation: (Value) -> (Value)) {
        runInSemaphore {
            _wrappedValue = operation(_wrappedValue)
        }
    }


    //MARK: Timout Access


    @discardableResult
    public func access(timeout: Timeout, _ operation: (Value) -> ()) -> DispatchTimeoutResult {
        return runInSemaphore(with: timeout) {
            operation(_wrappedValue)
        }
    }

    @discardableResult
    public func set(timeout: Timeout, _ operation: () -> Value) -> DispatchTimeoutResult {
        return runInSemaphore(with: timeout) {
            _wrappedValue = operation()
        }
    }

    @discardableResult
    public func mutate(timeout: Timeout, _ operation: (Value) -> (Value)) -> DispatchTimeoutResult {
        return runInSemaphore(with: timeout) {
            _wrappedValue = operation(_wrappedValue)
        }
    }


    //MARK: Generic Operations


    public func runInSemaphore(operation: () -> ()) {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
        operation()
    }

    public func runInSemaphore(with timeout: Timeout, operation: () -> ()) -> DispatchTimeoutResult {
        switch wait(with: timeout) {
        case .success:
            operation()
            semaphore.signal()
            return .success
        case .timedOut: return .timedOut
        }
    }


    //MARK: Convenience

    private func getInSamaphore() -> Value {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
        return _wrappedValue
    }

    private func wait(with timeout: Timeout) -> DispatchTimeoutResult {
        switch timeout {
        case .none:
            semaphore.wait()
            return .success
        case .dispatchTime(let timeout):
            return semaphore.wait(timeout: timeout)
        case .wallTime(let timeout):
            return semaphore.wait(wallTimeout: timeout)
        }
    }
}

extension Semaphore: Equatable where Value: Equatable {
    public static func == (lhs: Semaphore<Value>, rhs: Semaphore<Value>) -> Bool {
        lhs._wrappedValue == rhs.wrappedValue
    }
}

extension Semaphore: Comparable where Value: Comparable {
    public static func < (lhs: Semaphore<Value>, rhs: Semaphore<Value>) -> Bool {
        lhs._wrappedValue < rhs.wrappedValue
    }
}
