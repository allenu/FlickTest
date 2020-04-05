//
//  Colors.swift
//  FlickTest
//
//  Created by Allen Ussher on 4/5/20.
//  Copyright © 2020 Ussher Press. All rights reserved.
//

import AppKit

func HexColor(from hexValue: Int64) -> NSColor {
    let red: CGFloat = CGFloat((hexValue & 0xff0000) >> 16) / 255.0
    let green: CGFloat = CGFloat((hexValue & 0x00ff00) >> 8) / 255.0
    let blue: CGFloat = CGFloat(hexValue & 0x0000ff) / 255.0
    
    let color = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    return color
}

struct Colors {
    static let contentArea = HexColor(from: 0xf2f2ec)
    static let contentAreaLightText = HexColor(from: 0xa69980)
    static let contentAreaLightButton = HexColor(from: 0x885533)
    static let bottomCard = HexColor(from: 0x889eae)
    static let cardText = HexColor(from: 0xffddae)
}
