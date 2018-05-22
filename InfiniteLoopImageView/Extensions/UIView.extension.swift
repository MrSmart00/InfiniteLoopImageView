//
//  UIView.extension.swift
//  InfinitLoopImageView
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import Foundation

extension UIView : ILExtensionCompatible { }

extension ILExtension where Base == UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = base
        while responder != nil {
            let res = responder!
            if res is UIViewController {
                return (res as! UIViewController)
            } else {
                responder = responder?.next
            }
        }
        return nil
    }
}
