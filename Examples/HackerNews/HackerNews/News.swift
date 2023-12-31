//
//  NewsItem.swift
//  HackerNews
//
//  Created by Mauricio Cardozo on 15/12/23.
//

import DiffableUI
import Foundation
import SwiftUI

struct NewsItem: Codable, Hashable, Identifiable {
  let id: Int
  let title: String
  let points: Int?
  let user: String?
  let timeAgo: String
  let commentsCount: Int
  let url: String
  let domain: String?
}

struct News: CollectionItem {
  init(_ news: NewsItem) {
    item = news
  }

  var id: AnyHashable { item.id }
  var item: NewsItem
  var reuseIdentifier: String { "news-cell" }
  func configure(cell: NewsCell) {
    cell.title = item.title
    cell.domain = "(\(item.domain ?? ""))"
    cell.username = if let user = item.user {
      "by \(user)"
    } else { "" }
    cell.timePast = item.timeAgo
    cell.commentCount = "\(item.commentsCount) comments"
    cell.points = "\(item.points ?? 0)"
  }
}

final class NewsCell: CollectionViewCell {

  override func setUp() {
    super.setUp()
    setUpViews()
    setUpConstraints()
  }

  var title: String? {
    get { titleLabel.text }
    set { titleLabel.text = newValue }
  }

  var domain: String? {
    get { domainLabel.text }
    set { domainLabel.text = newValue }
  }

  var username: String? {
    get { usernameLabel.text }
    set { usernameLabel.text = newValue }
  }

  var timePast: String? {
    get { timeLabel.text }
    set { timeLabel.text = newValue }
  }

  var commentCount: String? {
    get { commentCountLabel.text }
    set { commentCountLabel.text = newValue }
  }

  var points: String? {
    get { pointsLabel.text }
    set { pointsLabel.text = newValue }
  }

  let titleLabel = {
    let view = UILabel()
    view.numberOfLines = 0
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .title3)
    return view
  }()

  let domainLabel = {
    let view = UILabel()
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .caption1)
    view.textColor = .secondaryLabel
    return view
  }()

  let usernameLabel = {
    let view = UILabel()
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .footnote)
    return view
  }()

  let timeLabel = {
    let view = UILabel()
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .footnote)
    return view
  }()

  let pointsArrow = {
    let view = UIImageView()
    view.image = UIImage(systemName: "triangle.fill")
    view.tintColor = .label
    return view
  }()

  let pointsLabel = {
    let view = UILabel()
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .footnote)
    return view
  }()

  let commentCountLabel = {
    let view = UILabel()
    view.adjustsFontForContentSizeCategory = true
    view.font = .preferredFont(forTextStyle: .footnote)
    return view
  }()

  func setUpViews() {
    [titleLabel, domainLabel, usernameLabel, timeLabel, pointsArrow, pointsLabel, commentCountLabel]
      .forEach {
        contentView.addSubview($0)
      }

    contentView.directionalLayoutMargins = .all(16)
    contentView.backgroundColor = .secondarySystemBackground
    contentView.layer.cornerRadius = 20
    contentView.layer.cornerCurve = .continuous
  }

  // Generated by ChatGPT!
  func setUpConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    domainLabel.translatesAutoresizingMaskIntoConstraints = false
    usernameLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    pointsArrow.translatesAutoresizingMaskIntoConstraints = false
    pointsLabel.translatesAutoresizingMaskIntoConstraints = false
    commentCountLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

      domainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      domainLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      domainLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      usernameLabel.topAnchor.constraint(equalTo: domainLabel.bottomAnchor, constant: 8),
      usernameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

      timeLabel.bottomAnchor.constraint(equalTo: commentCountLabel.topAnchor, constant: -4),
      timeLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

      pointsArrow.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
      pointsArrow.leadingAnchor.constraint(greaterThanOrEqualTo: usernameLabel.trailingAnchor),
      pointsArrow.widthAnchor.constraint(equalToConstant: 12),
      pointsArrow.heightAnchor.constraint(equalToConstant: 12),

      pointsLabel.centerYAnchor.constraint(equalTo: pointsArrow.centerYAnchor),
      pointsLabel.leadingAnchor.constraint(equalTo: pointsArrow.trailingAnchor, constant: 2),

      commentCountLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
      commentCountLabel.leadingAnchor.constraint(equalTo: pointsLabel.trailingAnchor, constant: 10),
      commentCountLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      commentCountLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
    ])
  }
}

#Preview {
  let cell = NewsCell()
  cell.title = "Not even LinkedIn is that keep on Microsoft's cloud: Shift to Azure abandoned"
  cell.domain = "(theregister.com)"
  cell.username = "by tontinton"
  cell.timePast = "1 hour ago"
  cell.commentCount = "15 comments"
  cell.points = "182"
  return cell
}
