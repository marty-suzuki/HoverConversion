//
//  NSIndexPath+Row.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import Foundation

extension NSIndexPath {
    func rowPlus(value: Int) -> NSIndexPath {
        return NSIndexPath(forRow: row + value, inSection: section)
    }
}