//
//  NSLock++.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

extension NSLock {
    /// Runs `body` while holding the lock and returns its result.
    /// Stands in for `NSLock.withLock(_:)`, which requires iOS 16.
    func synchronized<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
