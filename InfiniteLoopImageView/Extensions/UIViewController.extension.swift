//
//  UIViewController.extension.swift
//  InfinitLoopImageView
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import UIKit

extension UIViewController : ILExtensionCompatible { }

extension ILExtension where Base == UIViewController {
    fileprivate static func findVisibleViewController(viewController: UIViewController) -> UIViewController {
        
        if let presentedVC = viewController.presentedViewController {
            return self.findVisibleViewController(viewController:presentedVC)
        } else if viewController is UISplitViewController {
            let svc = viewController as! UISplitViewController
            if svc.viewControllers.count > 0 {
                if let lastVC = svc.viewControllers.last {
                    return self.findVisibleViewController(viewController:lastVC)
                }
            }
        } else if viewController is UINavigationController {
            let nvc = viewController as! UINavigationController
            if nvc.viewControllers.count > 0 {
                if let topVC = nvc.topViewController {
                    return self.findVisibleViewController(viewController:topVC)
                }
            }
        } else if viewController is UITabBarController {
            let tbc = viewController as! UITabBarController
            if let viewControllers = tbc.viewControllers {
                if viewControllers.count > 0 {
                    if let selectVC = tbc.selectedViewController {
                        return self.findVisibleViewController(viewController:selectVC)
                    }
                }
            }
        }
        return viewController
    }
    
    static func currentTopViewController() -> UIViewController? {
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        return self.findVisibleViewController(viewController: rootVC)
    }
    
    func isVisible() -> Bool {
        var visible = false
        if let parentVC = base.view.il.parentViewController() {
            if let currentVC = UIViewController.il.currentTopViewController() {
                if currentVC.isEqual(parentVC) {
                    visible = true
                } else {
                    currentVC.childViewControllers.forEach({ (childVC) in
                        if childVC.isEqual(parentVC) {
                            let point = childVC.view.convert(childVC.view.frame.origin, to: currentVC.view)
                            if point.x == 0 {
                                visible = true
                                return
                            }
                        }
                    })
                }
            }
        }
        return visible
    }
}

