//
//  XCTAssertEqual.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation

/// Returns the Cartesian product of multiple arrays
/// - Parameter arrays: An array of arrays of type T
/// - Returns: Array of arrays representing all combinations
func cartesianProduct<T>(_ arrays: [[T]]) -> [[T]] {
    arrays.reduce([[]] as [[T]]) { acc, array in
        acc.flatMap { prefix in
            array.map { element in
                prefix + [element]
            }
        }
    }
}
