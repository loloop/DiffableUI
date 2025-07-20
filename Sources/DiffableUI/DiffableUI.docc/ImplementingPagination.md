# Implementing Pagination

Learn how to implement efficient pagination patterns for large datasets.

## Overview

Pagination is essential for apps that work with large datasets. This guide covers various pagination strategies including infinite scrolling, page-based loading, cursor-based pagination, and handling edge cases.

## Basic Pagination Setup

### Data Structure

First, define a structure to manage paginated data:

```swift
struct PaginatedData<T> {
    var items: [T] = []
    var currentPage: Int = 0
    var hasMorePages: Bool = true
    var isLoading: Bool = false
    var error: Error?
    
    mutating func appendPage(_ newItems: [T], hasMore: Bool) {
        items.append(contentsOf: newItems)
        currentPage += 1
        hasMorePages = hasMore
        isLoading = false
        error = nil
    }
    
    mutating func reset() {
        items = []
        currentPage = 0
        hasMorePages = true
        isLoading = false
        error = nil
    }
}
```

### Pagination State

Define states for your paginated view:

```swift
enum PaginationState<T> {
    case initial
    case loading
    case loaded(items: [T])
    case loadingMore(items: [T])
    case error(Error)
    case allLoaded(items: [T])
}
```

## Infinite Scrolling

Implement automatic loading when scrolling near the end:

```swift
class InfiniteScrollViewController: DiffableViewController {
    @State private var paginatedData = PaginatedData<Item>()
    private let pageSize = 20
    private let loadMoreThreshold = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialData()
    }
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            ForEach(paginatedData.items) { item in
                ItemView(item: item)
            }
            
            if paginatedData.isLoading {
                LoadingIndicator()
            } else if let error = paginatedData.error {
                ErrorView(error: error) {
                    self.retryLoading()
                }
            }
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // Check if we should load more
        let itemsCount = paginatedData.items.count
        if indexPath.item >= itemsCount - loadMoreThreshold,
           !paginatedData.isLoading,
           paginatedData.hasMorePages {
            loadMoreData()
        }
    }
}
```

### Loading Logic

```swift
extension InfiniteScrollViewController {
    private func loadInitialData() {
        paginatedData.reset()
        paginatedData.isLoading = true
        reload()
        
        Task {
            do {
                let items = try await fetchItems(page: 0, pageSize: pageSize)
                paginatedData.appendPage(items, hasMore: items.count == pageSize)
                reload()
            } catch {
                paginatedData.error = error
                paginatedData.isLoading = false
                reload()
            }
        }
    }
    
    private func loadMoreData() {
        guard !paginatedData.isLoading else { return }
        
        paginatedData.isLoading = true
        reload()
        
        Task {
            do {
                let items = try await fetchItems(
                    page: paginatedData.currentPage + 1,
                    pageSize: pageSize
                )
                paginatedData.appendPage(items, hasMore: items.count == pageSize)
                reload()
            } catch {
                paginatedData.error = error
                paginatedData.isLoading = false
                reload()
            }
        }
    }
}
```

## Cursor-Based Pagination

For APIs that use cursor-based pagination:

```swift
struct CursorPaginatedData<T> {
    var items: [T] = []
    var nextCursor: String?
    var isLoading: Bool = false
    var error: Error?
    
    var hasMore: Bool {
        nextCursor != nil
    }
}

class CursorPaginationViewController: DiffableViewController {
    @State private var data = CursorPaginatedData<Post>()
    
    private func loadMore() async {
        guard !data.isLoading, data.hasMore else { return }
        
        data.isLoading = true
        reload()
        
        do {
            let response = try await API.fetchPosts(cursor: data.nextCursor)
            data.items.append(contentsOf: response.posts)
            data.nextCursor = response.nextCursor
            data.isLoading = false
            reload()
        } catch {
            data.error = error
            data.isLoading = false
            reload()
        }
    }
}
```

## Load More Button

Implement manual "Load More" button:

```swift
struct LoadMoreSection: CollectionSection {
    let id = "load-more"
    let hasMore: Bool
    let isLoading: Bool
    let onLoadMore: () -> Void
    
    var items: [any CollectionItem] {
        guard hasMore else { return [] }
        
        if isLoading {
            return [
                ActivityIndicator()
                    .centerAligned()
                    .padding(.vertical, 20)
            ]
        } else {
            return [
                Button("Load More") {
                    onLoadMore()
                }
                .centerAligned()
                .padding(.vertical, 20)
            ]
        }
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}
```

## Bidirectional Pagination

For timelines that load in both directions:

```swift
class TimelineViewController: DiffableViewController {
    @State private var items: [TimelineItem] = []
    @State private var oldestID: String?
    @State private var newestID: String?
    @State private var isLoadingNewer = false
    @State private var isLoadingOlder = false
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        ListSection {
            // Pull to refresh area
            if isLoadingNewer {
                ActivityIndicator()
                    .padding(.vertical, 20)
            }
            
            // Timeline items
            ForEach(items) { item in
                TimelineItemView(item: item)
            }
            
            // Load more area
            if isLoadingOlder {
                ActivityIndicator()
                    .padding(.vertical, 20)
            }
        }
    }
    
    private func loadNewer() async {
        guard !isLoadingNewer else { return }
        
        isLoadingNewer = true
        reload()
        
        do {
            let newItems = try await API.fetchTimeline(
                after: newestID,
                limit: 20
            )
            
            if !newItems.isEmpty {
                items.insert(contentsOf: newItems, at: 0)
                newestID = newItems.first?.id
            }
            
            isLoadingNewer = false
            reload()
        } catch {
            isLoadingNewer = false
            reload()
        }
    }
    
    private func loadOlder() async {
        guard !isLoadingOlder else { return }
        
        isLoadingOlder = true
        reload()
        
        do {
            let newItems = try await API.fetchTimeline(
                before: oldestID,
                limit: 20
            )
            
            if !newItems.isEmpty {
                items.append(contentsOf: newItems)
                oldestID = newItems.last?.id
            }
            
            isLoadingOlder = false
            reload()
        } catch {
            isLoadingOlder = false
            reload()
        }
    }
}
```

## Pagination with Search

Combine search with pagination:

```swift
class SearchViewController: DiffableViewController {
    @State private var searchQuery = ""
    @State private var searchResults = PaginatedData<SearchResult>()
    private let searchDebouncer = Debouncer(delay: 0.3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        if searchQuery.isEmpty {
            EmptyStateSection(
                message: "Search for something...",
                icon: "magnifyingglass"
            )
        } else if searchResults.items.isEmpty && !searchResults.isLoading {
            EmptyStateSection(
                message: "No results for '\(searchQuery)'",
                icon: "magnifyingglass"
            )
        } else {
            SearchResultsSection(
                results: searchResults.items,
                isLoading: searchResults.isLoading
            )
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        
        searchDebouncer.debounce { [weak self] in
            self?.performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchQuery = ""
            searchResults.reset()
            reload()
            return
        }
        
        searchQuery = query
        searchResults.reset()
        searchResults.isLoading = true
        reload()
        
        Task {
            do {
                let results = try await API.search(
                    query: query,
                    page: 0,
                    pageSize: 20
                )
                searchResults.appendPage(results, hasMore: results.count == 20)
                reload()
            } catch {
                searchResults.error = error
                searchResults.isLoading = false
                reload()
            }
        }
    }
}
```

## Caching and Offline Support

Implement caching for better performance:

```swift
class CachedPaginationViewController: DiffableViewController {
    @State private var paginatedData = PaginatedData<Article>()
    private let cache = ArticleCache()
    
    private func loadPage(_ page: Int) async {
        // Try cache first
        if let cachedItems = await cache.getPage(page) {
            paginatedData.items = cachedItems
            reload()
        }
        
        // Then fetch fresh data
        do {
            let items = try await API.fetchArticles(page: page)
            await cache.savePage(page, items: items)
            paginatedData.appendPage(items, hasMore: items.count == pageSize)
            reload()
        } catch {
            // If network fails but we have cache, show cached data
            if paginatedData.items.isEmpty,
               let cachedItems = await cache.getPage(page) {
                paginatedData.items = cachedItems
                paginatedData.error = error // Show error banner
            } else {
                paginatedData.error = error
            }
            reload()
        }
    }
}

actor ArticleCache {
    private var pages: [Int: [Article]] = [:]
    
    func getPage(_ page: Int) -> [Article]? {
        pages[page]
    }
    
    func savePage(_ page: Int, items: [Article]) {
        pages[page] = items
    }
    
    func clear() {
        pages.removeAll()
    }
}
```

## Performance Best Practices

### 1. Prefetching

```swift
extension PaginationViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        let maxIndex = indexPaths.map { $0.item }.max() ?? 0
        
        if maxIndex >= items.count - prefetchThreshold {
            Task {
                await loadMoreIfNeeded()
            }
        }
    }
}
```

### 2. Debouncing

```swift
class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        
        let workItem = DispatchWorkItem(block: action)
        self.workItem = workItem
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay,
            execute: workItem
        )
    }
}
```

### 3. Memory Management

```swift
class PaginationViewController: DiffableViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Keep only visible items + buffer
        if let visibleIndexPaths = collectionView.indexPathsForVisibleItems {
            let minIndex = max(0, (visibleIndexPaths.map { $0.item }.min() ?? 0) - 10)
            let maxIndex = min(items.count, (visibleIndexPaths.map { $0.item }.max() ?? 0) + 10)
            
            // Trim items outside visible range
            items = Array(items[minIndex..<maxIndex])
        }
    }
}
```

## Error Handling

Implement robust error handling:

```swift
struct PaginationErrorView: CollectionItem {
    let error: Error
    let onRetry: () -> Void
    
    var items: [any CollectionItem] {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.systemRed)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
        }
        .padding()
    }
}
```

## Key Takeaways

1. **Choose the Right Strategy**: Use infinite scroll for feeds, manual loading for control
2. **Handle Edge Cases**: Empty states, errors, end of data
3. **Optimize Performance**: Implement prefetching and caching
4. **Provide Feedback**: Show loading states and error messages
5. **Consider UX**: Maintain scroll position, handle refresh properly

## Next Steps

- Implement custom loading animations
- Add skeleton screens while loading
- Create reusable pagination components
- Add analytics for pagination events