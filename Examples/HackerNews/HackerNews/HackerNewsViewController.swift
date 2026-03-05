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
      state = .loading
      await reload()
      try await fetch()
    }
  }

  func configureCollectionView() {
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: .init(
        handler: { [weak self] _ in
          Task {
            try await self?.fetch(fullyReload: true)
          }
        }))
  }

  var state: APIState<Page<NewsItem>> = .idle
  var isGridMode = false
    
  func toggleViewMode() {
      isGridMode.toggle()
      Task { await self.reload() }
  }

  @CollectionViewBuilder
  override var sections: [any CollectionSection] {
    Grid(id: "initial-section") {
      Label("View mode")
            .textAlignment(.center)

      Toggle(state: isGridMode)
        .onChange { [weak self] _ in
          self?.toggleViewMode()
        }
    }
    .itemHeight(.absolute(20))
    .insets(.vertical(15))

    if isGridMode {
      if #available(iOS 16.0, *) {
        if case .finished(let news) = state {
          Grid(id: "news-grid") {
            ForEach(data: news.items) { item in
              NewsGridItem(item)
                .onTap { [weak self] in
                  guard let url = URL(string: item.url) else { return }
                  let controller = SFSafariViewController(url: url)
                  self?.navigationController?.present(controller, animated: true)
                }
            }
            if news.currentPage < 10 {
              ActivityIndicator()
                .onAppear { [weak self] in
                  try await self?.fetch()
                }
            }
          }
          .minimumItemWidth(180)
          .spacing(8)
          .insets(.horizontal(12).vertical(8))
          .itemInsets(.all(4))
        }
      }
    } else {
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
              .contextMenu(UIMenu(title: "", children: [
                UIAction(
                  title: "Share",
                  image: UIImage(systemName: "square.and.arrow.up")
                ) { [weak self] _ in
                  guard let url = URL(string: item.url) else { return }
                  let activity = UIActivityViewController(
                    activityItems: [url],
                    applicationActivities: nil)
                  self?.present(activity, animated: true)
                },
                UIAction(
                  title: "Copy Link",
                  image: UIImage(systemName: "link")
                ) { _ in
                  UIPasteboard.general.url = URL(string: item.url)
                },
              ]))
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
