//
//  Pixel.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import Foundation

/// Represents a 24-bit color in RGB space.
public struct Pixel : RawRepresentable, Hashable, Equatable {
    public typealias RawValue = Int
    public typealias SubValue = Int
    
    /// Bits used to encode the subvalue in the rawvalue
    public static let sigfigs : SubValue = 8
    /// Max number allowed for the given sigfigs
    public static let digitFullOfOnesUpToSigfigs = SubValue(pow(2, Double(Pixel.sigfigs))) - 1
    
    /// Red channel value
    public let red : SubValue
    /// Green channel value
    public let green : SubValue
    /// Blue channel value
    public let blue : SubValue
    
    public init(red : SubValue, green : SubValue, blue : SubValue) {
        self.red = red
        self.green = green
        self.blue = blue
        self.rawValue = (red << (2*Pixel.sigfigs)) + (green << Pixel.sigfigs) + blue
        self.hashValue = self.rawValue
    }
    // 28740809174
    
    public init?(rawValue: RawValue) {
        red   = Pixel.pushAndPullValue(base: rawValue, index: 2)
        green = Pixel.pushAndPullValue(base: rawValue, index: 1)
        blue  = Pixel.pushAndPullValue(base: rawValue, index: 0)
        self.rawValue = (red << (2*Pixel.sigfigs)) + (green << Pixel.sigfigs) + blue
        self.hashValue = self.rawValue
    }
    
    
    /// This is a private version used internally for performance gains.
    /// - Note: DO NOT USE
    public init(red : SubValue, green : SubValue, blue : SubValue, rawValue : RawValue) {
        self.red = red
        self.green = green
        self.blue = blue
        self.rawValue = rawValue
        self.hashValue = rawValue
    }
    
    public let rawValue : RawValue
    
    public let hashValue : Int
    
    public static func pushAndPullValue(base : RawValue, index : RawValue) -> SubValue {
        let howMuchToMove = index * Pixel.sigfigs
        return (base & (Pixel.digitFullOfOnesUpToSigfigs << howMuchToMove)) >> howMuchToMove
    }
}

extension Pixel : CustomStringConvertible {
    public var description : String {
        return "rgb(\(red), \(green), \(blue))"
    }
}

extension Pixel : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "rgb(\(red), \(green), \(blue), max: \(Pixel.digitFullOfOnesUpToSigfigs))"
    }
}
