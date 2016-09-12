//
//  UIScrollView+BottomBounceSize.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/12.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

extension UIScrollView {
    var bottomBounceSize: CGFloat {
        if bounds.size.height < contentSize.height {
            return contentOffset.y - (contentSize.height - bounds.size.height)
        } else {
            return contentOffset.y
        }
    }
}