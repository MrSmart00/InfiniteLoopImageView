//
//  InfiniteLoopImageVIewModel.swift
//  RotationBanner
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import UIKit

protocol InfiniteLoopImageViewBind {
    func receivedBindEvent(_ viewModel: InfiniteLoopImageViewModel)
}

@objcMembers class InfiniteLoopImageViewModel: NSObject {
    dynamic var imageURLList: [URL] = [URL]()
    var bindedObserver: NSKeyValueObservation?
    var currentIndex: Int = -1
    
    override init() {
        super.init()
        connection()
    }
    
    func bind(_ object: InfiniteLoopImageViewBind) {
        bindedObserver = observe(\.imageURLList, options: [.new, .old]) { (observe, change) in
            object.receivedBindEvent(self)
        }
    }
    
    func convertIndex(_ cellIndex: Int) -> Int {
        if imageURLList.count <= 1 {
            return 0
        } else {
            let cellIdx = cellIndex % imageURLList.count
            let center = imageURLList.count / 2
            var index = cellIdx - center
            if index < 0 {
                index = imageURLList.count + index
            } else if index > imageURLList.count - 1 {
                index = index - imageURLList.count
            }
            return index
        }
    }
    
    func convertCenterIndexPath(_ indexPath: IndexPath) -> IndexPath {
        var row = indexPath.row % imageURLList.count
        row += imageURLList.count
        return IndexPath(row: row, section: indexPath.section)
    }
    
    func getBannerImage(url: URL, completion:@escaping (_ url: URL, _ image: UIImage?) -> Void) {
        if let cache = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            if let cachedImage = UIImage(data: cache.data) {
                completion(url, cachedImage)
                return
            }
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            var image: UIImage? = nil
            if let imgData = data {
                image = UIImage(data: imgData)
            }
            DispatchQueue.main.async {
                return completion(url, image)
            }
        }
        task.resume()
    }
}

extension InfiniteLoopImageViewModel {
    func connection() {
        // FIXME: ここでimageURLListに入れるURL群取ってくる
    }
}
