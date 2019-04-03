//
//  ConenienceExtensions.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/2/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
