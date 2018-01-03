//
//  Swatch.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 12/23/17.
//

import Foundation

#if os(iOS)
    import UIKit
#endif

extension Float {
    var isBasicallyZero : Bool {
        return abs(self).distance(to: 1e-12) < 0
    }
}

public class HSLConverter {
    public func hslFor(_ pixel : Pixel) -> (Float, Float, Float) {
        let rf = Float(pixel.red) / 255.0
        let gf = Float(pixel.green) / 255.0
        let bf = Float(pixel.blue) / 255.0
    
        let theMax = max(rf, max(gf, bf))
        let theMin = min(rf, min(gf, bf))
    
        let lum = (theMax + theMin) / 2
        let delta = (theMax - theMin)
        
        if delta.isZero {
            return (0, 0, lum)
        }
        
        let saturation : Float
        if lum <= 0.5 {
            saturation = delta / (theMax + theMin)
        } else {
            saturation = delta / (2 - theMax - theMin)
        }
        
        var hue : Float = 0
        let sixth : Float = 1 / 6.0
        if rf == theMax {
            hue = (sixth * ((gf - bf) / delta))
            if gf < bf { hue += 1 }
        } else if gf == theMax {
            hue = (sixth * ((bf - rf) / delta)) + (1 / 3.0)
        } else if bf == theMax {
            hue = (sixth * ((rf - gf) / delta)) + (2 / 3.0)
        }
        
        if hue < 0 {
            hue += 1
        }
        
        if hue > 1 {
            hue -= 1
        }
        
        return (hue, saturation, lum)
    }
}

/// Organize swatches into well adjusted palletes
public struct SwatchOrganizer {
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
