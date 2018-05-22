//
//  String.extension.swift
//  InfinitLoopImageView
//
//  Created by Hinomori Hiroya on 2018/05/22.
//  Copyright © 2018年 Hinomori Hiroya. All rights reserved.
//

import Foundation

extension String : ILExtensionCompatible { }

extension ILExtension where Base == String {
    func encodeURL() -> String {
        guard let encode = base.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return base
        }
        return encode
    }
    
    func decodeURL() -> String {
        guard let decode = base.removingPercentEncoding else {
            return base
        }
        return decode
    }
}

