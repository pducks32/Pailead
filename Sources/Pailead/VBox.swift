//
//  VBox.swift
//  Pailead
//
//  Created by Patrick Metcalfe on 11/20/17.
//

import Foundation

public class VBox : Hashable {
    public static func ==(lhs: VBox, rhs: VBox) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public enum Axis : CustomStringConvertible {
        public static let all : [Axis] = [.red, .green, .blue]
        case red, green, blue
        
        public var description : String {
            switch self {
            case .red: return "red"
            case .green: return "green"
            case .blue: return "blue"
            }
        }
    }
    
    public var hashValue: Int {
        return minPixel.rawValue ^ maxPixel.rawValue
    }
    
    /// The superposition of **minimum** subvaues in each dimension
    public var minPixel : Pixel
    /// The superposition of **maximum** subvaues in each dimension
    public var maxPixel : Pixel
    /// The pixels that lie within the vbox
    public var contents : [Pixel : Int] = [:]
    
    //// The volume in rgb space that the vbox occupies
    public var volume : Pixel.SubValue {
        return redExtent * greenExtent * blueExtent
    }
    
    
    /// Create a new VBox with contents
    ///
    /// - Parameters:
    ///   - min: The minimum possible pixel
    ///   - max: The maximum possible pixel
    ///   - contents: The pixels and their frequencies
    public init(min : Pixel, max : Pixel, contents : [Pixel: Int]) {
        self.minPixel = min
        self.maxPixel = max
        self.contents = contents
    }
    
    
    /// Create a new VBox and calculate min and max pixels
    ///
    /// - Parameter pixels: The pixels and their frequencies
    public init(pixels : [Pixel : Int]) {
        var redMin   : Pixel.SubValue = 256
        var greenMin : Pixel.SubValue = 256
        var blueMin  : Pixel.SubValue = 256
        var redMax   : Pixel.SubValue = 0
        var greenMax : Pixel.SubValue = 0
        var blueMax  : Pixel.SubValue = 0
        
        pixels.keys.forEach { pixel in
            if pixel.blue < blueMin {
                blueMin = pixel.blue
            }
            if pixel.green < greenMin {
                greenMin = pixel.green
            }
            if pixel.red < redMin {
                redMin = pixel.red
            }
            
            if pixel.blue > blueMax {
                blueMax = pixel.blue
            }
            if pixel.green > greenMax {
                greenMax = pixel.green
            }
            if pixel.red > redMax {
                redMax = pixel.red
            }
        }
        self.minPixel = Pixel(red: redMin, green: greenMin, blue: blueMin)
        self.maxPixel = Pixel(red: redMax, green: greenMax, blue: blueMax)
        self.contents = pixels
    }
    
    
    /// Create a new Vbox and calculate the pixel frequencies and min/max pixels
    ///
    /// - Parameter pixels: All pixels in the vbox
    public init(pixels : [Pixel]) {
        var redMin   : Pixel.SubValue = 256
        var greenMin : Pixel.SubValue = 256
        var blueMin  : Pixel.SubValue = 256
        var redMax   : Pixel.SubValue = 0
        var greenMax : Pixel.SubValue = 0
        var blueMax  : Pixel.SubValue = 0
        var contents : [Pixel: Int] = [:]
        contents.reserveCapacity(pixels.count)
        
        pixels.forEach { pixel in
            if pixel.blue < blueMin {
                blueMin = pixel.blue
            }
            if pixel.green < greenMin {
                greenMin = pixel.green
            }
            if pixel.red < redMin {
                redMin = pixel.red
            }
            
            if pixel.blue > blueMax {
                blueMax = pixel.blue
            }
            if pixel.green > greenMax {
                greenMax = pixel.green
            }
            if pixel.red > redMax {
                redMax = pixel.red
            }
            contents[pixel] = (contents[pixel] ?? 0) + 1
        }
        
        self.minPixel = Pixel(red: redMin, green: greenMin, blue: blueMin)
        self.maxPixel = Pixel(red: redMax, green: greenMax, blue: blueMax)
        self.contents = contents
    }

    /// If the box has room to actually split.
    public var canSplit : Bool {
        return volume >= 2
    }
    
    /// Split the vbox into 2 equally populated vboxes
    ///
    /// - Todo: Calculate min and max so double loop won't be needed.
    /// - Returns: The two vboxes
    public func split() -> (VBox, VBox) {
        
        // How the fuck do I do this. A partition?
        let dimension = longestDimension
        let splitPoint = median(along: dimension)
        
        var smaller = [Pixel : Int]()
        var larger  = [Pixel : Int]()
        contents.forEach { (lineItem) in
            if lineItem.key[dimension] < splitPoint {
                smaller[lineItem.key] = lineItem.value
            } else {
                larger[lineItem.key] = lineItem.value
            }
        }
        return (VBox(pixels: smaller), VBox(pixels: larger))
    }
    
    /// Calculate the median point at which point there is an equal
    /// number of points on both sides of the split.
    ///
    /// - Parameter dimension: The dimension to split against
    /// - Returns: The median subvalue
    public func median(along dimension : Axis) -> Pixel.SubValue {
        var totalSum = 0
        
        let lengthOfLongest = length(along: dimension)
        
        var slicesSums : [Int] = [Int](repeating: 0, count: lengthOfLongest + 1)
        let minDimension = inital(in: dimension)
        contents.forEach { (swatch) in
            let (pixel, population) = swatch
            let redIndex = pixel[dimension] - minDimension
            slicesSums[Int(redIndex)] += population
        }
        
        var thingToAddToNext = 0
        for (index, slicePopulation) in slicesSums.enumerated() {
            thingToAddToNext += slicePopulation
            slicesSums[index] = thingToAddToNext
        }
        totalSum = slicesSums.last!
        
        let halfTotal = totalSum / 2
        
        
        // Possibility that first slice contains the majority of values
        if slicesSums[0] >= halfTotal {
            return inital(in: dimension) + 1
        }
        
        for index in slicesSums.indices.dropLast() {
            let current = slicesSums[index]
            let next = slicesSums[index+1]
            
            if current <= halfTotal && next >= halfTotal {
                return inital(in: dimension) + index + 1
            }
        }
        
        // Should never reach this
        fatalError("Really confused right now")
    }
    
    /// Lowest subvalue in given axis
    public func inital(in axis : Axis) -> Pixel.SubValue {
        switch axis {
        case .red:
            return initialRed
        case .green:
            return initialGreen
        case .blue:
            return initialBlue
        }
    }
    
    /// Highest subvalue in given axis
    public func final(in axis : Axis) -> Pixel.SubValue {
        switch axis {
        case .red:
            return finalRed
        case .green:
            return finalGreen
        case .blue:
            return finalBlue
        }
    }
    
    /// Subvalue bounds in given axis
    public func extremities(in axis : Axis) -> (lower : Pixel.SubValue, upper : Pixel.SubValue) {
        switch axis {
        case .red:
            return (initialRed, finalRed)
        case .green:
            return (initialGreen, finalGreen)
        case .blue:
            return (initialBlue, finalBlue)
        }
    }
    
    
    /// The statistical average pixel value
    ///
    /// - Complexity: O(n)
    /// - Returns: the average subvalues in each dimension as a pixel
    public func average() -> Pixel {
        var totalPopulation = 0
        var redSum = 0
        var greenSum = 0
        var blueSum = 0
        
        contents.forEach { (swatch) in
            totalPopulation += swatch.value
            let pixel = swatch.key
            redSum += pixel.red * swatch.value
            greenSum += pixel.green * swatch.value
            blueSum += pixel.blue * swatch.value
        }
        
        let finalRed = round(Double(redSum) / Double(totalPopulation))
        let finalGreen = round(Double(greenSum) / Double(totalPopulation))
        let finalBlue = round(Double(blueSum) / Double(totalPopulation))
        
        return Pixel(red: Pixel.SubValue(finalRed), green: Pixel.SubValue(finalGreen), blue: Pixel.SubValue(finalBlue))
    }
    
    /// The dimension with the greatest extent
    var longestDimension : Axis {
        return [Axis.red, Axis.green, Axis.blue].max { (first, second) -> Bool in
            // is Second larger than First?
            length(along: first) < length(along: second)
        }!
    }
    
    /// The length along a given axis
    ///
    /// - Parameter axis: the axis to use
    /// - Returns: Subvalue representing the length along dimension
    public func length(along axis : Axis) -> Pixel.SubValue {
        switch axis {
        case .red:
            return redLength
        case .green:
            return greenLength
        case .blue:
            return blueLength
        }
    }
    
    /// Halfway point along a given axis
    ///
    /// - Parameter axis: the axis to use
    /// - Returns: the subvalue that is halfway between min and max
    public func midpoint(in axis : Axis) -> Pixel.SubValue {
        let (lower, upper) = self.extremities(in: axis)
        return lower + (upper - lower) / 2
    }
    
    /// Check if the pixel is within the vbox's contents
    ///
    /// - Parameter pixel: the pixel to check
    /// - Returns: Whether the contents of the vbox contains the pixel
    public func contains(_ pixel : Pixel) -> Bool {
        if let _ = contents.index(forKey: pixel) {
            return true
        } else {
            return false
        }
    }
    
    /// Check if pixel is within bounds of vbox
    ///
    /// - Parameter pixel: the pixel to check
    /// - Returns: whether the pixel lies within the box
    public func covers(_ pixel : Pixel) -> Bool {
        return covers(value: pixel.red, in: .red) &&
            covers(value: pixel.green, in: .green) &&
            covers(value: pixel.blue, in: .blue)
    }
    
    /// Check if a pixel subvalue is within the bounds of the vbox
    ///
    /// - Parameters:
    ///   - value: the subvalue to be evaluated
    ///   - axis: along which acess to check for subvalue
    /// - Returns: whether the subvalue lies within the bounds of the axis
    public func covers(value : Pixel.SubValue, in axis : Axis) -> Bool {
        let extremitiesInAxis = extremities(in: axis)
        return extremitiesInAxis.lower <= value && value <= extremitiesInAxis.upper
    }
    
    /// Lowest red value in box
    public var initialRed : Pixel.SubValue {
        return minPixel.red
    }
    /// Largest red value in box
    public var finalRed : Pixel.SubValue {
        return maxPixel.red
    }
    /// Lowest green value in box
    public var initialGreen : Pixel.SubValue {
        return minPixel.green
    }
    /// Largest green value in box
    public var finalGreen : Pixel.SubValue {
        return maxPixel.green
    }
    /// Lowest blue value in box
    public var initialBlue : Pixel.SubValue {
        return minPixel.blue
    }
    /// Largest blue value in box
    public var finalBlue : Pixel.SubValue {
        return maxPixel.blue
    }
    /// The distance between min and max red values
    public var redLength : Pixel.SubValue {
        return finalRed - initialRed
    }
    /// The distance along red this box should take up in the world
    public var redExtent : Pixel.SubValue {
        return redLength + 1
    }
    /// The distance between min and max green values
    public var greenLength : Pixel.SubValue {
        return finalGreen - initialGreen
    }
    /// The distance along green this box should take up in the world
    public var greenExtent : Pixel.SubValue {
        return greenLength + 1
    }
    /// The distance between min and max blue values
    public var blueLength : Pixel.SubValue {
        return finalBlue - initialBlue
    }
    /// The distance along blue this box should take up in the world
    public var blueExtent : Pixel.SubValue {
        return blueLength + 1
    }
}

extension Pixel {
    
    subscript(axis : VBox.Axis) -> Pixel.SubValue {
        switch axis {
        case .red: return red
        case .green: return green
        case .blue: return blue
        }
    }
    
    init(_ elements : [VBox.Axis: Pixel.SubValue]) {
        self.init(red: elements[.red] ?? 0, green: elements[.green] ?? 0, blue: elements[.blue] ?? 0)
    }
}
