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

struct Page<T: Hashable> {
  let items: [T]
  let currentPage: Int
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
            try await self?.fetch(fullyReload: true)
          }
        }))
  }

  var state: APIState<Page<NewsItem>> = .idle

  @CollectionViewBuilder
  override var sections: [any CollectionSection] {
    List {
      switch state {
      case .idle:
        Empty()
      case .loading:
        ActivityIndicator()
      case .finished(let news):
        ForEach(data: news.items) { item in
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
        if news.currentPage < 10 {
          ActivityIndicator()
            .onAppear { [weak self] in
              try await self?.fetch()
            }
        }
      }
    }
    .contentInsetsReference(.readableContent)
  }

  func fetch(fullyReload: Bool = false) async throws {
    let currentPage = if case .finished(let page) = state, !fullyReload {
      page.currentPage
    } else {
      1
    }

    guard let url = URL(
      string: "https://api.hackerwebapp.com/news?page=\(currentPage)")
    else { return }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let news = try decoder.decode([NewsItem].self, from: data)

    if case .finished(let t) = state {
      state = .finished(
        .init(
          items: (t.items + news).removeDuplicates(),
          currentPage: currentPage+1))
    } else {
      state = .finished(
        .init(
          items: news,
          currentPage: currentPage+1))
    }

    collectionView.refreshControl?.endRefreshing()
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
