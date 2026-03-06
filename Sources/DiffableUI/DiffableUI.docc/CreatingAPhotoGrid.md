# Creating a Photo Grid

Build a responsive photo grid with selection, zooming, and sharing capabilities.

## Overview

This tutorial demonstrates how to create a photo grid similar to the iOS Photos app, featuring responsive layouts, multi-selection, batch operations, and smooth animations.

## Setting Up the Photo Model

Define the photo data structure:

```swift
struct Photo: Identifiable {
    let id = UUID()
    let image: UIImage
    let thumbnail: UIImage
    let createdAt: Date
    let location: String?
    
    static func generateThumbnail(from image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

struct Album {
    let id = UUID()
    let name: String
    var photos: [Photo]
    let coverPhoto: Photo?
}
```

## Creating the Grid Layout

Build an adaptive grid that responds to device orientation:

```swift
struct PhotoGridSection: CollectionSection {
    let id = "photo-grid"
    let photos: [Photo]
    let selectedIDs: Set<UUID>
    let onPhotoTap: (Photo) -> Void
    let onPhotoLongPress: (Photo) -> Void
    
    var items: [any CollectionItem] {
        photos.map { photo in
            PhotoGridItem(
                photo: photo,
                isSelected: selectedIDs.contains(photo.id),
                onTap: { onPhotoTap(photo) },
                onLongPress: { onPhotoLongPress(photo) }
            )
        }
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Calculate columns based on container width
        let containerWidth = environment.container.contentSize.width
        let minItemWidth: CGFloat = 100
        let spacing: CGFloat = 2
        
        let columns = max(1, Int(containerWidth / minItemWidth))
        let itemWidth = (containerWidth - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemWidth) // Square items
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemWidth)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: columns
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        
        return section
    }
}
```

## Photo Grid Item

Create a custom item for photos with selection support:

```swift
struct PhotoGridItem: CollectionItem {
    typealias CellType = PhotoGridCell
    typealias ItemType = Photo
    
    let id: UUID
    let item: Photo
    let isSelected: Bool
    let reuseIdentifier = "PhotoGridCell"
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    init(photo: Photo, isSelected: Bool, onTap: @escaping () -> Void, onLongPress: @escaping () -> Void) {
        self.id = photo.id
        self.item = photo
        self.isSelected = isSelected
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
    
    func configure(cell: PhotoGridCell) {
        cell.configure(with: item, isSelected: isSelected)
    }
    
    func didSelect() {
        onTap()
    }
    
    func setBehaviors(cell: PhotoGridCell) {
        let longPress = UILongPressGestureRecognizer(
            target: cell,
            action: #selector(cell.handleLongPress)
        )
        longPress.minimumPressDuration = 0.5
        cell.addGestureRecognizer(longPress)
        cell.onLongPress = onLongPress
    }
}

class PhotoGridCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let selectionOverlay = UIView()
    private let checkmarkImageView = UIImageView()
    var onLongPress: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Image view
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Selection overlay
        selectionOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        selectionOverlay.alpha = 0
        
        // Checkmark
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.alpha = 0
        
        // Layout
        [imageView, selectionOverlay, checkmarkImageView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            selectionOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with photo: Photo, isSelected: Bool) {
        imageView.image = photo.thumbnail
        
        UIView.animate(withDuration: 0.2) {
            self.selectionOverlay.alpha = isSelected ? 1 : 0
            self.checkmarkImageView.alpha = isSelected ? 1 : 0
        }
    }
    
    @objc func handleLongPress() {
        onLongPress?()
    }
}
```

## Photo Grid View Controller

Implement the main view controller with selection modes:

```swift
class PhotoGridViewController: DiffableViewController {
    enum Mode {
        case viewing
        case selecting
    }
    
    @State private var photos: [Photo] = []
    @State private var mode = Mode.viewing
    @State private var selectedPhotoIDs = Set<UUID>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        setupNavigationBar()
        loadPhotos()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(toggleSelectionMode)
        )
    }
    
    @objc private func toggleSelectionMode() {
        switch mode {
        case .viewing:
            enterSelectionMode()
        case .selecting:
            exitSelectionMode()
        }
    }
    
    private func enterSelectionMode() {
        mode = .selecting
        selectedPhotoIDs.removeAll()
        
        navigationItem.rightBarButtonItem?.title = "Cancel"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Select All",
            style: .plain,
            target: self,
            action: #selector(selectAll)
        )
        
        updateToolbar()
        reload()
    }
    
    private func exitSelectionMode() {
        mode = .viewing
        selectedPhotoIDs.removeAll()
        
        navigationItem.rightBarButtonItem?.title = "Select"
        navigationItem.leftBarButtonItem = nil
        navigationController?.setToolbarHidden(true, animated: true)
        
        reload()
    }
    
    @CollectionViewBuilder
    override var sections: [any CollectionSection] {
        PhotoGridSection(
            photos: photos,
            selectedIDs: selectedPhotoIDs,
            onPhotoTap: { [weak self] photo in
                self?.handlePhotoTap(photo)
            },
            onPhotoLongPress: { [weak self] photo in
                self?.handlePhotoLongPress(photo)
            }
        )
    }
}
```

## Selection Handling

Implement photo selection logic:

```swift
extension PhotoGridViewController {
    private func handlePhotoTap(_ photo: Photo) {
        switch mode {
        case .viewing:
            showPhotoDetail(photo)
        case .selecting:
            togglePhotoSelection(photo)
        }
    }
    
    private func handlePhotoLongPress(_ photo: Photo) {
        guard mode == .viewing else { return }
        
        // Enter selection mode and select the long-pressed photo
        enterSelectionMode()
        togglePhotoSelection(photo)
    }
    
    private func togglePhotoSelection(_ photo: Photo) {
        if selectedPhotoIDs.contains(photo.id) {
            selectedPhotoIDs.remove(photo.id)
        } else {
            selectedPhotoIDs.insert(photo.id)
        }
        
        updateToolbar()
        reload()
    }
    
    @objc private func selectAll() {
        if selectedPhotoIDs.count == photos.count {
            // Deselect all
            selectedPhotoIDs.removeAll()
            navigationItem.leftBarButtonItem?.title = "Select All"
        } else {
            // Select all
            selectedPhotoIDs = Set(photos.map { $0.id })
            navigationItem.leftBarButtonItem?.title = "Deselect All"
        }
        
        updateToolbar()
        reload()
    }
}
```

## Toolbar Actions

Add batch operations toolbar:

```swift
extension PhotoGridViewController {
    private func updateToolbar() {
        guard mode == .selecting else {
            navigationController?.setToolbarHidden(true, animated: true)
            return
        }
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareSelectedPhotos)
        )
        shareButton.isEnabled = !selectedPhotoIDs.isEmpty
        
        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteSelectedPhotos)
        )
        deleteButton.isEnabled = !selectedPhotoIDs.isEmpty
        deleteButton.tintColor = .systemRed
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let countLabel = UILabel()
        countLabel.text = "\(selectedPhotoIDs.count) selected"
        countLabel.font = .systemFont(ofSize: 16)
        let countItem = UIBarButtonItem(customView: countLabel)
        
        toolbarItems = [shareButton, flexibleSpace, countItem, flexibleSpace, deleteButton]
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @objc private func shareSelectedPhotos() {
        let selectedPhotos = photos.filter { selectedPhotoIDs.contains($0.id) }
        let images = selectedPhotos.map { $0.image }
        
        let activityController = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
        present(activityController, animated: true)
    }
    
    @objc private func deleteSelectedPhotos() {
        let alert = UIAlertController(
            title: "Delete \(selectedPhotoIDs.count) Photos?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.photos.removeAll { self.selectedPhotoIDs.contains($0.id) }
            self.exitSelectionMode()
        })
        
        present(alert, animated: true)
    }
}
```

## Photo Detail View

Create a detail view with zooming:

```swift
class PhotoDetailViewController: UIViewController {
    private let photo: Photo
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupImageView()
        setupGestures()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupImageView() {
        imageView.image = photo.image
        imageView.contentMode = .scaleAspectFit
        
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupGestures() {
        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let point = gesture.location(in: imageView)
            let rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
            scrollView.zoom(to: rect, animated: true)
        }
    }
}

extension PhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
```

## Performance Optimizations

### Thumbnail Generation

Generate thumbnails efficiently:

```swift
class PhotoThumbnailGenerator {
    static let shared = PhotoThumbnailGenerator()
    private let thumbnailCache = NSCache<NSString, UIImage>()
    
    func thumbnail(for photo: Photo, size: CGSize) async -> UIImage {
        let key = "\(photo.id)-\(size.width)x\(size.height)" as NSString
        
        if let cached = thumbnailCache.object(forKey: key) {
            return cached
        }
        
        let thumbnail = await generateThumbnail(from: photo.image, size: size)
        thumbnailCache.setObject(thumbnail, forKey: key)
        
        return thumbnail
    }
    
    private func generateThumbnail(from image: UIImage, size: CGSize) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = UIGraphicsImageRenderer(size: size)
                let thumbnail = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: size))
                }
                continuation.resume(returning: thumbnail)
            }
        }
    }
}
```

### Memory Management

Handle large photo collections:

```swift
class PhotoGridViewController: DiffableViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear thumbnail cache
        PhotoThumbnailGenerator.shared.clearCache()
    }
}
```

## Key Features Implemented

1. **Responsive Grid**: Adapts to device orientation and screen size
2. **Multi-Selection**: Long press to enter selection mode
3. **Batch Operations**: Share and delete multiple photos
4. **Photo Viewing**: Full-screen photo with pinch-to-zoom
5. **Performance**: Efficient thumbnail generation and caching

## Next Steps

- Add photo filtering and sorting
- Implement album organization
- Add photo editing capabilities
- Create custom transitions
- Add iCloud Photo Library support