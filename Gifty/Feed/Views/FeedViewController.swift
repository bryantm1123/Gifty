//
//  FeedViewController.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import UIKit

class FeedViewController: UICollectionViewController {
    
    private let reuseIdentifier = "GifCell"
    private let sectionInsets = UIEdgeInsets(
      top: 50.0,
      left: 20.0,
      bottom: 50.0,
      right: 20.0)
    private let itemsPerRow: CGFloat = 2
    
    // TODO: Replace with real data
    let items: [Int] = [1,2,3,4,5,6,7,9,10]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

}

// MARK: DataSource
extension FeedViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
      }
      
      // 2
      override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
      ) -> Int {
        return items.count
      }
      
      // 3
      override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
      ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: reuseIdentifier,
          for: indexPath)
        cell.backgroundColor = .black
        // Configure the cell
        return cell
      }
}

// MARK: Flow Layout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      
      return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      insetForSectionAt section: Int
    ) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
      return sectionInsets.left
    }
}
