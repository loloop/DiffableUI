//
//  Identifiable+RemoveDuplicates.swift
//  HackerNews
//
//  Created by Mauricio Cardozo on 22/12/23.
//

import Foundation

extension Array where Element: Identifiable {
  func removeDuplicates() -> Self {
    var uniqueElements: [Element] = []
    for element in self {
      if !uniqueElements.contains(where: { $0.id == element.id }) {
        uniqueElements.append(element)
      }
    }

    return uniqueElements
  }
}
