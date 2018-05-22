//
//  Base.extension.swift
//  InfinitLoopImageView
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import Foundation

public final class ILExtension<Base> {
    let base: Base
    public init(base: Base) {
        self.base = base
    }
}

public protocol ILExtensionCompatible {
    associatedtype ILExtensionType
    static var il: ILExtensionType.Type { get }
    var il: ILExtensionType { get }
}

public extension ILExtensionCompatible {
    
    public static var il: ILExtension<Self>.Type {
        return ILExtension<Self>.self
    }
    
    public var il: ILExtension<Self> {
        return ILExtension(base: self)
    }
}
