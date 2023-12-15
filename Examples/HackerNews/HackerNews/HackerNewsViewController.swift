//
//  ContentView.swift
//  HackerNews
//
//  Created by Mauricio Cardozo on 15/12/23.
//

import DiffableUI
import Foundation
import SwiftUI
import SafariServices

enum APIState<T> {
  case idle
  case loading
  case finished(T)
}

final class HackerNewsViewController: DiffableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    reload()

    Task {
      try await fetchNews()
    }
  }

  var state: APIState<[NewsItem]> = .idle {
    didSet {
      reload()
    }
  }

  @CollectionViewBuilder
  override var sections: [any CollectionSection] {
    List {
      switch state {
      case .idle:
        Empty()
      case .loading:
        ActivityIndicator()
      case .finished(let news):
        ForEach(data: news) { item in
          News(item)
            .onTap { [weak self] in
              guard let url = URL(string: item.url) else { return }
              let controller = SFSafariViewController(url: url)
              self?
                .navigationController?
                .present(controller, animated: true)
            }
             .padding(.vertical(8).horizontal(12))
        }
      }
    }
    .contentInsetsReference(.readableContent)
  }

  func fetchNews() async throws {
    state = .loading

    guard let url = URL(string: "https://api.hackerwebapp.com/news") else { return }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let news = try decoder.decode([NewsItem].self, from: data)
    state = .finished(news)
  }
}

#Preview {
  NavigationStack {
    HackerNews()
  }
}
