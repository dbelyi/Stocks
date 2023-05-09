//
//  StockDetailHeaderView.swift
//  Stocks
//
//  Created by Danila Belyi on 09.05.2023.
//

import UIKit

class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    addSubviews(chartView, collectionView)
    collectionView.delegate = self
    collectionView.dataSource = self
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  override func layoutSubviews() {
    super.layoutSubviews()
    chartView.frame = CGRect(x: 0, y: 0, width: width, height: height - 100)
    collectionView.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
  }

  func configure(chartViewModel: StockChartView.ViewModel) {}

  // MARK: - CollectionView

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  )
    -> Int {
    return 0
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  )
    -> UICollectionViewCell {
    return UICollectionViewCell()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  )
    -> CGSize {
    return CGSize(width: width / 2, height: height / 3)
  }

  // MARK: - Private

  private let chartView = StockChartView()

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumInteritemSpacing = 0
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemRed
    return collectionView
  }()
}
