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
    
    public var minPixel : Pixel
    public var maxPixel : Pixel
    public var contents : [Pixel : Int] = [:]
    
    public var volume : Pixel.SubValue {
        return redExtent * greenExtent * blueExtent
    }
    
    public init(min : Pixel, max : Pixel, contents : [Pixel: Int]) {
        self.minPixel = min
        self.maxPixel = max
        self.contents = contents
    }
    
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
    
    public var canSplit : Bool {
        return redLength >= 1
    }
    
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
    
    private func median_dimensionOrder(for dimension : Axis) -> (Axis, Axis, Axis) {
        switch dimension {
        case .red:
            return (.red, .green, .blue)
        case .green:
            return (.green, .blue, .red)
        case .blue:
            return (.blue, .red, .green)
        }
    }
    
    public func median(along dimension : Axis) -> Pixel.SubValue {
        var totalSum = 0
        //var slicesCumSum : [Int] = []
        
        
        let (firstDimension, secondDimension, thirdDimension) = median_dimensionOrder(for: dimension)
        
        let lengthOfLongest = length(along: firstDimension)
        //slicesCumSum.reserveCapacity(lengthOfLongest)
        
        //var cachedPixel : [VBox.Axis: Pixel.SubValue] = [firstDimension: 0, secondDimension: 0, thirdDimension: 0]
        /// - todo: Maybe just use a hash sort
        
        var slicesSums : [Int] = [Int](repeating: 0, count: lengthOfLongest + 1)
        let minDimension = inital(in: firstDimension)
        contents.forEach { (swatch) in
            let (pixel, population) = swatch
            let redIndex = pixel[firstDimension] - minDimension
            slicesSums[Int(redIndex)] += population
            //for thingIndex in slicesSums[Int(redIndex)...].indices {
            //    slicesSums[thingIndex] += population
            //}
        }
        var thingToAddToNext = 0
        for (index, slicePopulation) in slicesSums.enumerated() {
            thingToAddToNext += slicePopulation
            slicesSums[index] = thingToAddToNext
        }
        totalSum = slicesSums.last!
//        print(inital(in: firstDimension)...final(in: firstDimension))
//        print(lengthOfLongest)
//        for firstIndex in inital(in: firstDimension)...final(in: firstDimension) {
//            var sliceSum = 0
//            cachedPixel[firstDimension] = firstIndex
//            for secondIndex in inital(in: secondDimension)...final(in: secondDimension) {
//                cachedPixel[secondDimension] = secondIndex
//                for thirdIndex in inital(in: thirdDimension)...final(in: thirdDimension) {
//                    cachedPixel[thirdDimension] = thirdIndex
//                    sliceSum += contents[Pixel(cachedPixel)] ?? 0
//                }
//            }
//            totalSum += sliceSum
//            slicesCumSum.append(totalSum)
//        }
//        assert(slicesCumSum[4] == slicesSums[4])
        let halfTotal = totalSum / 2
        
        
        // Possibility that first slice contains the majority of values
        if slicesSums[0] >= halfTotal {
            return inital(in: firstDimension) + 1
        }
        
        for index in slicesSums.indices.dropLast() {
            let current = slicesSums[index]
            let next = slicesSums[index+1]
            
            if current <= halfTotal && next >= halfTotal {
                return inital(in: firstDimension) + index + 1
            }
        }
        
        // Should never reach this
        fatalError("Really confused right now")
    }
    
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
        
//        for pixel in contents.keys {
//            let population = contents[pixel]!
//            totalPopulation += population
//            redSum   += pixel.red * population
//            greenSum += pixel.green * population
//            blueSum  += pixel.blue * population
//        }
        
        let finalRed = round(Double(redSum) / Double(totalPopulation))
        let finalGreen = round(Double(greenSum) / Double(totalPopulation))
        let finalBlue = round(Double(blueSum) / Double(totalPopulation))
        
        return Pixel(red: Pixel.SubValue(finalRed), green: Pixel.SubValue(finalGreen), blue: Pixel.SubValue(finalBlue))
    }
    
    var longestDimension : Axis {
        return [Axis.red, Axis.green, Axis.blue].max { (first, second) -> Bool in
            // is Second larger than First?
            length(along: first) < length(along: second)
        }!
    }
    
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
    
    public func midpoint(in dimension : Axis) -> Pixel.SubValue {
        let (upper, lower) = self.extremities(in: dimension)
        return (upper - lower) / 2
    }
    
    public func contains(_ pixel : Pixel) -> Bool {
        if let _ = contents.index(forKey: pixel) {
            return true
        } else {
            return false
        }
    }
    
    public func covers(_ pixel : Pixel) -> Bool {
        return covers(value: pixel.red, in: .red) &&
            covers(value: pixel.green, in: .green) &&
            covers(value: pixel.blue, in: .blue)
    }
    
    public func covers(value : Pixel.SubValue, in axis : Axis) -> Bool {
        let extremitiesInAxis = extremities(in: axis)
        return extremitiesInAxis.lower <= value && value <= extremitiesInAxis.upper
    }
    
    public var initialRed : Pixel.SubValue {
        return minPixel.red
    }
    
    public var finalRed : Pixel.SubValue {
        return maxPixel.red
    }
    
    public var initialGreen : Pixel.SubValue {
        return minPixel.green
    }
    
    public var finalGreen : Pixel.SubValue {
        return maxPixel.green
    }
    
    public var initialBlue : Pixel.SubValue {
        return minPixel.blue
    }
    
    public var finalBlue : Pixel.SubValue {
        return maxPixel.blue
    }
    
    public var redLength : Pixel.SubValue {
        return finalRed - initialRed
    }
    
    public var redExtent : Pixel.SubValue {
        return redLength + 1
    }
    
    public var greenLength : Pixel.SubValue {
        return finalGreen - initialGreen
    }
    
    public var greenExtent : Pixel.SubValue {
        return greenLength + 1
    }
    
    public var blueLength : Pixel.SubValue {
        return finalBlue - initialBlue
    }
    
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
