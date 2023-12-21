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
import OrderedCollections

enum APIState<T> {
  case idle
  case loading
  case finished(T)
}

final class HackerNewsViewController: DiffableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()

    Task {
      try await fetch()
    }
  }

  func configureCollectionView() {
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: .init(
        handler: { [weak self] _ in
          Task {
            self?.state = .loading
            try await self?.fetch(page: 0)
          }
        }))
  }

  var state: APIState<OrderedSet<NewsItem>> = .idle
  var currentPage = 1

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
        ActivityIndicator()
          .onAppear { [weak self] in
            let page = self?.currentPage ?? 0
            try await self?.fetch(page: page)
          }
      }
    }
    .contentInsetsReference(.readableContent)
  }

  func fetch(page: Int = 1) async throws {
    guard let url = URL(string: "https://api.hackerwebapp.com/news?page=\(page)") else { return }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let news = try decoder.decode([NewsItem].self, from: data)

    if case .finished(let t) = state {
      state = .finished(OrderedSet(t+news))
    } else {
      state = .finished(OrderedSet(news))
    }

    collectionView.refreshControl?.endRefreshing()
    currentPage += 1
    await reload()
  }
}

struct HackerNews: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> HackerNewsViewController { .init() }
  func updateUIViewController(_ uiViewController: HackerNewsViewController, context: Context) {}
}

#Preview {
  NavigationStack {
    HackerNews()
  }
}
