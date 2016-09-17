//
//  NSIndexPath+Row.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/11.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//
//

import Foundation

extension IndexPath {
    func rowPlus(_ value: Int) -> IndexPath {
        return IndexPath(row: row + value, section: section)
    }
}
