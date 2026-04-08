//
//  RangeReplaceableCollection+Compat.swift
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

import Foundation
import SwiftUI

extension RangeReplaceableCollection where Self: MutableCollection, Index == Int {
    mutating func removeCompat(atOffsets offsets: IndexSet) {
        if #available(iOS 13.0, *) {
            remove(atOffsets: offsets)
        } else {
            // Remove from highest index to lowest to avoid shifting issues
            for index in offsets.sorted(by: >) {
                remove(at: index)
            }
        }
    }
}
