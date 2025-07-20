# Building a News Feed

Learn how to build a complete news feed with pagination, loading states, and dynamic content.

## Overview

This tutorial walks through building a Hacker News-style feed application, demonstrating key DiffableUI concepts including pagination, async data loading, error handling, and performance optimization.

## Setting Up the Data Model

First, let's define our data structures:

```swift
struct Story: Identifiable, Codable {
    let id: Int
    let title: String
    let by: String
    let score: Int
    let time: Int
    let url: String?
    let descendants: Int
    
    var timeAgo: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

enum FeedState {
    case loading
    case loaded([Story])
    case error(Error)
    case loadingMore([Story])
}
```

## Creating the Feed View Controller

Build the main feed view controller:

```swift
class NewsFeedViewController: DiffableViewController {
    @State private var feedState = FeedState.loading
    @State private var currentPage = 0
    private let pageSize = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hacker News"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadStories()
    }
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        switch feedState {
        case .loading:
            LoadingSection()
            
        case .loaded(let stories), .loadingMore(let stories):
            StorySection(stories: stories)
            
            if case .loadingMore = feedState {
                LoadingMoreSection()
            }
            
        case .error(let error):
            ErrorSection(error: error) {
                self.loadStories()
            }
        }
    }
}
```

## Implementing Story Items

Create a custom item for displaying stories:

```swift
struct StoryItem: CollectionItem {
    typealias CellType = StoryCell
    typealias ItemType = Story
    
    let id: Int
    let item: Story
    let reuseIdentifier = "StoryCell"
    var onTap: (() -> Void)?
    
    init(story: Story, onTap: (() -> Void)? = nil) {
        self.id = story.id
        self.item = story
        self.onTap = onTap
    }
    
    func configure(cell: StoryCell) {
        cell.configure(with: item)
    }
    
    func didSelect() {
        onTap?()
    }
}

class StoryCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let metadataLabel = UILabel()
    private let scoreLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
        
        metadataLabel.font = .systemFont(ofSize: 12)
        metadataLabel.textColor = .secondaryLabel
        
        scoreLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        scoreLabel.textColor = .systemOrange
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            metadataLabel,
            scoreLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with story: Story) {
        titleLabel.text = story.title
        metadataLabel.text = "by \(story.by) • \(story.timeAgo) • \(story.descendants) comments"
        scoreLabel.text = "▲ \(story.score)"
    }
}
```

## Building Section Types

### Story Section

```swift
struct StorySection: CollectionSection {
    let id = "stories"
    let items: [any CollectionItem]
    
    init(stories: [Story]) {
        self.items = stories.map { story in
            StoryItem(story: story) {
                // Handle story tap
                if let url = story.url, let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1 // Separator line
        section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0)
        
        return section
    }
}
```

### Loading Section

```swift
struct LoadingSection: CollectionSection {
    let id = "loading"
    let items: [any CollectionItem]
    
    init() {
        self.items = [
            ActivityIndicator()
                .centerAligned()
                .padding(.vertical, 100)
        ]
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}
```

## Implementing Data Loading

### API Service

```swift
class HackerNewsAPI {
    static let shared = HackerNewsAPI()
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    
    func fetchTopStories() async throws -> [Int] {
        let url = URL(string: "\(baseURL)/topstories.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Int].self, from: data)
    }
    
    func fetchStory(id: Int) async throws -> Story {
        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Story.self, from: data)
    }
    
    func fetchStories(ids: [Int]) async throws -> [Story] {
        try await withThrowingTaskGroup(of: Story?.self) { group in
            for id in ids {
                group.addTask {
                    try? await self.fetchStory(id: id)
                }
            }
            
            var stories: [Story] = []
            for try await story in group {
                if let story = story {
                    stories.append(story)
                }
            }
            
            // Sort by original order
            return stories.sorted { first, second in
                ids.firstIndex(of: first.id) ?? 0 < ids.firstIndex(of: second.id) ?? 0
            }
        }
    }
}
```

### Loading Stories

```swift
extension NewsFeedViewController {
    private func loadStories() {
        Task {
            do {
                feedState = .loading
                reload()
                
                let storyIDs = try await HackerNewsAPI.shared.fetchTopStories()
                let pageIDs = Array(storyIDs.prefix(pageSize))
                let stories = try await HackerNewsAPI.shared.fetchStories(ids: pageIDs)
                
                feedState = .loaded(stories)
                reload()
            } catch {
                feedState = .error(error)
                reload()
            }
        }
    }
    
    private func loadMoreStories() {
        guard case .loaded(let currentStories) = feedState else { return }
        
        Task {
            do {
                feedState = .loadingMore(currentStories)
                reload()
                
                let storyIDs = try await HackerNewsAPI.shared.fetchTopStories()
                let startIndex = (currentPage + 1) * pageSize
                let endIndex = min(startIndex + pageSize, storyIDs.count)
                
                guard startIndex < storyIDs.count else {
                    feedState = .loaded(currentStories)
                    reload()
                    return
                }
                
                let pageIDs = Array(storyIDs[startIndex..<endIndex])
                let newStories = try await HackerNewsAPI.shared.fetchStories(ids: pageIDs)
                
                currentPage += 1
                feedState = .loaded(currentStories + newStories)
                reload()
            } catch {
                feedState = .loaded(currentStories)
                reload()
                // Show error toast
            }
        }
    }
}
```

## Adding Pagination

Implement infinite scrolling:

```swift
extension NewsFeedViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // Check if we're displaying one of the last items
        if case .loaded(let stories) = feedState,
           indexPath.item >= stories.count - 5 {
            loadMoreStories()
        }
    }
}
```

## Pull to Refresh

Add pull-to-refresh functionality:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add refresh control
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    collectionView.refreshControl = refreshControl
}

@objc private func refresh() {
    currentPage = 0
    
    Task {
        await loadStories()
        collectionView.refreshControl?.endRefreshing()
    }
}
```

## Error Handling

Create an error section:

```swift
struct ErrorSection: CollectionSection {
    let id = "error"
    let items: [any CollectionItem]
    
    init(error: Error, retry: @escaping () -> Void) {
        self.items = [
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.systemRed)
                
                Text("Failed to load stories")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondaryLabel)
                    .multilineTextAlignment(.center)
                
                Button("Try Again") {
                    retry()
                }
                .foregroundColor(.systemBlue)
            }
            .padding(32)
            .centerAligned()
        ]
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Full screen layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.8)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}
```

## Performance Optimizations

### Image Caching

If your feed includes images:

```swift
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        
        cache.setObject(image, forKey: key)
        return image
    }
}
```

### Prefetching

Implement data prefetching:

```swift
class NewsFeedViewController: DiffableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = self
    }
}

extension NewsFeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Prefetch images or data for upcoming cells
    }
}
```

## Complete Example

The complete implementation is available in the [HackerNews example project](https://github.com/loloop/DiffableUI/tree/main/Examples/HackerNews).

## Key Takeaways

1. **State Management**: Use enums to represent different feed states
2. **Async Loading**: Leverage Swift concurrency for clean async code
3. **Error Handling**: Always provide retry mechanisms
4. **Performance**: Implement caching and prefetching for smooth scrolling
5. **User Experience**: Add loading indicators and pull-to-refresh

## Next Steps

- Add search functionality
- Implement comment threads
- Add offline support with Core Data
- Create custom transitions between screens