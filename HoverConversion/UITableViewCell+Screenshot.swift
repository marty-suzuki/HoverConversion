//
//  UITableViewCell+Screenshot.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/09/08.
//  Copyright © 2016年 marty-suzuki. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func screenshot(_ scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
