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
    private var mMemoryCacheImages: [URL : UIImage] = [URL : UIImage]()
    private let cacheDirectoryPath: String?
    dynamic var imageURLList: [URL] = [URL]()
    var bindedObserver: NSKeyValueObservation?
    var currentIndex: Int = -1
    
    override init() {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        if let first = pathes.first {
            let nsPath = NSString(string: first)
            cacheDirectoryPath = nsPath.appendingPathComponent("imagecache")
        } else {
            cacheDirectoryPath = nil
        }
        super.init()
        
        initializeCache()
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
        if let image = mMemoryCacheImages[url] {
            return completion(url, image)
        }
        if let image = cachedImageWithURL(url: url) {
            return completion(url, image)
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            if let weakSelf = self {
                var image: UIImage? = nil
                if let imgData = data {
                    image = UIImage(data: imgData)
                    if image == nil {
                        weakSelf.mMemoryCacheImages.updateValue(image!, forKey: url)
                        if let cachePath = weakSelf.cacheDirectoryPath {
                            let filepath = NSString(string: cachePath).appendingPathComponent(url.absoluteString.il.encodeURL())
                            do {
                                try imgData.write(to: URL(fileURLWithPath: filepath))
                            } catch {
                                
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    return completion(url, image)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func initializeCache() {
        //        var result = [Dictionary]()
        let fm = FileManager.default
        if let path = cacheDirectoryPath {
            do {
                var isDirectory: ObjCBool = false
                if !fm.fileExists(atPath: path, isDirectory: &isDirectory) {
                    try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                }
                
                //                let pathlist = try fm.contentsOfDirectory(atPath: path)
                //                for (_, element) in pathlist.enumerated() {
                //                    if let filePath: String = NSString(string: path).appendingPathComponent(element) {
                //                        let attributes = try fm.attributesOfItem(atPath: filePath)
                //
                //                    }
                //                }
            } catch {
                
            }
        }
        //        if result.count > 20 {
        //            let sort: NSSortDescriptor = NSSortDescriptor(key: FileAttributeKey.creationDate.rawValue, ascending: true)
        //        }
    }
    
    fileprivate func cachedImageWithURL(url: URL) -> UIImage? {
        if let path = cacheDirectoryPath {
            if let cachedImage = mMemoryCacheImages[url] {
                return cachedImage
            } else {
                let filePath = NSString(string: path).appendingPathComponent(url.absoluteString.il.encodeURL())
                if let fileImage = UIImage(contentsOfFile: filePath) {
                    mMemoryCacheImages.updateValue(fileImage, forKey: url)
                    return fileImage
                }
            }
        }
        return nil
    }

}

extension InfiniteLoopImageViewModel {
    func connection() {
        // FIXME: ここでimageURLListに入れるURL群取ってくる
    }
}
