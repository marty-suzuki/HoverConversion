//
//  UITableViewCell+Screenshot.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/08.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func screenshot(scale: CGFloat = UIScreen.mainScreen().scale) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
