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
    
    /// Convert hsl to rgb
    ///
    /// - Remark: If hue were an int then `secondComponent`
    ///   would be identity but important to see it's a float.
    /// - ToDo: Clean up calculation to be more clear
    ///
    /// - Parameters:
    ///   - hue: (0, 1)
    ///   - saturation: (0, 1)
    ///   - lumience: (0, 1) same as lightness
    /// - Returns: A Pixel of rgb (0, 255)
    func pixelFor(hue : Float, saturation : Float, lumience : Float) -> Pixel {
        if (lumience >= 1) { return Pixel(red: 255, green: 255, blue: 255) }
        if (lumience <= 0) { return Pixel(red: 0, green: 0, blue: 0) }
        
        let chroma = 1.0 - abs((2 * lumience) - 1.0) * saturation
        let hueSextant = Int((hue * 6).rounded(.down))
        
        let secondComponentWeight = 1.0 - ((hue * 6.0).remainder(dividingBy: 2.0) - 1.0).magnitude
        let secondComponent = chroma * secondComponentWeight
        
        let red : Float
        let green : Float
        let blue : Float
        switch hueSextant {
        case 0:
            red = chroma
            green = secondComponent
            blue = 0
        case 1:
            red = secondComponent
            green = chroma
            blue = 0
        case 2:
            red = 0
            green = chroma
            blue = secondComponent
        case 3:
            red = 0
            green = secondComponent
            blue = chroma
        case 4:
            red = secondComponent
            green = 0
            blue = chroma
        case 5:
            red = chroma
            green = 0
            blue = secondComponent
        default:
            fatalError("Not possible but Swift doesn't know that")
        }
        
        let lumienceAdjustment = lumience - (chroma / 2)
        let finalRed = Int((red + lumienceAdjustment) * 255)
        let finalGreen = Int((green + lumienceAdjustment) * 255)
        let finalBlue = Int((blue + lumienceAdjustment) * 255)
        return Pixel(red: finalRed, green: finalGreen, blue: finalBlue)
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
