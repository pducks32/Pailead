import Foundation

#if os(macOS)
    public typealias Image = NSImage
    public typealias Color = NSColor
#elseif os(iOS)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
#endif

private class BlockMMCQProcessingDelegate : MMCQProcessingDelegate {
    var onDidFinish : ((ModifiedMedianCutQuantizer) -> Void)?
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didStartWith vbox: VBox) {}
    
    func mmcq(_ mmcq: ModifiedMedianCutQuantizer, didSplitBox: VBox, into: (VBox, VBox)) {}
    
    func mmcqDidFinishProcessing(_ mmcq: ModifiedMedianCutQuantizer) {
        self.onDidFinish?(mmcq)
    }
}

public struct Pailead {
    
    private static let defaultQueue = DispatchQueue(label: "com.patrickmetcalfe.pailead.processing")
    
    
    /// Extract the top average colors from a image
    /// - Remarks: Using Modified Median Cut Quantization, extract
    ///            the top colors found in the image using the given queue.
    ///
    /// - Parameters:
    ///   - numberOfColors: Number of avergae colors to extract
    ///   - image: The image to extract from.
    ///   - queue: The queue to use. (default is a private concurrent queue).
    ///   - completionHandler: What to do with the colors once generated.
    public static func extractTop(_ numberOfColors : Int, from image : Image, onQueue queue : DispatchQueue? = nil, completionHandler : @escaping (([Color]) -> Void)) {
        let chosenQueue = queue ?? defaultQueue
        chosenQueue.async {
            guard let pixelData = image.pixelData() else { fatalError("Pixel Extraction Failed") }
            var pixels : [Pixel] = []
            pixels.reserveCapacity(pixelData.count / 4)
            
            for index in stride(from: 0, to: pixelData.count, by: 4) {
                let pixel = Pixel(red: Int(pixelData[index]), green: Int(pixelData[index + 1]), blue: Int(pixelData[index + 2]))
                pixels.append(pixel)
            }
            
            let paileadThingy = ModifiedMedianCutQuantizer(numberOfSwatches: numberOfColors, pixels: pixels)
            let blockDelegate = BlockMMCQProcessingDelegate()
            blockDelegate.onDidFinish = { mmcq in
                let colors = mmcq.getSwatches().map({ (pixel : Pixel) -> Color in
                    let red = CGFloat(pixel.red) / 255
                    let green = CGFloat(pixel.green) / 255
                    let blue = CGFloat(pixel.blue) / 255
                    
                    return Color(red: red, green: green, blue: blue, alpha: 1)
                })
                completionHandler(colors)
            }
            paileadThingy.delegate = blockDelegate
            paileadThingy.run()
        }
    }
    
    class PaletteMaker {
        let swatches : [Swatch]
        
        var darkVibrantSwatch : Swatch?
        var vibrantSwatch : Swatch?
        var lightVibrantSwatch : Swatch?
        
        var darkMutedSwatch : Swatch?
        var mutedSwatch : Swatch?
        var lightMutedSwatch : Swatch?
        
        let highestPopulation : Int
        
        init(swatches : [Swatch]) {
            self.swatches = swatches
            self.highestPopulation = swatches.map({ $0.count }).max()!
            
            organizeSwatches()
        }
        
        func organizeSwatches() {
            vibrantSwatch = findColor(targetLuma: 0.5, minLuma: 0.3, maxLuma: 0.7, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            lightVibrantSwatch = findColor(targetLuma: 0.74, minLuma: 0.55, maxLuma: 1, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            darkVibrantSwatch = findColor(targetLuma: 0.26, minLuma: 0, maxLuma: 0.45, targetSaturation: 1, minSaturation: 0.35, maxSaturation: 1)
            
            
            mutedSwatch = findColor(targetLuma: 0.5, minLuma: 0.3, maxLuma: 0.7, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
            
            lightMutedSwatch = findColor(targetLuma: 0.74, minLuma: 0.55, maxLuma: 1, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
            
            darkMutedSwatch = findColor(targetLuma: 0.26, minLuma: 0, maxLuma: 0.45, targetSaturation: 0.3, minSaturation: 0, maxSaturation: 0.4)
        }
        
        func isAlreadySelected(_ swatch : Swatch) -> Bool {
            return vibrantSwatch == swatch || darkVibrantSwatch == swatch ||
                    lightVibrantSwatch == swatch || mutedSwatch == swatch ||
                    darkMutedSwatch == swatch || lightMutedSwatch == swatch
        }
        
        func findColor(targetLuma : Float, minLuma : Float, maxLuma : Float,
                       targetSaturation : Float, minSaturation : Float, maxSaturation : Float) -> Swatch? {
            var max : Swatch? = nil
            var maxValue : Float = 0
            let converter = HSLConverter()
            swatches.forEach { swatch in
                let (_, sat, luma) = converter.hslFor(swatch.pixel)
                if (sat >= minSaturation && sat <= maxSaturation &&
                    luma >= minLuma && luma <= maxLuma && !isAlreadySelected(swatch)) {
                    let thisValue : Float = findComparisonValue(saturation: sat, targetSaturation: targetSaturation, luma: luma, targetLuma: targetLuma, population: swatch.count, highestPopulation: highestPopulation)
                    if (max == nil || thisValue > maxValue) {
                        max = swatch
                        maxValue = thisValue;
                    }
                }
            }
            
            return max
        }
        
        func findComparisonValue(saturation : Float, targetSaturation : Float, luma : Float, targetLuma : Float, population : Int, highestPopulation : Int) -> Float {
            return weightedMean((invertDiff(value: saturation, targetValue: targetSaturation), 3),
                                (invertDiff(value: luma, targetValue: targetLuma), 6.5),
                                (Float(population) / Float(highestPopulation), 0.5))
        }
        
        func invertDiff(value : Float, targetValue : Float) -> Float {
            return 1.0 - abs(value - targetValue)
        }
        
        func weightedMean(_ values : (Float, Float)...) -> Float {
            var sum : Float = 0
            var sumWeight : Float = 0
            values.forEach { entry in
                sum += (entry.0 * entry.1)
                sumWeight += entry.1
            }
            return sum / sumWeight
        }
        
    }
    
    
    func generatePalettes(from image : Image) -> [Swatch] {
        
        return []
    }
}
