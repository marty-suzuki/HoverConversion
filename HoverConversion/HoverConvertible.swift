//
//  HoverConvertible.swift
//  HoverConversion
//
//  Created by Taiki Suzuki on 2016/07/18.
//
//

import UIKit

public protocol HoverConvertible {
    associatedtype ListType
    var displayingList: [ListType] { get set }
}