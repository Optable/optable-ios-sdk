//
//  Locked.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

/// A value guarded by a lock, so it can be shared across threads under Swift 6 strict concurrency.
/// Stands in for `Synchronization.Mutex` (iOS 18) and `OSAllocatedUnfairLock` (iOS 16).
final class Locked<Value> {
    private let lock = NSLock()
    private var value: Value

    init(_ value: Value) {
        self.value = value
    }

    /// Runs `body` with exclusive access to the wrapped value and returns its result.
    func withLock<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}

extension Locked: @unchecked Sendable where Value: Sendable {}
