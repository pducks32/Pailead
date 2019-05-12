//
//  Swatch.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 12/23/17.
//

import Foundation
import CoreGraphics

extension Float {
    var isBasicallyZero : Bool {
        return abs(self).distance(to: 1e-12) < 0
    }
}

public struct Swatch {
    
    public var color : Color {
        let red = CGFloat(pixel.red) / 255
        let green = CGFloat(pixel.green) / 255
        let blue = CGFloat(pixel.blue) / 255
        
        return Color(red: red, green: green, blue: blue, alpha: 1)
    }
    
    public var pixel : Pixel
    public var count : Int
    
    public init(_ pixel : Pixel, count : Int) {
        self.pixel = pixel
        self.count = count
    }
}

extension Swatch : CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook : PlaygroundQuickLook {
        return .color(color)
    }
}

extension Swatch : Equatable {
    public static func ==(lhs: Swatch, rhs: Swatch) -> Bool {
        return lhs.pixel == rhs.pixel
    }
}

extension Swatch : Hashable {
    public var hashValue : Int {
        return pixel.hashValue
    }
}
