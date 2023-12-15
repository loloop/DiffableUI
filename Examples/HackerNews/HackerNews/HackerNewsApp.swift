//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Mauricio Cardozo on 15/12/23.
//

import SwiftUI

@main
struct HackerNewsApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        HackerNews()
          .navigationTitle("Hacker News")
          .ignoresSafeArea(.container)
      }
    }
  }
}

struct HackerNews: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> HackerNewsViewController { .init() }
  func updateUIViewController(_ uiViewController: HackerNewsViewController, context: Context) {}
}
