//
//  Pixel.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import Foundation

/// Represents a 24-bit color in RGB space. Each channel is out of 255.
public struct Pixel : RawRepresentable, Hashable, Equatable {
    public typealias RawValue = Int
    public typealias SubValue = Int
    
    /// Bits used to encode the subvalue in the rawvalue
    public static let sigfigs : SubValue = 8
    /// Max number allowed for the given sigfigs
    public static let digitFullOfOnesUpToSigfigs = SubValue(pow(2, Double(Pixel.sigfigs))) - 1
    
    // - MARK: Channels
    /// Red channel value [0-255]
    public let red : SubValue
    /// Green channel value [0-255]
    public let green : SubValue
    /// Blue channel value [0-255]
    public let blue : SubValue
    
    // - MARK: Computed
    /// The 24-bit encoded value representing all 3 channels.
    public let rawValue : RawValue
    /// Normally set to `rawValue`
    public let hashValue : Int
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
    // - MARK: Initializers
    /// Initialize a new pixel with the given `red`, `blue`, and `green` channels out of 255.
    public init(red : SubValue, green : SubValue, blue : SubValue) {
        self.red = red
        self.green = green
        self.blue = blue
        self.rawValue = (red << (2*Pixel.sigfigs)) + (green << Pixel.sigfigs) + blue
        self.hashValue = self.rawValue
    }
    
    /// Unmarshal a `rawValue` into it's 3 encoded channels
    public init?(rawValue: RawValue) {
        red   = Pixel.pushAndPullValue(base: rawValue, index: 2)
        green = Pixel.pushAndPullValue(base: rawValue, index: 1)
        blue  = Pixel.pushAndPullValue(base: rawValue, index: 0)
        self.rawValue = (red << (2*Pixel.sigfigs)) + (green << Pixel.sigfigs) + blue
        self.hashValue = self.rawValue
    }
    
    
    /// This is a private version used internally for performance gains.
    /// - Warning: DO NOT USE
    /// - Note: DO NOT USE
    public init(red : SubValue, green : SubValue, blue : SubValue, rawValue : RawValue) {
        self.red = red
        self.green = green
        self.blue = blue
        self.rawValue = rawValue
        self.hashValue = rawValue
    }
    
    
    /// Extract an index from an encoded rawValue
    ///
    /// - Note: `RawValue` is encoded as rgb so red is at the 2nd index.
    /// - Parameters:
    ///   - base: the `RawValue` to extract from
    ///   - index: which channel to extract
    /// - Returns: The subvalue represented in index
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
