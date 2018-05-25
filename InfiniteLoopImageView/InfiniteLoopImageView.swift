//
//  InfiniteLoopImageView.swift
//  RotationBanner
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import UIKit

protocol InfiniteLoopImageDelegate : class {
    func rotationBanner(_ view: InfiniteLoopImageView, tappedIndexPath: IndexPath)
}

private class ImageCell: UICollectionViewCell {
    
    fileprivate var image: UIImage? {
        get {
            return imageView?.image
        }
        set {
            imageView?.image = newValue
        }
    }
    private var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        imageView = UIImageView(frame: frame)
        if let iv = imageView {
            iv.contentMode = .scaleAspectFill
            contentView.addSubview(iv)
            
            iv.translatesAutoresizingMaskIntoConstraints = false
            var viewConstraints = [NSLayoutConstraint]()
            viewConstraints.append(NSLayoutConstraint(item: iv, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: iv, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: iv, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: iv, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
            contentView.addConstraints(viewConstraints)
        }
    }
}

class InfiniteLoopImageView: UIView {
    
    private var timer: Timer? = nil
    private var collection: UICollectionView?
    private var needsCentering = false
    
    private let viewModel: InfiniteLoopImageViewModel = InfiniteLoopImageViewModel()
    
    var rotationInterval: TimeInterval = 5
    weak var delegate: InfiniteLoopImageDelegate?
    private var indexChangeObserver: NSKeyValueObservation?
    init(_ frame: CGRect, layout: UICollectionViewFlowLayout) {
        super.init(frame: frame)
        setup(frame, layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(self.frame, UICollectionViewFlowLayout())
    }
    
    private func setup(_ frame: CGRect, _ layout: UICollectionViewFlowLayout) {
        viewModel.bind(self)
        collection = UICollectionView(frame: frame, collectionViewLayout: layout)
        if let collectionView = collection {
            if collectionView.frame.size.width != layout.itemSize.width {
                needsCentering = true
            } else {
                collectionView.isPagingEnabled = true
            }
            collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
            collectionView.backgroundColor = .clear
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.scrollsToTop = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            addSubview(collectionView)
            
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            var viewConstraints = [NSLayoutConstraint]()
            viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
            viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
            addConstraints(viewConstraints)
        }
    }
    
    private func startAutoRotation() {
        if isUserInteractionEnabled && !isHidden && timer == nil {
            timer = Timer.scheduledTimer(timeInterval: rotationInterval,
                                         target: self,
                                         selector: #selector(nextItem),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    private func stopAutoRotation() {
        if let tm = timer, tm.isValid {
            tm.invalidate()
        }
        timer = nil
    }
    
    @objc private func nextItem() {
        if viewModel.imageURLList.count < 2 {
            return
        }
        
        if let vc = (self as UIView).il.parentViewController() {
            if vc.il.isVisible() {
                collection?.scrollToItem(at: IndexPath(row: viewModel.currentIndex + 1, section: 0),
                                         at: .centeredHorizontally,
                                         animated: true)
                return
            }
        }
        stopAutoRotation()
    }
}

extension InfiniteLoopImageView: InfiniteLoopImageViewBind {
    func receivedBindEvent(_ viewModel: InfiniteLoopImageViewModel) {
        collection?.reloadData()
        let centerIndex = viewModel.convertCenterIndexPath(IndexPath(row: viewModel.imageURLList.count / 2, section: 0))
        collection?.scrollToItem(at: centerIndex, at: .centeredHorizontally, animated: false)
        viewModel.currentIndex = centerIndex.row
        startAutoRotation()
    }
}

extension InfiniteLoopImageView: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoRotation()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, !needsCentering {
            endScroll(scrollView, update: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endScroll(scrollView, update: false)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        endScroll(scrollView, update: false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if needsCentering {
            let layout = collection!.collectionViewLayout as! UICollectionViewFlowLayout
            let pageWidth = layout.itemSize.width
            let currentOffset = scrollView.contentOffset.x
            var newTargetOffset: CGFloat
            let diff = (scrollView.frame.size.width - layout.itemSize.width) / 2
            
            let current: CGFloat
            if targetContentOffset.pointee.x > currentOffset {
                current = ceil(currentOffset / pageWidth)
            } else {
                current = floor(currentOffset / pageWidth)
            }
            newTargetOffset = current * pageWidth - diff
            
            if newTargetOffset < 0 {
                newTargetOffset = 0
            } else if (newTargetOffset > scrollView.contentSize.width){
                newTargetOffset = scrollView.contentSize.width
            }
            
            targetContentOffset.pointee.x = CGFloat(currentOffset)
            scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)
        }
    }
    
    private func endScroll(_ scrollView: UIScrollView, update: Bool) {
        if update {
            return
        }
        let collectionView = scrollView as! UICollectionView
        let cx = scrollView.contentOffset.x + scrollView.frame.size.width / 2
        let center = CGPoint(x: cx, y: scrollView.frame.size.height / 2)
        var centerCell: UICollectionViewCell? = nil
        collectionView.visibleCells.forEach { (cell) in
            if cell.frame.contains(center) {
                centerCell = cell
            }
        }
        if let cell = centerCell {
            collectionView.delegate = nil
            let indexPath = collectionView.indexPath(for: cell)
            let moveTo = viewModel.convertCenterIndexPath(indexPath!)
            collectionView.scrollToItem(at: moveTo, at: .centeredHorizontally, animated: false)
            collectionView.delegate = self
            viewModel.currentIndex = moveTo.row
        }
        startAutoRotation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let dl = delegate {
            let index = IndexPath(row: viewModel.convertIndex(indexPath.row), section: indexPath.section)
            dl.rotationBanner(self, tappedIndexPath: index)
        }
    }
}

extension InfiniteLoopImageView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageURLList.count * 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let index = viewModel.convertIndex(indexPath.row)
        let url = viewModel.imageURLList[index]
        cell.image = nil
        viewModel.getBannerImage(url: url) { (loadedURL, image) in
            if url == loadedURL {
                cell.image = image
            }
        }
        return cell
    }
    
}
